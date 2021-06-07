function [longitude] = localtimetolongitude(lt,time)
    % convert geographic local time to geographic longitude
    
    zeroLongLocalTime = hours(timeofday(time));
    
    longitude = mod((lt - zeroLongLocalTime) * 15,360);
    longitude(longitude>=180) = longitude(longitude>=180) - 360;
    
end