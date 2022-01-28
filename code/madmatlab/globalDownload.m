function [] = globalDownload(url, ...
    outputDir, ...
    user_fullname, ...
    user_email, ...
    user_affiliation, ...
    format, ...
    startTime, ...
    endTime, ...
    inst, ...
    kindats, ...
    expName, ...
    fileDesc, ...
    excludeExpName)
% globalDownload is a script to search through the entire Madrigal database
% for appropriate files in ascii, hdf5, or netCDF4 format to store locally
%
%    Inputs:
%
%        url - url to homepage of site to be searched (Example: 
%              'http://millstonehill.haystack.mit.edu/'
%
%        outputDir - the local directory to store the downloaded files.
%                 (Example: './isprint.txt')
%
%        user_fullname - the full user name (Example: 'Bill Rideout')
%
%        user email -  Example: 'brideout@haystack.mit.edu'
%
%        user_affiliation - Example: 'MIT'
%
%        format - either "ascii" or "hdf5" or "netCDF4" (if Madrigal 3 site).  Ascii is simple column
%        delimited acsii
%
%        startTime - a Matlab time to begin search at. Example:
%                    datenum('20-Jan-1998 00:00:00') Time in UT
%
%        endTime - a Matlab time to end search at. Example:
%                  datenum('21-Jan-1998 23:59:59') Time in UT
%
%        inst - instrument code (integer).  See 
%            http://cedar.openmadrigal.org/instMetadata/
%            for this list. Examples: 30 for Millstone
%            Hill Incoherent Scatter Radar, 80 for Sondrestrom Incoherent 
%            Scatter Radar
%
%    Optional inputs
%
%        kindats - is an optional array of kindat (kinds of data) codes to accept.
%           The default is an empty array, which will accept all kindats.
%  
%        expName - a case insensitive regular expression that matches the experiment
%           name.  Default is zero-length string, which matches all experiment names.
%           For example, *ipy* matches any name containing ipy, IPY, etc.
%
%        fileDesc - a case insensitive regular expression that matches the file description.
%           Default is zero-length string, which matches all file descriptions.
%
%        excludeExpName - a case insensitive regular expression that matches the experiment
%           name.  Experiment is rejected if match. Default is zero-length
%           string, and no experiments excluded.
% 
%        ADDED by Jiaen Ren:
%        subfolder - true or false: whether create subfolders to save the data
%
%    Returns: Nothing.
%
%    Affects: Writes downloaded files to outputDir
%
%        
%
%  Example: globalDownload('http://millstonehill.haystack.mit.edu/', ...
%                         'downloadDir', ...
%                         'Bill Rideout', ...
%                         'brideout@haystack.mit.edu', ...
%                         'MIT', ...
%                         'ascii', ...
%                         datenum('20-Jan-1998 00:00:00'), ...
%                         datenum('21-Jan-1998 23:59:59'), ...
%                         30);
%
%  $Id: globalDownload.m 6811 2019-03-28 19:13:46Z brideout $
%


if (nargin < 10)
    kindats = [];
end

if (nargin < 11)
    expName = '';
end

if (nargin < 12)
    fileDesc = [];
end

if (nargin < 13)
    excludeExpName = '';
end

% make sure directory exists
if (exist(outputDir) ~= 7)
    mkdir(outputDir)
end

% check format
if strcmp(format, 'ascii')
    format = 'simple';
elseif strcmp(format, 'hdf5')
    ;
elseif strcmp(format, 'netCDF4')
    ;    
else
    exception = MException('Madmatlab:IllegalArgument', ...
       strcat('Illegal format ', format));
    throw(exception);
end
    
cgiurl = getMadrigalCgiUrl(url);
expArray = getExperimentsWeb(cgiurl, inst, startTime, endTime, 1);
if (isempty(expArray))
    exception = MException('Madmatlab:NoExperimentsFound', ...
       'No experiments found for these arguments');
    throw(exception);
end

% loop through each experiment
for i = 1:length(expArray)

    % expName filter, if any
    if (length(expName) > 0)
        result = regexpi(expArray(i).name, expName);
        if (length(result) == 0)
            continue;
        end
    end
    
    % excludeExpName filter, if any
    if (length(excludeExpName) > 0)
        result = regexpi(expArray(i).name, excludeExpName);
        if (length(result) ~= 0)
            continue;
        end
    end

     % for each experiment, find all default files
     expFileArray = getExperimentFilesWeb(cgiurl, expArray(i).id);
     for j = 1:length(expFileArray)
         if (expFileArray(j).category ~= 1)
             continue
	 end
	 
	 % kindat filter
	 if (length(kindats) > 0)
             okay = 0;
             for k = 1:length(kindats)
                 if (expFileArray(j).kindat == kindats(k))
                     okay = 1;
                     break;
                 end
             end
             if (okay == 0)
                 continue;
             end
	 end
	 
	 % fileDesc filter, if any
     if (length(fileDesc) > 0)
         result = regexpi(expFileArray(j).status, fileDesc);
         if (length(result) == 0)
             continue;
         end
     end

     % download file
     fullFilename = expFileArray(j).name;
     % get basename
     tokenList = strfind(fullFilename, '/');
     token = tokenList(end);
     basename = fullFilename(token+1:end);
	 fprintf(1, 'Downloading file %s\n', fullFilename);
     
     % edit by Jiaen Ren, create subfolders to avoid files with the same
     % name replacing each other
     subfolder = false;
     if subfolder
         fnames = strsplit(fullFilename,'/');
         subfoldyear = fnames{end-3};
         subfoldname = fnames{end-1};
         fulloutputDir = [strrep(outputDir,'\','') '/' subfoldyear '/' subfoldname];
         if ~isfolder(fulloutputDir)
             mkdir(fulloutputDir);
         end
         suboutputDir = [outputDir '/' subfoldyear '/' subfoldname];
     else
         suboutputDir = outputDir;
     end
    
     if strcmp(format, 'simple')
        outputFile = strcat(suboutputDir, '/', basename, '.txt');
     elseif strcmp(format, 'hdf5')
        outputFile = strcat(suboutputDir, '/', basename, '.hdf5');
     elseif strcmp(format, 'netCDF4')
        outputFile = strcat(suboutputDir, '/', basename, '.nc');
     end
     
     if ~isfile(strrep(outputFile,'\',''))
         madDownloadFile(cgiurl,  fullFilename, outputFile, user_fullname, user_email, user_affiliation, format);
     end
end % experiment loop

end
