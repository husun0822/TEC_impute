function records = isprintWeb(cgiUrl, file, parms, user_fullname, user_email, user_affiliation, filters, outputFile, missing, assumed, knownbad)
%  isprintWeb  	Create an isprint-like 3D array of doubles via a command similar to the isprint command-line application, but access data via the web
%  
%  The calling syntax is:
%  
%  		[records] = isprintWeb(cgiUrl, file, parms, user_fullname, user_email, user_affiliation, [filters, [outputFile, [missing, [assumed, [knownbad] ] ] ] ])
%  
%   where 
%
%     cgiUrl (string) to Madrigal site cgi directory that has that
%      filename.
%        (Example: 'http://madrigal.haystack.mit.edu/cgi-bin/madrigal/') 
%         Note that method getMadrigalCgiUrl converts homepage url into cgiUrl.
%  
%     file is path to file
%         (example = '/home/brideout/data/mlh980120g.001')
%  
%     parms is the desired parameters in the form of a comma-delimited
%         string of Madrigal mnemonics (example = 'gdlat,ti,dti')
%
%     user_fullname - is user name (string)
%
%     user_email - is user email address (string)
%
%     user_affiliation - is user affiliation (string) 
%  
%     filters is the optional filters requested in exactly the form given in isprint
%         command line (example = 'time1=15:00:00 date1=01/20/1998 
%                       time2=15:30:00 date2=01/20/1998 filter=ti,500,1000')
%         See:  http://millstonehill.haystack.mit.edu/ug_commandLine.html for details
%
%     outputFile - save the output to an output file.  If extension is in
%       .h5, .hdf, or .hdf5, the output format will be Madrigal Hdf5.  If
%       extension is .nc, it will be netCDF4.  Otherwise ascii.
%
%     missing is an optional double to represent missing values.  Defaults to NaN
%
%     assumed is an optional double to represent assumed values.  Defaults to NaN
%
%     knownbad is an optional double to represent knownbad values.  Defaults to NaN
%
%     If not outputFile set, he returned records is a three dimensional array of double with the dimensions:
%
%         [Number of rows, number of parameters requested, number of records]
%
%     If outputFile set, records is set to 0.
%
%     If error or no data returned, will return error explanation string instead.
%
%   Example: data = isprintWeb('http://madrigal.haystack.mit.edu/cgi-bin/madrigal/', ...
%                                '/opt/madrigal/experiments/1998/mlh/07jan98/mil980107g.001', ...
%                                'gdlat,ti,dti', ...
%                                'Bill Rideout', 'wrideout@haystack.mit.edu', 'MIT');
%
%   Requires wget.
%
%    $Id: isprintWeb.m 6811 2019-03-28 19:13:46Z brideout $

% constant
maxRecs = 1000;
maxCalls = 500;

% defaults
missingValue = NaN;
assumedValue = NaN;
knownbadValue = NaN;


if (nargin < 6)
    error('Usage: [records] = isprintWeb(url, file, parms, user_fullname, user_email, user_affiliation, [filters, [missing, [assumed, [knownbad] ] ] ])');
end
if (nargin < 7)
    filters = '';
end
if (nargin < 8)
    outputFile = '';
end
if (nargin < 9)
    missing = missingValue;
end
if (nargin < 10)
    assumed = assumedValue;
end
if (nargin < 11)
    knownbad = knownbadValue;
end

% verify user entered doubles for missing, assumed, knownbad
if (strcmp(class(missing), 'char'))
    error('missing must be a float or NaN, not a string')
end
if (strcmp(class(assumed), 'char'))
    error('assumed must be a float or NaN, not a string')
end
if (strcmp(class(knownbad), 'char'))
    error('knownbad must be a float or NaN, not a string')
end

if (length(outputFile) > 1)
    [pathstr,name,ext] = fileparts(outputFile);
    if (strcmp(ext, '.h5') | strcmp(ext, '.hdf5') | strcmp(ext, '.hdf'))
        format = 'Hdf5';
    elseif (strcmp(ext, '.nc'))
        format = 'netCDF4';
    else
        format = 'ascii';
    end
    useStdOut = 0;
else
    format = 'ascii';
    useStdOut = 1;
end

if (strcmp(format, 'Hdf5') | strcmp(format, 'netCDF4'))
    % we need to verify its Madrigal 3 at least
    version = getVersion(cgiUrl);
    items = strsplit(version, '.');
    majorRelease = str2num(char(items(1)));
    if (majorRelease < 3)
        error('You can only request data in Hdf5 or netCDF4 format if the Madrigal site is 3.0 or later');
    end
end

% Use wget only

records = isprintWget(cgiUrl, file, parms, user_fullname, user_email, user_affiliation, filters, outputFile, missing, assumed, knownbad);
if (useStdOut ~= 1 && records ~= -1)
    records = 0;
end
return



