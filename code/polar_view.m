function fig = polar_view(fig, tec_color_map)
    axis1 = findall(fig,'Type','Axes','-not','Type','AxesToolbar');
    for j = 4:numel(axis1)
        ax = axis1(j);
        
        axes(ax);
        colormap(ax,tec_color_map);
        %         ax.Position(2) = 0.1050;
        %         ax.Position(4) = 0.8450;
        
        origin = [90 180 0];
        mapProjection = 'eqdazim';
        latitudeLimits = [10 90];
        %         longitudeLimits = [-180 180];
        mltLabelLocations = latitudeLimits(1);
        
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
end