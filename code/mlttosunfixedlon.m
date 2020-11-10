function flon = mlttosunfixedlon(mlt,varargin)
% mlttosunfixedlon converts local time to sun-fixed longitude [-180, 180]
%   sun-fixed longitude is needed to plot using the mapping
%   toolbox, assuming a plot with longitude limits of [-180, 180]
%
%   mlttofakelon(mlt,origin) set the 0 fake geo longitude to be at
%   origin MLT, origin default to be 0 MLT
if nargin > 1
    origin = varargin{1};
else
    origin = 0;
end
flon = (mlt-origin) * 15;
flon(flon < -180) = mod(flon(flon < -180), 180);
flon(flon > 180) = mod(flon(flon > 180), -180);
end