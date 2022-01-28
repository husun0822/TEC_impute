% Madrigal Toolbox
% Version 1.0.3   19-July-2004
%
%  Remote methods - can be run anywhere on the internet, from any platform
%
%   getMadrigalCgiUrl  	parse the main madrigal page to get the cgi url 
%
%   isprintWeb  	Create an isprint-like 3D array of doubles via
%                	a command similar to the isprint command-line
%                	application, but access data via the web
%		
%   getInstrumentsWeb  	returns an array of instrument structs of instruments 
%                       found on remote Madrigal server.
%			
%   getExperimentsWeb  	returns an array of experiment structs given input filter 
%   			arguments from a remote Madrigal server.
%
%
%   getCgiurlForExperiment  	returns cgiurl of experiment struct as returned 
%   				by getExperimentsWeb or getExperiments.
%
%   getExperimentFilesWeb  	returns an array of experiment file structs given 
%   				experiment id from a remote Madrigal server.
%
%   getParametersWeb  	returns an array of parameter structs given filename 
%   			from a remote Madrigal server.
%
%  madCalculatorWeb  	Create a matrix of doubles via a the Madrigal derivation engine 
%                       for a time and range of lat, long, and alt
%  
%
%        Additional methods based on the above calls
%
%  getIonosphericTerminator   returns an n x 2 array of lat, lon defining the
%                             ionospheric terminator at the given time and altitude
%
%  getGsmPoint               returns a single point in the GSM XY plane via Tsyganenko
%                            field for given time, gdlat, glon, gdalt
%
%  mapGeodeticToGsm returns a 2 x N array of GSM X and Y where a field
%                   line intersects the input points, and is followed to the GSM Z=0 plane.
%
%  mapGsmToAltitude returns a 2 x N array of geodetic lat and long where a field
%                   line intersects a given stop altitude for arrays of starting points in GSM
%                   coordinates.
%
%  getMagnetopause   returns a matrix of xgsm, ygsm points on the
%                    sun-facing side of the magnetopause
%
%  getConjagatePoint returns the magnetic conjugate lat and long for a given
%                    gdlat, glon, gdalt, along with the corrected geomagnetic lat and long of
%                    the starting point.
%
%  Local methods - run on Madrigal server, somewhat faster then remote methods 
%    Not available if you only installed the remote Matlab Madrigal API  
%
%   isprint  		Create an isprint-like 3D array of doubles via
%                	a command similar to the isprint command-line
%                	application     
%		
%   getInstruments  	returns an array of instrument structs of instruments 
%   			found on local Madrigal server.
%
%   getExperiments  	returns an array of experiments structs of instruments 
%   			given input filter arguments.
%			
%   getExperimentFiles  	returns an array of experiment file structs given experiment id.
%   
%   getParameters  	returns an array of parameter structs given madrigal filename.
%   
%   madsearchfiles  	Returns a list of comma-delimited file names
%                       found in the local Madrigal database between
%                       start time and end time.  Deprecated - use get* methods for
%			more complete searching.
%			
%  getMadroot	 	return madroot, either from environment variable, or from installed value
%
%  convert_coords	 Convert back and forth between geomagnetic and geodetic coordinates
