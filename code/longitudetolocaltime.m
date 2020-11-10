function [localTime] = longitudetolocaltime(long,time)
    % convert geographic longitude to geographic local time
    
    zeroLongLocalTime = hours(timeofday(time));
    
    localTime = mod(zeroLongLocalTime + long/15,24);
    
end