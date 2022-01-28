function result = compareVersions(ver1, ver2)
%  compareVersions returns -1 if ver1 < ver2, 0 if equal, 1 if ver1 > ver2
%
%  Inputs: version number strings, in form number dot number (any number of dots)
%
% Written by Bill Rideout (brideout@haystack.mit.edu)
% $Id: compareVersions.m 3605 2011-09-21 19:59:14Z brideout $

% deal with arguments

if (nargin ~= 2)
    error('Usage: result = compareVersions(ver1, ver2)');
end

ver1List = regexp(ver1, '\.', 'split');
ver2List = regexp(ver2, '\.', 'split');

index = 0;
while(1)
    if ((length(ver1List) < (index + 1)) & (length(ver2List) >= (index + 1)))
        result = -1;
        return;
    elseif ((length(ver1List) >= (index + 1)) & (length(ver2List) < (index + 1)))
        result = 1;
        return;
    elseif ((length(ver1List) < (index + 1)) & (length(ver2List) < (index + 1)))
        result = 0;
        return;
    end

    ver1Str = ver1List{index+1};
    ver2Str = ver2List{index+1};
    verNum1 = str2num(ver1Str);
    verNum2 = str2num(ver2Str);
    if (verNum1 < verNum2)
        result = -1;
        return;
    elseif (verNum1 > verNum2)
        result = 1;
        return;
    end
    index = index + 1;
    
end