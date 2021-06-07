function lats = magnetic_equator(lons)
    % Input longitudes, output latitudes of the magnectic equator.
    % If input is local time, call localtimetolongitude first to convert
    % local time to longitude.
    
    filename = '../data/igrfgridData.csv';
    fileID = fopen(filename);
    igrf = textscan(fileID,'%f %f %f %f %f %f %f','CommentStyle','#','Delimiter',',');
    fclose(fileID);
    
    lat = igrf{2};
    lon = igrf{3};
    inc = igrf{5};
    
    lat_eq = lat(abs(inc)<1);
    lon_eq = lon(abs(inc)<1);
    
    lon_eq_uniq = unique(lon_eq);
    lat_eq_uniq = cell2mat(arrayfun(@(i) mean(lat_eq(lon_eq == i)), ...
        lon_eq_uniq, 'UniformOutput', false));
    
    lats = interp1(lon_eq_uniq, lat_eq_uniq, lons);
end




