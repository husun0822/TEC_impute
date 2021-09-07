mad_dir = '/Users/jiaenren/Dropbox (University of Michigan)/TEC_201709/Data/Madrigal';
date_file = '/Users/jiaenren/TEC_impute/data/irregular_days.csv';
irregulardays = importfile(date_file, [2, Inf]);
dates = datetime(irregulardays.year+2000,irregulardays.month,irregulardays.day);
date_strs = cellstr(datestr(dates,'yymmdd'));

for j = 13:numel(date_strs) % 9, 
    file_date_str = date_strs{j};
    file_list = dir([mad_dir '/*/*' file_date_str '*.mat']);
    load([file_list.folder '/' file_list.name]);
    % igs = load('./TEC_201709/igs_cgm_mat/gps_tec15min_igs_20170908_v01.mat');
    % igsData = igs.tecData;
    load coastlines;
    
    % colormap for dTEC map
    colors = 16;
    rg = linspace(0, 1, colors/2)';
    bg = fliplr(linspace(0, 1, colors/2))';
    blue = horzcat(rg, rg, ones(size(rg)));
    red = horzcat(ones(size(bg)), bg, bg);
    dmap = vertcat(blue, red);
    
    % mseigs = nan(96,1);
    % msesh_cgm = nan(96,1);
    msesh = nan(288,1);
    msesh_ICLS = nan(288,1);
    %% output as video
    v = VideoWriter(['../plot/SH_' file_date_str],'MPEG-4');
    v.FrameRate = 5;
    open(v);
    %%
    for i = 1:6:288 %85 %63 %52 76 77 78 92
        
        % i = 3*t-2:3*t;
        time = datetime(tecData.time{i},'InputFormat','yyyy-MM-dd/HH:mm:ss');
        
        % tecIGS = igs.tecData.tec(:,:,t);
        % latIGS = double(igsData.latitude);
        % ltlonIGS = double(mlttosunfixedlon(longitudetolocaltime(igsData.longitude,time),12));
        % lonIGS = igsData.longitude;
        
        % tec = double(tecData.tec_cgm_MedianFilter(:,:,i));
        % tec_CGM = mean(tec,3,'omitnan');
        % lat_CGM = double(tecData.mlat);
        % lon_CGM = mlttosunfixedlon(double(tecData.mlt),12);
        % coastmlat_CGM = tecData.coastmlat(:,floor(median(i)));
        % coastmlon_CGM = mlttosunfixedlon(tecData.coastmlt(:,floor(median(i))),12);
        
        order = 8;
        mu = 0.1;
        
        % [tecSH_CGM,tecSH_CGM_ICLS,output_CGM] = SHfit_ICLS(tec_CGM,lat_CGM,lon_CGM,order,mu,1);
        
        tec = double(tecData.tec_MedianFilter(:,:,i));
        tec = mean(tec,3,'omitnan');
        tec(tec>100) = nan; % quality control, max limit
        tec(tec<=0) = nan; % quality control, min limit
        lat = double(tecData.latitude);
        ltlon = mlttosunfixedlon(longitudetolocaltime(tecData.longitude,time),12);
        lon = tecData.longitude;
        coastmlat = coastlat;
        coastmlon = mlttosunfixedlon(longitudetolocaltime(coastlon,time),12);
        
        
        [tecSH,tecSH_ICLS,output] = SHfit_ICLS(tec,lat,lon,order,mu,30);
        
        % comparison
        fig = figure('Position',[1 199 1673 734],'Visible','on');
        nrow = 1; ncol = 3;
        [ha,pos] = tight_subplot(nrow,ncol,[0.01 0.01],[0.08 0.08],0.01);
        
        % axes(ha(1));
        ha(1) = subplot(nrow,ncol,1);
        plot_geo_tec(lat,lon,tec,time);
        time_str = [tecData.time{i(1)} ' - ' tecData.time{i(end)}];
        title(time_str);
        
        % ha(2) = subplot(nrow,ncol,2);
        % plot_geo_tec(latIGS,lonIGS,tecIGS,time);
        % % colorbar('off');
        % index = find(tecIGS<=0);
        % hold on;
        % scatterm(latIGS(index),ltlonIGS(index),10,'r*');
        % tecIGS_interp = interp2(igsData.latitude',igsData.longitude',tecIGS',tecData.latitude',tecData.longitude');
        % mseIGS = mean((tecIGS_interp' - tec).^2,'all','omitnan');
        % title({['MSE IGS= ' num2str(mseIGS)],igsData.time{t}});
        
        ha(2) = subplot(nrow,ncol,2);
        plot_geo_tec(lat,lon,tecSH_ICLS,time);
        % colorbar('off');
        index = find(tecSH_ICLS<=0);
        hold on;
        scatterm(lat(index),ltlon(index),10,'r*');
        mseSH_ICLS = mean((tecSH_ICLS - tec).^2,'all','omitnan');
        title({['Order = ' num2str(order) ' \mu = ' num2str(mu)],...
            ['MSE SH = ' num2str(mseSH_ICLS)]});
        
        ha(3) = subplot(nrow,ncol,3);
        plot_geo_tec(lat,lon,tecSH,time);
        % colorbar('off');
        index = find(tecSH<=0);
        hold on;
        scatterm(lat(index),ltlon(index),10,'r*');
        mseSH = mean((tecSH - tec).^2,'all','omitnan');
        title({['Order = ' num2str(order) ' \mu = ' num2str(mu)],...
            ['MSE SH = ' num2str(mseSH)]});
        
        % ha(4) = subplot(nrow,ncol,4);
        % plot_cgm_tec(lat_CGM,lon_CGM,tecSH_CGM_ICLS,coastmlat_CGM,coastmlon_CGM);
        % % colorbar('off');
        % index = find(tecSH_CGM_ICLS<=0);
        % hold on;
        % scatterm(lat_CGM(index),lon_CGM(index),10,'r*');
        % mseSH_CGM = mean((tecSH_CGM_ICLS - tec_CGM).^2,'all','omitnan');
        % title({['Order = ' num2str(order) ' \mu = ' num2str(mu)],...
        %     ['MSE SH = ' num2str(mseSH_CGM)]});
        
        % % axes(ha(5));
        % ha(5) = subplot(nrow,ncol,5);
        % plot_cgm_tec(lat_CGM,lon_CGM,tec_CGM,coastmlat_CGM,coastmlon_CGM);
        % time_str = [tecData.time{i(1)} ' - ' tecData.time{i(end)}];
        % title(time_str);
        %
        % % axes(ha(6));
        % ha(6) = subplot(nrow,ncol,6);
        % plot_cgm_tec(lat,lon,tecIGS_interp'-tec,coastmlat,coastmlon);
        % % colorbar('off');
        % title({['MSE IGS= ' num2str(mseIGS)],igsData.time{t}});
        %
        % % axes(ha(7));
        % ha(8) = subplot(nrow,ncol,8);
        % plot_cgm_tec(lat_CGM,lon_CGM,tecSH_CGM_ICLS-tec_CGM,coastmlat_CGM,coastmlon_CGM);
        % % colorbar('off');
        % mseSH_CGM = mean((tecSH_CGM_ICLS - tec_CGM).^2,'all','omitnan');
        % title({['Order = ' num2str(order) ' \mu = ' num2str(mu)],...
        %     ['MSE SH = ' num2str(mseSH_CGM)]});
        %
        % % axes(ha(8));
        % ha(7) = subplot(nrow,ncol,7);
        % plot_cgm_tec(lat,lon,tecSH_ICLS-tec,coastmlat,coastmlon);
        % % colorbar('off');
        % mseSH = mean((tecSH_ICLS - tec).^2,'all','omitnan');
        % title({['Order = ' num2str(order) ' \mu = ' num2str(mu)],...
        %     ['MSE SH = ' num2str(mseSH)]});
        
        % mseigs(t) = mseIGS;
        % msesh_cgm(t) = mseSH_CGM;
        msesh(i) = mseSH;
        msesh_ICLS(i) = mseSH_ICLS;
        
        % for m = 6:8
        % caxis(ha(m),[-16,16]);
        % colormap(ha(m),dmap);
        % setm(ha(m),'FFaceColor',[0.8 0.8 0.8]);
        % end
        
        for m = 1:numel(ha)
            ha(m).Position = pos{m};
            ha(m).ColorScale = 'log';
            caxis(ha(m), [5 60]);
        end
        
        frame = getframe(fig);
        disp(time);
        writeVideo(v,frame);
        close(fig);
    end
    close(v);
end
%%
% scatter(msesh,msesh_cgm);hold on;
% plot([0,16],[0,16]);
% xlabel('MSE SH GEO'); ylabel('MSE SH CGM');
% %%
% scatter(msesh,mseigs);hold on;
% plot([0,16],[0,16]);
% xlabel('MSE SH GEO'); ylabel('MSE SH IGS');
