function instArray = getInstrumentsWeb(cgiurl)
%  getInstrumentsWeb  	returns an array of instrument structs of instruments found on remote Madrigal server.
%
%  inputs:  cgiurl (string) to Madrigal site cgi directory 
%      (Example: 'http://madrigal.haystack.mit.edu/cgi-bin/madrigal/') 
%      Note that method getMadrigalCgiUrl converts homepage url into cgiurl. 
%
%  output:
%     instArray - array of instrument structs found
%
%       instrument struct has the fields:
%
%     instrument.name (string) Example: 'Millstone Hill Incoherent Scatter Radar'
%     instrument.code (int) Example: 30
%     instrument.mnemonic (3 char string) Example: 'mlh'
%     instrument.latitude (double) Example: 45.0
%     instrument.longitude (double) Example: 110.0
%     instrument.altitude (double)  Example: 0.015 (km) 
%     instrument.category (string) Instrument category description.  May be
%       if Madrigal 2.6 or earlier.
%
%  Raises error if unable to return instrument array
% 
%  Example:
%  getInstrumentsWeb('http://madrigal.haystack.mit.edu/cgi-bin/madrigal/')

% deal with arguments

if (nargin ~= 1)
    error('Usage: [instArray] = getInstrumentsWeb(cgiurl)');
end

% build the complete cgi string
cgiurl = strcat(cgiurl, 'getInstrumentsService.py');

% make sure any + replaced by %2B
cgiurl = strrep(cgiurl,'+','%2B');

% now get that url
these_options = weboptions('Timeout',300, 'ContentType', 'text');
result = webread(cgiurl, these_options);

% look for errors - if html returned, error occurred
htmlList = strfind(result, '</html>');
if (~isempty(htmlList))
    err.message = strcat('Unable to run cgi script getInstrumentsWeb using cgiurl: - ', cgiurl);
    err.identifier = 'madmatlab:scriptError';
    rethrow(err);
end
% check that not too short
if (length(result) < 10)
    err.message = 'Unable to run cgi script getInstrumentsWeb using cgiurl provided';
    err.identifier = 'madmatlab:scriptError';
    rethrow(err);
end

% surpress matlab warning about multibyte Characters
warning off REGEXP:multibyteCharacters

result = sprintf('%s\n', result);

% parse result
lineMarks = regexp(result, '\n');
% init array to return
instArray = [];
% loop through each line
for line = 1:length(lineMarks)
    if line == 1
        thisLine = result(1:lineMarks(line));
    else
         thisLine = result(lineMarks(line-1):lineMarks(line));
    end
    if length(thisLine) < 10
        continue
    end
    commaMarks = strfind(thisLine, ',');
    % name
    newInstrument.name = strtrim(thisLine(1:commaMarks(1)-1));
    % code
    newInstrument.code = str2num(thisLine(commaMarks(1)+1:commaMarks(2)-1));
    % mnemonic
    newInstrument.mnemonic = thisLine(commaMarks(2)+1:commaMarks(3)-1);
    % latitude
    newInstrument.latitude = str2num(thisLine(commaMarks(3)+1:commaMarks(4)-1));
    % longitude
    newInstrument.longitude = str2num(thisLine(commaMarks(4)+1:commaMarks(5)-1));
    % altitude
    if length(commaMarks) > 5
        newInstrument.altitude = str2num(thisLine(commaMarks(5)+1:commaMarks(6)-1));
    else
        newInstrument.altitude = str2num(thisLine(commaMarks(5)+1:end));
    end
    % category
    if length(commaMarks) > 6
        newInstrument.category = thisLine(commaMarks(6)+1:commaMarks(7)-1);
    elseif length(commaMarks) == 6
        newInstrument.category = thisLine(commaMarks(6)+1:end-1);
    else
        newInstrument.category = 'Unknown';
    end
    % append new instrument
    instArray = [instArray newInstrument];
end

