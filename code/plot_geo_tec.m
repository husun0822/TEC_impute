function [p,cb] = plot_geo_tec(lat,lon,tec,time)
    % [p,cb] = plot_geo_tec(lat,lon,tec,time) plots the global TEC map
    % geographic (GEO) coordinates on GEO local time coordinates.
    % --------------Input--------------
    % lat - matrix of the latitude grid
    % lon - matrix of the longitude grid
    % tec - matrix of the TEC map
    % time - datetime of the current map used for local time conversion
    
    % --------------Output--------------
    % p: handle of the tec plot
    % cb: handle of the colorbar
    
    % get coastlines
    load coastlines;
    
    % convert lat lon tec to double float
    lat = double(lat);
    lon = double(lon);
    tec = double(tec);
    
    % convert longitude to local time
    lt = longitudetolocaltime(lon,time);
    coastlt = longitudetolocaltime(coastlon,time);
    
    % convert local time to sun fixed longitude
    sflon = mlttosunfixedlon(lt,12);
    coastsflon = mlttosunfixedlon(coastlt,12);
    
    % copy a column of -180 deg longitude as 180 deg longitude
    index = find(sflon(1,:) == -180);
    if ~isempty(index)
        sflon = horzcat(sflon(:,1:index),sflon(:,index:end));
        lat = horzcat(lat(:,1:index),lat(:,index:end));
        tec = horzcat(tec(:,1:index),tec(:,index:end));
        sflon(:,index) = 180;
    end
    
    % create a world map
    ax = worldmap('World');
    setm(ax,'mapprojection','pcarree');
    setm(ax,'MLabelParallel',-90);
    
    % plot tec
    p = pcolorm(lat,sflon,tec,'FaceColor','flat');hold on;
    colormap jet;
    cb = colorbar('southoutside');
    caxis([0 60]);
    
    % plot coastlines in MLT
    plotm(coastlat,coastsflon,'k');
    
    % change longitude label to local time
    m = mlabel("on");
    mltLabel = string(num2str([24:-3:0]'));
    mltLabel(1) = "24 LT";
    for i=1:numel(m)
        m(i).String{2} = mltLabel(i);
    end
    
end