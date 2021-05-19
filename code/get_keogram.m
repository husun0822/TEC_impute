function [keogram, time_grid, lat_grid] = get_keogram(tecData, tec_field)
    % compute the average TEC keogram for each local time
    
    local_time = tecData.local_time;
    tec = tecData.(tec_field);
    
    sub = floor(local_time(1,:));
    keogram = nan(size(tec,1),24,size(tec,3));
    
    for lt = 1:24
        keogram(:,lt,:) = mean(tec(:,sub==lt-1,:), 2, 'omitnan');
    end
    
    keogram = permute(keogram,[1 3 2]);
    
    time = datetime(tecData.time, 'InputFormat','uuuu-MM-dd/HH:mm:ss');
    lat = tecData.latitude(:,1);
    time_num = datenum(time);
    [time_grid, lat_grid] = meshgrid(time_num, lat);
end