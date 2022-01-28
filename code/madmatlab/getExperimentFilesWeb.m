function expFileArray = getExperimentFilesWeb(cgiurl, experimentId)
%  getExperimentFilesWeb  	returns an array of experiment file structs given experiment id from a remote Madrigal server.
%
%  Note that it is assumed that experiment is local to cgiurl.  If not,
%  empty list will be returned. Use getCgiurlForExperiment to get the correct
%  cgiurl for any given experiment struct.
%
%  Inputs:
%
%      1. cgiurl (string) to Madrigal site cgi directory that has that
%      experiment.
%        (Example: 'http://madrigal.haystack.mit.edu/cgi-bin/madrigal/') 
%         Note that method getMadrigalCgiUrl converts homepage url into cgiurl. 
% 
%      2. experiment id (int) as returned by getExperiments or
%         getExperimentsWeb
%
%   Return array of Experiment File struct (May be empty):
%   
%   file.name (string) Example '/opt/mdarigal/blah/mlh980120g.001'
%   file.kindat (int) Kindat code.  Example: 3001
%   file.kindatdesc (string) Kindat description: Example 'Basic Derived Parameters'
%   file.category (int) (1=default, 2=variant, 3=history, 4=real-time)
%   file.status (string)('preliminary', 'final', or any other description)
%   file.permission (int)  0 for public, 1 for private 
%   file.doi (string) - citable doi for file ('None' if not available)
%
%  Raises error if unable to return experiment file array
% 
%  Example: expFileArray =
%  getExperimentFilesWeb('http://madrigal.haystack.mit.edu/cgi-bin/madrigal/', 10001686);
    
% check input arguments
if (~isnumeric(experimentId))
    err.message = 'experimentId must be integer';
    err.identifier = 'madmatlab:badArguments';
    rethrow(err);
end

if (experimentId == -1)
    err.message = 'Invalid experiment id.  This is usually caused by calling getExperimentsWeb for a non-local experiment.  You need to make a second call to getExperimentsWeb with the cgiurl of the non-local experiment (getCgiurlForExperiment(experiment.url))';
    err.identifier = 'madmatlab:badArguments';
    rethrow(err);
end

dims = size(experimentId);
if (dims(1) ~= 1 | dims(2) ~= 1)
    err.message = 'experimentId must be integer';
    err.identifier = 'madmatlab:badArguments';
    rethrow(err);
end

if (nargin ~= 2)
    err.message = 'usage: getExperimentFilesWeb(cgiurl, experimentId)';
    err.identifier = 'madmatlab:badArguments';
    rethrow(err);
end

% build the complete cgi url
if (cgiurl(end) == '/')
    cgiurl = strcat(cgiurl, 'getExperimentFilesService.py?');
else
    cgiurl = strcat(cgiurl, '/getExperimentFilesService.py?');
end


% append id
[temp  errmsp] = sprintf('id=%s', num2str(experimentId));
cgiurl = strcat(cgiurl, temp);

% make sure any + replaced by %2B
cgiurl = strrep(cgiurl,'+','%2B');

% now get that url
these_options = weboptions('Timeout',300, 'ContentType', 'text');
result = webread(cgiurl, these_options);

% look for errors - if html returned, error occurred
htmlList = strfind(result, '</html>');
if (~isempty(htmlList))
    err.message = strcat('Unable to run cgi script getExperimentFilesWeb using cgiurl: - ', cgiurl);
    err.identifier = 'madmatlab:scriptError';
    rethrow(err);
end

% surpress matlab warning about multibyte Characters
warning off REGEXP:multibyteCharacters

result = sprintf('%s\n', result);

% parse result
lineMarks = regexp(result, '\n');

% init array to return
expFileArray = [];
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
    newExperimentFile.name = strtrim(thisLine(1:commaMarks(1)-1));
    % kindat
    newExperimentFile.kindat = str2num(thisLine(commaMarks(1)+1:commaMarks(2)-1));
    % kindatdesc
    newExperimentFile.kindatdesc = thisLine(commaMarks(2)+1:commaMarks(3)-1);
    % category
    newExperimentFile.category = str2num(thisLine(commaMarks(3)+1:commaMarks(4)-1));
    % status
    newExperimentFile.status = thisLine(commaMarks(4)+1:commaMarks(5)-1);
    % permission
    if length(commaMarks) > 5
        newExperimentFile.permission = str2num(thisLine(commaMarks(5)+1:commaMarks(6)-1));
    else
        newExperimentFile.permission = str2num(thisLine(commaMarks(5)+1:end));
    end
    % doi
    if length(commaMarks) > 6
        newExperimentFile.doi = thisLine(commaMarks(6)+1:commaMarks(7)-1);
    elseif length(commaMarks) == 6
        newExperimentFile.doi = thisLine(commaMarks(6)+1:end);
    else
        newExperimentFile.doi = 'None';
    end
    
    % append new experiments
    expFileArray = [expFileArray newExperimentFile];
end
