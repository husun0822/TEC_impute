function version = getVersion(cgiurl)
%  getVersion  	returns a a string representing the Madrigal version
%
%  inputs:  cgiurl (string) to Madrigal site cgi directory 
%      (Example: 'http://madrigal.haystack.mit.edu/cgi-bin/madrigal/') 
%      Note that method getMadrigalCgiUrl converts homepage url into cgiurl. 
%
%  output:
%    version - a atring representing the Madrigal version.
%
% Returns 2.5 if Madrigal does not contain the getVersion service
% 
%  Example:
%  version = getVersion('http://madrigal.haystack.mit.edu/cgi-bin/madrigal/')
%
% Written by Bill Rideout (brideout@haystack.mit.edu)
%  $Id: getVersion.m 5818 2016-09-23 20:08:37Z brideout $

% deal with arguments

if (nargin ~= 1)
    error('Usage: version = getVersion(cgiurl)');
end

% build the complete cgi string
cgiurl = strcat(cgiurl, 'getVersionService.py');

% make sure any + replaced by %2B
cgiurl = strrep(cgiurl,'+','%2B');

% now get that url
try
    these_options = weboptions('Timeout',300, 'ContentType', 'text');
    version = webread(cgiurl, these_options);
catch
    version = '2.5';
end
