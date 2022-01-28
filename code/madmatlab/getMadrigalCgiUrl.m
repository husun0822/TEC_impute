function cgiUrl = getMadrigalCgiUrl(url)
%  getMadrigalCgiUrl  	parse the main madrigal page to get the cgi url
% 
%  With Madrigal 3, this method simply returns the original url.
%
%  input: url to Madrigal
%
%  output: cgi url for that Madrigal Site
%
%  Note: parses the homepage for the accessData link

% get main page
if url(end) ~= '/'
    result = findstr(url, 'index.html');
    if length(result) == 0
        url = strcat(url,'/');
    end
end
these_options = weboptions('Timeout',300, 'ContentType', 'text');
pagedata = webread(url, these_options);

% get host name
if strncmp(url,'http:',5), url=url(6:end); end
if strncmp(url,'//',2),    url=url(3:end); end
[host,page]=strtok(url,'/');
[host,port]=strtok(host,':');

index1 = regexp(pagedata, '[^"]*accessData.cgi');
% check for error
if length(index1) == 0
    err.message = 'No Madrigal home page found at given url';
    err.identifier = 'madmatlab:badArguments';
    rethrow(err);
end
index2 = regexp(pagedata, 'accessData.cgi');
cgiUrl = strcat('http://', host, port, pagedata(index1:index2-1));
