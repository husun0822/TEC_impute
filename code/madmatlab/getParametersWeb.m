function parmArray = getParametersWeb(cgiurl, filename)
%  getParametesWeb  	returns an array of parameter structs given filename from a remote Madrigal server.
%
%  Note that it is assumed that filename is local to cgiurl.  If not,
%  empty list will be returned.
%
%  Inputs:
%
%      1. cgiurl (string) to Madrigal site cgi directory that has that
%      filename.
%        (Example: 'http://madrigal.haystack.mit.edu/cgi-bin/madrigal/') 
%         Note that method getMadrigalCgiUrl converts homepage url into cgiurl. 
% 
%      2. filename (string) as returned by getExperimentFiles or
%         getExperimentFilesWeb
%
%   Return array of Parameter struct:
%   
%       parameter.mnemonic (string) Example 'dti'
%       parameter.description (string) Example:
%          "F10.7 Multiday average observed (Ott) - Units: W/m2/Hz"
%       parameter.isError (int) 1 if error parameter, 0 if not
%       parameter.units (string) Example "W/m2/Hz"
%       parameter.isMeasured (int) 1 if measured, 0 if derivable
%       parameter.category (string) Example: "Time Related Parameter" 
%       parameter.isSure (int) 1 if can be found for all records, 0 if only
%           for some records (implies not all records have same measured
%           parameters)
%
%  Raises error if unable to return parameter array
% 
%  Example: parmArray = getParametersWeb('http://madrigal.haystack.mit.edu/cgi-bin/madrigal/', ...
%                                        '/opt/madrigal/experiments/1998/mlh/07jan98/mil980107g.001')

% check input arguments

if (nargin ~= 2)
    err.message = 'usage: getParametersWeb(cgiurl, filename)';
    err.identifier = 'madmatlab:badArguments';
    rethrow(err);
end

% build the complete cgi url
cgiurl = strcat(cgiurl, 'getParametersService.py?');

% append filename
[temp  errmsp] = sprintf('filename=%s', filename);
cgiurl = strcat(cgiurl, temp);

% make sure any + replaced by %2B
cgiurl = strrep(cgiurl,'+','%2B');

% now get that url
these_options = weboptions('Timeout',300, 'ContentType', 'text');
result = webread(cgiurl, these_options);

% look for errors - if html returned, error occurred
htmlList = strfind(result, '</html>');
if (~isempty(htmlList))
    err.message = strcat('Unable to run cgi script getParametersWeb using cgiurl: - ', cgiurl);
    err.identifier = 'madmatlab:scriptError';
    rethrow(err);
end

% surpress matlab warning about multibyte Characters
warning off REGEXP:multibyteCharacters

result = sprintf('%s\n', result);

% parse result - note that backslash used as delimiter, since text may contain
%    commas
lineMarks = regexp(result, '\n');

% init array to return
parmArray = [];
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
    backslashMarks = regexp(thisLine, '\\');
    % mnemonic
    newParameter.mnemonic = strtrim(thisLine(1:backslashMarks(1)-1));
    % description
    newParameter.description = thisLine(backslashMarks(1)+1:backslashMarks(2)-1);
    % isError
    newParameter.isError = str2num(thisLine(backslashMarks(2)+1:backslashMarks(3)-1));
    % units
    newParameter.units = thisLine(backslashMarks(3)+1:backslashMarks(4)-1);
    % isMeasured
    newParameter.isMeasured = str2num(thisLine(backslashMarks(4)+1:backslashMarks(5)-1));
    % category
    newParameter.category = thisLine(backslashMarks(5)+1:backslashMarks(6)-1);
    % finally, isSure
    if length(backslashMarks) > 6
        newParameter.isSure = str2num(thisLine(backslashMarks(6)+1:backslashMarks(7)-1));
    else
        newParameter.isSure = str2num(thisLine(backslashMarks(6)+1:end));
    end
    
    % append new parameter
    parmArray = [parmArray newParameter];
end
