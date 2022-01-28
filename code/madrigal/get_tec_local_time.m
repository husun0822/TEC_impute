function [tec_local_time, ltGrid] = get_tec_local_time(TEC, longitude, time_strings)
    
    tec_size = size(TEC);
    tec_local_time = zeros(size(TEC));
    
    for i = 1:numel(time_strings)
        time_str = time_strings{i};
        time = datetime(time_str,'InputFormat','yyyy-MM-dd/HH:mm:ss');
        tec = TEC(:,:,i);
        lon = longitude;
        lt = longitudetolocaltime(lon,time);
        
        % create global latitude/local time grid
        latLimits = [-90 90];
        ltLimits = [0 24];
        gratSize = tec_size(1:2);
        [~, ltGrid] = meshgrat(latLimits, ltLimits, gratSize);
        
        ltGrid_12_index = find(abs(ltGrid(1,:)-12)<1e-5);
        lt_12_index = find(abs(lt(1,:)-12)==min(abs(lt(1,:)-12)));
        
        lt_shift = circshift(lt,ltGrid_12_index-lt_12_index,2);
        if min(abs(ltGrid - lt_shift),[],'all') > 1
            warning('Local time shift error larger than 1 deg.');
        end
        
        tec_local_time(:,:,i) = circshift(tec,ltGrid_12_index-lt_12_index,2);
        
%         subplot(2,1,1)
%         imagesc(tec);set(gca,'YDir','normal');colormap('jet');
%         subplot(2,1,2)
%         imagesc(tec_local_time(:,:,i));set(gca,'YDir','normal');colormap('jet');
%         drawnow;
    end
end