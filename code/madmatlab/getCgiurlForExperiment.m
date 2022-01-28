function cgiurl = getCgiurlForExperiment(experiment)
%  getCgiurlForExperiment  	returns cgiurl of experiment.url as returned by getExperimentsWeb.
%
%  inputs:  experiment struct as returned by getExperimentsWeb or getExperiments.
%
%
%  output:
%     cgiurl of experiment
%
%  Simply truncates experiment.url to remove /madtoc/<YYYY>/<inst>/<date>
% 
%  Example: If expArray is the value returned in the getExperimentsWeb example, and
%           expArray(1).url = 'http://madrigal.haystack.mit.edu/cgi-bin/madrigal/madtoc/1998/mlh/07jan98', then
%
%     getCgiurlForExperiment(expArray(1))
%
%     returns: 
%
%          'http://madrigal.haystack.mit.edu/cgi-bin/madrigal/'

% deal with arguments

if (nargin ~= 1)
    error('Usage: cgiurl = getCgiurlForExperiment(experiment struct)');
end


index = findstr(experiment.url, '/madtoc/');

if isempty(index)
    err.message = strcat('experiment url does not contain madtoc');
    err.identifier = 'madmatlab:badArguments';
    rethrow(err);
end

cgiurl = experiment.url(1:index);
