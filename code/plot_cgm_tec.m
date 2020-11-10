function [p,cb] = plot_cgm_tec(mlat,mlt,tec,coastmlat,coastmlt)
    % [p,cb] = plot_cgm_tec(lat,mlt,tec,coastmlat,coastmlt) plots the global TEC map
    % on CGM MLT coordinates.
    % --------------Input--------------
    % mlat - matrix of the magnetic latitude grid
    % mlt - matrix of the magnetic local time grid
    % tec - matrix of the TEC map
    % coastmlat - vector of magnetic latitudes of coastline
    % coastmlt - vector of magnetic local times of coastline
    
    % --------------Output--------------
    % p: handle of the tec plot
    % cb: handle of the colorbar
    
    % convert mlat mlt tec to double float
    mlat = double(mlat);
    mlt = double(mlt);
    tec = double(tec);
    
    % convert mlt to sun fixed longitude
    lon = mlttosunfixedlon(mlt,12);
    coastmlon = mlttosunfixedlon(coastmlt,12);
    
    % create a world map
    ax = worldmap('World');
    setm(ax,'mapprojection','pcarree');
    setm(ax,'MLabelParallel',-90);
    
    % plot tec
    p = pcolorm(mlat,lon,tec,'FaceColor','flat');hold on;
    colormap jet;
    cb = colorbar('southoutside');
    caxis([0 60]);
    
    % plot coastlines in MLT
    plotm(coastmlat,coastmlon,'k');
    
    % change longitude label to MLT
    m = mlabel("on");
    mltLabel = string(num2str([24:-3:0]'));
    mltLabel(1) = "24 MLT";
    for i=1:numel(m)
        m(i).String{2} = mltLabel(i);
    end
    
end