function fig = plot_keogram_at_local_times(keogram_data, local_time, lat_range)
    % plot keogram at the local times specified
    
    stime_str = datestr(keogram_data.time_grid(1,1),'yyyymmdd');
    etime_str = datestr(keogram_data.time_grid(1,end),'yyyymmdd');
    fig = figure('Position',[62 47 1272 908]);
    if numel(local_time)==1
        [ha, ~] = tight_subplot(1,1,0.07,0.1,0.1);
    else
        [ha, ~] = tight_subplot(ceil(numel(local_time)/2),2,0.07,0.1,0.1);
    end
    color_map = load('tec_color_map.mat'); % customized colormap
    for i = 1:numel(local_time)
        lt = local_time(i);
        axes(ha(i));
        if lt > 6 && lt <=18
            color_range = [0 30];
        else
            color_range = [0 30];
        end
        plot_keogram(keogram_data.time_grid,keogram_data.lat_grid,...
            keogram_data.keogram(:,:,lt+1),color_map,'linear',color_range);
        ylim(lat_range);
        if strcmp(stime_str, etime_str)
            title({stime_str,[num2str(lt) ' LT']});
        else
            title({[stime_str ' - ' etime_str],[num2str(lt) ' LT']});
        end
        mag_eq_lat = magnetic_equator(localtimetolongitude(lt,...
            datetime(keogram_data.time_grid(1,:),'ConvertFrom','datenum')));
        hold on; plot(keogram_data.time_grid(1,:), mag_eq_lat,'k-','LineWidth',2); hold off;
    end
end

% helper function
function p = plot_keogram(X,Y,keogram,color_map,color_scale,color_range)
    % plot tec keogram
    
    if strcmp(color_scale,'log')
        scale = @log10;
    else
        scale = @(x) x;
    end
    p = pcolor(X,Y,scale(keogram));
    shading interp;
    datetick(gca,'x','HH:MM','keeplimits');
    colormap(gca, color_map.tec_color_map);
    color_ticks = [color_range(1),10:10:color_range(end)];
    caxis(gca, scale(color_range));
    cb = colorbar;cb.Label.String='VTEC (TECu)';
    cb.Ticks = scale(color_ticks);
    cb.TickLabels = cellstr(string(color_ticks));
    xlabel('UT');ylabel('Latitude');
    set(gca,'TickDir','out');
end