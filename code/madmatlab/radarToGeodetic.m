function [geodeticArr] = radarToGeodetic(madrigalUrl, slatgd, slon, saltgd, azArr, elArr, rangeArr)
% radarToGeodetic converts arrays of az,el, and range values to geodetic
%   arrays of lat, lon and alt.
%
%  Inputs:
%
%  madrigalUrl - url to madrigal site, such as
%   'http://www.haystack.mit.edu/madrigal'
%  slatgd - radar geodetic latitude
%  slon - radar longitude
%  saltgd - radar altitude in km
%  azArr - array of input az values (-180 - 180)
%  elArr - array of input el values (0 - 90) (len = len of azArr)
%  rangeArr - array of input range values in km (len = len of azArr)
%
%  Returns a 3 X N matrix where column 1 is lat, column 2 is long, and 
%  column 3 is alt.  N is the length of the input matrices.  
%
%  Example:
%
%    res = radarToGeodetic('http://millstonehill.haystack.mit.edu', ...
%                           42.0,-71.0,0.1, ...
%                           [-20, -10, 0, 10, 20],[45,45,45,45,45], ...
%                           [1000.0, 1000.0, 1000.0, 1000.0, 1000.0]);
%
% $Id: radarToGeodetic.m 6811 2019-03-28 19:13:46Z brideout $
%
cgiurl = getMadrigalCgiUrl(madrigalUrl);

% check that lengths are the same
if (length(azArr) ~= length(elArr) | length(azArr) ~= length(rangeArr))
    err.message = 'All input array lengths must be equal';
    err.identifier = 'madmatlab:badArguments';
    rethrow(err);
end

% build the complete cgi url
cgiurl = strcat(cgiurl, 'radarToGeodeticService.py?');

% append arguments
[temp  errmsp] = sprintf('slatgd=%f&', slatgd);
cgiurl = strcat(cgiurl, temp);
[temp  errmsp] = sprintf('slon=%f&', slon);
cgiurl = strcat(cgiurl, temp);
[temp  errmsp] = sprintf('saltgd=%f&', saltgd);
cgiurl = strcat(cgiurl, temp);

% append input points
cgiurl = strcat(cgiurl, 'az=');
for i = 1:length(azArr)
    if (i == length(azArr))
        [temp  errmsp] = sprintf('%f&', azArr(i));
    else
        [temp  errmsp] = sprintf('%f,', azArr(i));
    end
    cgiurl = strcat(cgiurl, temp);
end
cgiurl = strcat(cgiurl, 'el=');
for i = 1:length(elArr)
    if (i == length(elArr))
        [temp  errmsp] = sprintf('%f&', elArr(i));
    else
        [temp  errmsp] = sprintf('%f,', elArr(i));
    end
    cgiurl = strcat(cgiurl, temp);
end
cgiurl = strcat(cgiurl, 'range=');
for i = 1:length(rangeArr)
    if (i == length(rangeArr))
        [temp  errmsp] = sprintf('%f&', rangeArr(i));
    else
        [temp  errmsp] = sprintf('%f,', rangeArr(i));
    end
    cgiurl = strcat(cgiurl, temp);
end

% now get that url
these_options = weboptions('Timeout',300, 'ContentType', 'text');
result = webread(cgiurl, these_options);

% look for errors - if html returned, error occurred
htmlList = strfind(result, 'Error');
if (~isempty(htmlList))
    err.message = strcat('Unable to run cgi script radarToGeodeticService using cgiurl: - ', cgiurl);
    err.identifier = 'madmatlab:scriptError';
    result
    rethrow(err);
end

% surpress matlab warning about multibyte Characters
warning off REGEXP:multibyteCharacters

% parse result
lineMarks = regexp(result, '\n');
commaMarks = strfind(result, ',');
% parsing state variables
presentStart = 1;
presentToken = 1;
% init array to return
geodeticArr = [];
% loop through each line
for line = 1:length(lineMarks)
    % make sure were not finished
    if (presentStart >= lineMarks(end))
        break;
    end
    lat = str2num(result(presentStart:commaMarks(presentToken)-1));
    presentStart = commaMarks(presentToken) + 1;
    presentToken = presentToken + 1;
    lon = str2num(result(presentStart:commaMarks(presentToken)-1));
    presentStart = commaMarks(presentToken) + 1;
    presentToken = presentToken + 1;
    alt = str2num(result(presentStart:lineMarks(line)-1));
    presentStart = lineMarks(line) + 1;
    geodeticArr = [geodeticArr; lat lon alt];
end

return;
