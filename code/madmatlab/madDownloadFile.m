function  result  = madDownloadFile(cgiurl,  fullFilename, outputFile, user_fullname, user_email, user_affiliation, format )
%madDownloadFile downloads a Madrigal file to local computer in various
%formats
%
%    The calling syntax is:
%       result  = madDownloadFile(cgiurl,  fullFilename, outputFile, [ format ] )
%   
% Inputs: 
%
%      1. cgiurl (string) to Madrigal site cgi directory 
%        (Example: 'http://madrigal.haystack.mit.edu/cgi-bin/madrigal/') 
%         Note that method getMadrigalCgiUrl converts homepage url into
%         cgiurl. 
%
%      2. fullFilename - file to download as returned by getExperimentFilesWeb.m
%
%      3. outputFile - name to save new file to
%
%      4. user_fullname - is user name (string)
%
%      5. user_email - is user email address (string)
%
%      6. user_affiliation - is user affiliation (string) 
%
%      7. format - one of the following strings:
%          'simple', 'hdf5', 'netCDF4'
%              'simple' is the default if not specified.  
%
%         'netCDF4' option will only work with Madrigal 3.0 or greater
%
%    $Id: madDownloadFile.m 6971 2019-07-29 19:25:40Z brideout $
%
result = -1;

if (nargin < 6)
    error('Usage: result  = madDownloadFile(cgiurl,  fullFilename, outputFile, user_fullname, user_email, user_affiliation, [ format ] )');
end
if (nargin < 7)
    format = 'simple';
end

% verify wget installed before we do anything
% try to use wget
[result, cmdout] = system('wget -h');
if (result ~= 0)
    exception = MException('Madmatlab:WgetFailed', ...
       'Unable to run wget - please make sure its installed');
    throw(exception);
end


if (strcmp(format, 'simple'))
    fileType = -1;
elseif (strcmp(format, 'hdf5'))
    fileType = -2;
elseif (strcmp(format, 'netCDF4'))
    fileType = -3;
    % verify Madrigal can handle this
    thisVer = getVersion(cgiurl);
    if (compareVersions(thisVer, '3.0') < 0)
        err.message = 'This madrigal site does not support netCDF4 format until it is upgraded to at least 3.0';
        err.identifier = 'madmatlab:badArguments';
        rethrow(err);
    end
else
    err.message = 'illegal format argument in madDownloadFile';
    err.identifier = 'madmatlab:badArguments';
    rethrow(err);
end

% build the complete cgi url
if (cgiurl(end) == '/')
    cgiurl = strcat(cgiurl, 'getMadfile.cgi?');
else
    cgiurl = strcat(cgiurl, '/getMadfile.cgi?');
end


% append filename and filetype
[temp  errmsp] = sprintf('fileName=%s&fileType=%i&user_fullname=%s&user_email=%s&user_affiliation=%s', ...
    fullFilename, fileType, user_fullname, user_email, user_affiliation);
cgiurl = strcat(cgiurl, temp);

% make sure any + replaced by %2B
cgiurl = strrep(cgiurl,'+','%2B');

% make sure any space replaced by +
cgiurl = strrep(cgiurl,' ','+');

wget_command = horzcat('wget -q --timeout=600 --tries=4 -O', ' ', outputFile, ' "', cgiurl, '"');

% Use wget
tic;
[result, cmdout] = system(wget_command);
if (result ~= 0)
    time_passed = toc;
    if (time_passed > 590)
        % Assume simply timed out
        disp('Timeout occured - file not downloaded');
        result = -1;
        return;
    else
        exception = MException('Madmatlab:WgetFailed', ...
            strcat('Wget command failed: ', wget_command));
        throw(exception);
    end
end

% if text, try to uncompress
if (fileType == -1)
    % verify gunzip installed
    cmd = 'gunzip -h';
    [result, cmdout] = system(cmd);
    if (result ~= 0)
        exception = MException('Madmatlab:download', ...
            'gunzip command failed, gunzip must be installed.');
        throw(exception);
    end
    cmd = sprintf('cp %s %s.gz', outputFile, outputFile);
    [result, cmdout] = system(cmd);
    if (result ~= 0)
        exception = MException('Madmatlab:download', ...
            strcat('cp command failed: ', cmd));
        throw(exception);
    end
    cmd = sprintf('gunzip -f %s.gz', outputFile);
    [result, cmdout] = system(cmd);
    if (result ~= 0)
        % file may not have been compressed - just cp it back
        cmd = sprintf('mv %s.gz %s', outputFile, outputFile);
        [result, cmdout] = system(cmd);
    end
    
end


% surpress matlab warning about multibyte Characters
warning off REGEXP:multibyteCharacters

result = 0;
end

