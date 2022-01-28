function record = madCalculatorWeb(cgiUrl, ...
                                   time, ...
                                   startLat, ...
                                   endLat, ...
                                   stepLat, ...
                                   startLong, ...
                                   endLong, ...
                                   stepLong, ... 
                                   startAlt, ...
                                   endAlt, ...
                                   stepAlt, ...
                                   parms)
%  madCalculatorWeb  	Create a matrix of doubles via a the Madrigal derivation engine for a time and range of lat, long, and alt
%  
%  The calling syntax is:
%  
%  		[record] = madCalculatorWeb(cgiurl, time, startLat, endLat, stepLat, startLong, endLong, stepLong, 
%                                   startAlt, endAlt, stepAlt, parms)
%  
%   where 
%
%     cgiurl (string) to Madrigal site cgi directory that has that
%      filename.
%        (Example: 'http://madrigal.haystack.mit.edu/cgi-bin/madrigal/') 
%         Note that method getMadrigalCgiUrl converts homepage url into cgiurl.
%  
%     time - Matlab datenum double (must be UTC)	7. startLat - Starting geodetic latitude, -90 to 90 (required)
%     
%     endLat - Ending geodetic latitude, -90 to 90 (required)
%     
%     stepLat - Latitude step (0.1 to 90) (required)
%     
%     startLong - Starting geodetic longitude, -180 to 180 (required)
%     
%     endLong - Ending geodetic longitude, -180 to 180 (required)
%     
%     stepLong - Longitude step (0.1 to 180) (required)
%     
%     startAlt - Starting geodetic altitude, >= 0 (required)
%     
%     endAlt - Ending geodetic altitude, > 0 (required)
%     
%     stepAlt - Altitude step (>= 0.1) (required)
%  
%     parms is the desired parameters in the form of a comma-delimited
%         string of Madrigal mnemonics (example = 'gdlat,ti,dti')
%  
%
%     The returned record is a matrix of doubles with the dimensions:
%
%         [(num lat steps * num long steps * num alt steps), 3 + num of parms]
%
%     The first three columns will always be lat, long, and alt, so there are three
%     additional columns to the number of parameters requested via the parms argument.
%
%     If error or no data returned, will return error explanation string instead.
%
%     Example: result = madCalculatorWeb('http:/grail.haystack.mit.edu/cgi-bin/madrigal', ...
%                                         now,45,55,5,45,55,5,200,300,50,'bmag,bn');

% deal with arguments

Usage = '[record] = madCalculatorWeb(cgiurl, time, startLat, endLat, stepLat, startLong, endLong, stepLong, startAlt, endAlt, stepAlt, parms)';

if (nargin ~= 12)
    error(Usage);
end

% be sure cgiUrl ends with /
if ~strcmp(cgiUrl(end), '/')
    cgiUrl = strcat(cgiUrl, '/');
end

% get datevec
dateList = datevec(time);

% build the complete cgi string, replacing characters as required by cgi standard
cgiUrl = strcat(cgiUrl, 'madCalculatorService.py?year=');
cgiUrl = strcat(cgiUrl, num2str(dateList(1)));
cgiUrl = strcat(cgiUrl, '&month=');
cgiUrl = strcat(cgiUrl, num2str(dateList(2)));
cgiUrl = strcat(cgiUrl, '&day=');
cgiUrl = strcat(cgiUrl, num2str(dateList(3)));
cgiUrl = strcat(cgiUrl, '&hour=');
cgiUrl = strcat(cgiUrl, num2str(dateList(4)));
cgiUrl = strcat(cgiUrl, '&min=');
cgiUrl = strcat(cgiUrl, num2str(dateList(5)));
cgiUrl = strcat(cgiUrl, '&sec=');
cgiUrl = strcat(cgiUrl, num2str(round(dateList(6))));
cgiUrl = strcat(cgiUrl, '&startLat=');
cgiUrl = strcat(cgiUrl, num2str(startLat));
cgiUrl = strcat(cgiUrl, '&endLat=');
cgiUrl = strcat(cgiUrl, num2str(endLat));
cgiUrl = strcat(cgiUrl, '&stepLat=');
cgiUrl = strcat(cgiUrl, num2str(stepLat));
cgiUrl = strcat(cgiUrl, '&startLong=');
cgiUrl = strcat(cgiUrl, num2str(startLong));
cgiUrl = strcat(cgiUrl, '&endLong=');
cgiUrl = strcat(cgiUrl, num2str(endLong));
cgiUrl = strcat(cgiUrl, '&stepLong=');
cgiUrl = strcat(cgiUrl, num2str(stepLong));
cgiUrl = strcat(cgiUrl, '&startAlt=');
cgiUrl = strcat(cgiUrl, num2str(startAlt));
cgiUrl = strcat(cgiUrl, '&endAlt=');
cgiUrl = strcat(cgiUrl, num2str(endAlt));
cgiUrl = strcat(cgiUrl, '&stepAlt=');
cgiUrl = strcat(cgiUrl, num2str(stepAlt));
cgiUrl = strcat(cgiUrl, '&parms=');
cgiUrl = strcat(cgiUrl, parms);

% make sure any + replaced by %2B
cgiUrl = strrep(cgiUrl,'+','%2B');

% now get that url
these_options = weboptions('Timeout',300, 'ContentType', 'text');
text = webread(cgiUrl, these_options);

% look for errors 
htmlList = findstr(text, 'Error');
if (~isempty(htmlList))
    err.message = strcat('Unable to run madCalculatorWeb - error is ', text);
    err.identifier = 'madmatlab:scriptError';
    rethrow(err);
end

% look for errors - if "****" returned, error occurred
errList = findstr(text, '****');
if (~isempty(errList))
    err.message = strcat('Unable to run madCalculatorWeb - error is ', text);
    err.identifier = 'madmatlab:scriptError';
    rethrow(err);
end


% now parse the output into a matrix

% the first parse is simply to get dimensions

% get numParms
if length(parms) < 2
    err.message = strcat('parms cannot be empty string');
    err.identifier = 'madmatlab:badArguments';
    rethrow(err);
end

commaMarks = regexp(parms, ',');
numParms = length(commaMarks) + 4; % since 3 extra columns = lat, long, alt

% get all new lines
lineMarks = regexp(text, '\n');
numRows = length(lineMarks);


% create the matrix
record = zeros(numRows, numParms);
records(:,:) = nan;

% the next parse is to populate records
% get all new lines
lineMarks = regexp(text, '\n');
presentStart = 1;
this2D = 0;
thisParm = 0;
isNew2D = 1;
for line=1:length(lineMarks)
    % get next line
    newLine = text(presentStart:lineMarks(line));
    presentStart = lineMarks(line) + 1;
    if length(newLine) < 2
       % ignore first empty line
       continue;
    end
   
    % now loop through each token
    tokenList = regexp(newLine, ' ');
    presentTokenStart = 1;
    foundFirstToken = 0;
    thisParm = 1;
    for i = 1:length(tokenList)+1
        if i == length(tokenList)+1
            token = newLine(presentTokenStart:end-1);
        else    
            token = newLine(presentTokenStart:tokenList(i)-1);
            presentTokenStart = tokenList(i) + 1;
        end
        if length(token) < 2
            continue;
        end
        % check if its a double
        newDouble = str2double(token);
        % check if its missing
        if strcmp(token, 'missing')
            newDouble = nan;
        end
        % check if its assumed
        if strcmp(token, 'assumed')
            newDouble = nan;
        end
        % check if its knownbad
        if strcmp(token, 'knownbad')
           newDouble = nan;
        end
        % increment this2D if first
        if foundFirstToken == 0
            this2D = this2D + 1;
            foundFirstToken = 1;
        end
        record(this2D, thisParm) = newDouble;
        thisParm = thisParm + 1;
    end
    
   
   
end
