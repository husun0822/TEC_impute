function expArray = getExperimentsWeb(cgiurl, instCodeArray, starttime, endtime, localFlag)
%  getExperimentsWeb  	returns an array of experiment structs given input filter arguments from a remote Madrigal server.
%
%  Inputs:
%
%      1. cgiurl (string) to Madrigal site cgi directory 
%        (Example: 'http://madrigal.haystack.mit.edu/cgi-bin/madrigal/') 
%         Note that method getMadrigalCgiUrl converts homepage url into cgiurl. 
% 
%      2. instCodeArray - a 1 X N array of ints containing selected instrument codes.  Special value of 0 selects all instruments.
% 
%      3. starttime - Matlab datenum double (must be UTC)
% 
%      4. endtime - Matlab datenum double (must be UTC)
%
%      5. localFlag - 1 if local experiments only, 0 if all experiments 
%
%   Returns a startime sorted array of Experiment struct (May be empty):
%   
%   experiment.id (int) Example: 10000111
%   experiment.url (string) Example: 'http://madrigal.haystack.mit.edu/cgi-bin/madtoc/1997/mlh/03dec97'
%      Deprecated url used only in metadata. To see real url, use realUrl
%      field described below
%   experiment.name (string) Example: 'Wide Latitude Substorm Study'
%   experiment.siteid (int) Example: 1
%   experiment.sitename (string) Example: 'Millstone Hill Observatory'
%   experiment.instcode (int) Code of instrument. Example: 30
%   experiment.instname (string) Instrument name. Example: 'Millstone Hill Incoherent Scatter Radar'
%   experiment.starttime (double) Matlab datenum of experiment start
%   experiment.endtime (double) Matlab datenum of experiment end
%   experiment.isLocal (int) 1 if local, 0 if not 
%   experiment.madrigalUrl (string) - home url of Madrigal site with this
%       experiment. Example 'http://millstonehill.haystack.mit.edu'
%   experiment.PI - experiment principal investigator.  May be unknown for
%       Madrigal 2.5 and earlier sites.
%   experiment.PIEmail - PI email. May be unknown for Madrigal 2.6 or
%       earlier.
%   realUrl - real url to experiment valid for web browser
%
%  Raises error if unable to return experiment array
% 
%  Example: expArray = getExperimentsWeb('http://madrigal.haystack.mit.edu/cgi-bin/madrigal/', ...
%                                         30, datenum('01/01/1998'), datenum('12/31/1998'), 1);
%
%   Note that if the returned
%   experiment is not local, the experiment.id will be -1.  This means that you
%   will need to call getExperimentsWeb a second time with the cgiurl of the 
%   non-local experiment (getCgiurlForExperiment(experiment.madrigalUrl)).  This is because 
%   while Madrigal sites share metadata about experiments, the real experiment ids are only
%   known by the individual Madrigal sites.  See testMadmatlab.m
%   for an example of this.

% check input arguments
if (~isnumeric(instCodeArray))
    err.message = 'second argument to getExperimentsWeb must be 1 x N array of ints - use 0 for all instruments';
    err.identifier = 'madmatlab:badArguments';
    rethrow(err);
end

dims = size(instCodeArray);
if (dims(1) ~= 1 | dims(2) < 1)
    err.message = 'second argument to getExperimentsWeb must be 1 x N array of ints - use 0 for all instruments';
    err.identifier = 'madmatlab:badArguments';
    rethrow(err);
end

if (nargin ~= 5)
    err.message = 'getExperimentsWeb usage: expArray = getExperimentsWeb(cgiurl, instCodeArray, starttime, endtime, localFlag)';
    err.identifier = 'madmatlab:badArguments';
    rethrow(err);
end

% we first need to call getMetadata to create a dictionary of siteIds and
% Urls - form will be cell array where each cell is a cell array of two
% items, the siteId and the main site url
if (cgiurl(end) ~= '/')
    cgiurl = strcat(cgiurl, '/');
end
siteDict = {};
siteUrl = strcat(cgiurl, 'getMetadata?fileType=5');
% now get that url
these_options = weboptions('Timeout',300, 'ContentType', 'text');
result = webread(siteUrl, these_options);

% surpress matlab warning about multibyte Characters
warning off REGEXP:multibyteCharacters

result = sprintf('%s\n', result);

% parse site result
lineMarks = regexp(result, '\n');

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

    % id
    id = str2num(thisLine(1:commaMarks(1)-1));
    % name
    name = thisLine(commaMarks(1)+1:commaMarks(2)-1);
    % url
    url = thisLine(commaMarks(2)+1:commaMarks(3)-1);
    % url2
    url2 = thisLine(commaMarks(3)+1:commaMarks(4)-1);

    % append new data
    siteDict = [ siteDict {id, strcat('http://', url, '/', url2) }];
end


% build the complete cgi url
cgiurl = strcat(cgiurl, 'getExperimentsService.py?');


% append --code options
for i = 1:length(instCodeArray)
    [temp  errmsp] = sprintf('code=%i&', instCodeArray(i));
    cgiurl = strcat(cgiurl, temp);
end

% append start time
startTimeVec = datevec(starttime);
[temp  errmsp] = sprintf('startyear=%i&', startTimeVec(1));
cgiurl = strcat(cgiurl, temp);
[temp  errmsp] = sprintf('startmonth=%i&', startTimeVec(2));
cgiurl = strcat(cgiurl, temp);
[temp  errmsp] = sprintf('startday=%i&', startTimeVec(3));
cgiurl = strcat(cgiurl, temp);
[temp  errmsp] = sprintf('starthour=%i&', startTimeVec(4));
cgiurl = strcat(cgiurl, temp);
[temp  errmsp] = sprintf('startmin=%i&', startTimeVec(5));
cgiurl = strcat(cgiurl, temp);
[temp  errmsp] = sprintf('startsec=%i&', round(startTimeVec(6)));
cgiurl = strcat(cgiurl, temp);

% append end time
endTimeVec = datevec(endtime);
[temp  errmsp] = sprintf('endyear=%i&', endTimeVec(1));
cgiurl = strcat(cgiurl, temp);
[temp  errmsp] = sprintf('endmonth=%i&', endTimeVec(2));
cgiurl = strcat(cgiurl, temp);
[temp  errmsp] = sprintf('endday=%i&', endTimeVec(3));
cgiurl = strcat(cgiurl, temp);
[temp  errmsp] = sprintf('endhour=%i&', endTimeVec(4));
cgiurl = strcat(cgiurl, temp);
[temp  errmsp] = sprintf('endmin=%i&', endTimeVec(5));
cgiurl = strcat(cgiurl, temp);
[temp  errmsp] = sprintf('endsec=%i&', round(endTimeVec(6)));
cgiurl = strcat(cgiurl, temp);

% append localFlag
if localFlag == 0
    cgiurl = strcat(cgiurl, 'local=0');
else
    cgiurl = strcat(cgiurl, 'local=1');
end

% make sure any + replaced by %2B
cgiurl = strrep(cgiurl,'+','%2B');

% now get that url
result = urlread(cgiurl);

% look for errors - if html returned, error occurred
htmlList = strfind(result, '</html>');
if (~isempty(htmlList))
    err.message = strcat('Unable to run cgi script getExperimentsWeb using cgiurl: - ', cgiurl);
    err.identifier = 'madmatlab:scriptError';
    rethrow(err);
end

result = sprintf('%s\n', result);

% parse result
lineMarks = regexp(result, '\n');
% init array to return
expArray = [];
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
    % id
    newExperiment.id = str2num(thisLine(1:commaMarks(1)-1));
    % url
    newExperiment.url = thisLine(commaMarks(1)+1:commaMarks(2)-1);
    % name
    newExperiment.name = thisLine(commaMarks(2)+1:commaMarks(3)-1);
    % siteid
    newExperiment.siteid = str2num(thisLine(commaMarks(3)+1:commaMarks(4)-1));
    % site name
    newExperiment.sitename = thisLine(commaMarks(4)+1:commaMarks(5)-1);
    % instcode
    newExperiment.instcode = str2num(thisLine(commaMarks(5)+1:commaMarks(6)-1));
    % inst name
    newExperiment.instname = thisLine(commaMarks(6)+1:commaMarks(7)-1);
    % get starttime
    % year
    year = str2num(thisLine(commaMarks(7)+1:commaMarks(8)-1));
    % month
    month = str2num(thisLine(commaMarks(8)+1:commaMarks(9)-1));
    % day
    day = str2num(thisLine(commaMarks(9)+1:commaMarks(10)-1));
    % hour
    hour = str2num(thisLine(commaMarks(10)+1:commaMarks(11)-1));
    % minute
    minute = str2num(thisLine(commaMarks(11)+1:commaMarks(12)-1));
    % second
    second = str2num(thisLine(commaMarks(12)+1:commaMarks(13)-1));
    % create starttime
    newExperiment.starttime = datenum([year month day hour minute second]);
    % get endtime
    % year
    year = str2num(thisLine(commaMarks(13)+1:commaMarks(14)-1));
    % month
    month = str2num(thisLine(commaMarks(14)+1:commaMarks(15)-1));
    % day
    day = str2num(thisLine(commaMarks(15)+1:commaMarks(16)-1));
    % hour
    hour = str2num(thisLine(commaMarks(16)+1:commaMarks(17)-1));
    % min
    minute = str2num(thisLine(commaMarks(17)+1:commaMarks(18)-1));
    % sec
    second = str2num(thisLine(commaMarks(18)+1:commaMarks(19)-1));
    % create endtime
    newExperiment.endtime = datenum([year month day hour minute second]);
    % finally, isLocal - may or may not be last
    if length(commaMarks) > 19
        newExperiment.isLocal = str2num(thisLine(commaMarks(19)+1:commaMarks(20)-1));
    else
        newExperiment.isLocal = str2num(thisLine(commaMarks(19)+1:end));
    end
    
    if (newExperiment.isLocal == 0)
        newExperiment.id = -1;
    end

    newExperiment.madrigalUrl = 'unknown';
    for i = 1:2:length(siteDict)+1
        if siteDict{i} == newExperiment.siteid
            newExperiment.madrigalUrl = siteDict{i+1};
            break
        end
    end
    
    if length(commaMarks) > 20
        newExperiment.PI = thisLine(commaMarks(20)+1:commaMarks(21)-1);
    else
        newExperiment.PI = 'Unknown';
    end
        
    if length(commaMarks) > 21
        newExperiment.PIEmail = thisLine(commaMarks(21)+1:commaMarks(22)-1);
    elseif length(commaMarks) == 21
        newExperiment.PIEmail = thisLine(commaMarks(21)+1:end-1);
    else
        newExperiment.PIEmail = 'Unknown';
    end
    
    % realUrl
    realUrl = newExperiment.url;
    realUrl = strrep(realUrl, '/madtoc/', '/madExperiment.cgi?exp=');
    title = strrep(newExperiment.name, ' ', '+');
    realUrl = strcat(realUrl, '&displayLevel=0&expTitle=', title);
    newExperiment.realUrl = realUrl;
    
    
    
    % append new experiments
    expArray = [expArray newExperiment];
    
% now sort the array based on http://blogs.mathworks.com/pick/2010/09/17/sorting-structure-arrays-based-on-fields/
expArrayFields = fieldnames(expArray);
expArrayCell = struct2cell(expArray);
sz = size(expArrayCell);
expArrayCell = reshape(expArrayCell, sz(1), []);
expArrayCell = expArrayCell';
expArrayCell = sortrows(expArrayCell, 8);
expArrayCell = reshape(expArrayCell', sz);
expArray = cell2struct(expArrayCell, expArrayFields, 1);

end



