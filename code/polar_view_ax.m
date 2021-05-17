function ax = polar_view_ax(ax, hemi, tec_color_map)
    % switch a map to polar view
    
   
    axes(ax);
    colormap(ax,tec_color_map);
    %         ax.Position(2) = 0.1050;
    %         ax.Position(4) = 0.8450;
    mapProjection = 'eqdazim';
    
    if strcmp(hemi,'north')
        origin = [90 180 0];
        latitudeLimits = [10 90];
        mltLabelLocations = latitudeLimits(1);
    else
        origin = [-90 180 0];
        latitudeLimits = [-90 -10];
        mltLabelLocations = latitudeLimits(2);
        ax.XDir = 'reverse';
    end
%     longitudeLimits = [-180 180];
    
    setm(ax, 'origin', origin);
    setm(ax, 'MapProjection', mapProjection);
    setm(ax, 'MapLatLimit', latitudeLimits);
    %         setm(ax, 'MapLonLimit', longitudeLimits);
    setm(ax,'mlabelparallel',mltLabelLocations);
    setm(ax,'PLineLocation',10);
    
    caxis(ax,[0 30]);
    
    mltLabelLocations = [0,21:-3:3];
    %         lonLabelLocations = mlttofakelon(mltLabelLocations,12);
    setm(ax,'plabellocation',10);
    setm(ax,'plabelmeridian',160);
    setm(ax,'mlabellocation',45);
    
    % replace longitude labels with mlt labels
    m = mlabel('on');
    m = m(1:8);
    mltLabel = [num2str(mltLabelLocations') repmat(' LT',[numel(mltLabelLocations), 1])];
    for i = 1:numel(m)
        m(i).String = mltLabel(i, :);
    end
end