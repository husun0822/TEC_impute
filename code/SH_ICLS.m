load('./TEC_201709/madrigal_mat_SH/gps170908g.005.mat');
igs = load('./TEC_201709/igs_cgm_mat/gps_tec15min_igs_20170908_v01.mat');
igsData = igs.tecData;
load coastlines;

% colormap for dTEC map
colors = 16;
rg = linspace(0, 1, colors/2)';
bg = fliplr(linspace(0, 1, colors/2))';
blue = horzcat(rg, rg, ones(size(rg)));
red = horzcat(ones(size(bg)), bg, bg);
dmap = vertcat(blue, red);

mseigs = nan(96,1);
% msesh_cgm = nan(96,1);
msesh = nan(96,1);
%% output as video
v = VideoWriter('./SH fit/tec_ICLS_170908_geo_test','MPEG-4');
v.FrameRate = 5;
open(v);
%%
for t = 77:77 %85 %63 %52 76 77 78 92

i = 3*t-2:3*t;
time = datetime(tecData.time{i(2)},'InputFormat','yyyy-MM-dd/HH:mm:ss');

tecIGS = igs.tecData.tec(:,:,t);
latIGS = double(igsData.latitude);
ltlonIGS = double(mlttosunfixedlon(longitudetolocaltime(igsData.longitude,time),12));
lonIGS = igsData.longitude;

tec = double(tecData.tec_cgm_MedianFilter(:,:,i));
tec_CGM = mean(tec,3,'omitnan');
lat_CGM = double(tecData.mlat);
lon_CGM = mlttosunfixedlon(double(tecData.mlt),12);
coastmlat_CGM = tecData.coastmlat(:,floor(median(i)));
coastmlon_CGM = mlttosunfixedlon(tecData.coastmlt(:,floor(median(i))),12);

order = 11;
mu = 0.1;

% [tecSH_CGM,tecSH_CGM_ICLS,output_CGM] = SHfit_ICLS(tec_CGM,lat_CGM,lon_CGM,order,mu,1);

tec = double(tecData.tec_MedianFilter(:,:,i));
tec = mean(tec,3,'omitnan');
lat = double(tecData.latitude);
ltlon = mlttosunfixedlon(longitudetolocaltime(tecData.longitude,time),12);
lon = tecData.longitude;
coastmlat = coastlat;
coastmlon = mlttosunfixedlon(longitudetolocaltime(coastlon,time),12);


[tecSH,tecSH_ICLS,output] = SHfit_ICLS(tec,lat,lon,order,mu,30);

% comparison
fig = figure('Position',[1 199 1673 734],'Visible','on');
nrow = 1; ncol = 4;
[ha,pos] = tight_subplot(nrow,ncol,[0.01 0.01],[0.08 0.08],0.01);

% axes(ha(1));
ha(1) = subplot(nrow,ncol,1);
plot_geo_tec(lat,lon,tec,time);
time_str = [tecData.time{i(1)} ' - ' tecData.time{i(end)}];
title(time_str);

% axes(ha(2));
ha(2) = subplot(nrow,ncol,2);
plot_geo_tec(latIGS,lonIGS,tecIGS,time);
% colorbar('off');
index = find(tecIGS<=0);
hold on;
scatterm(latIGS(index),ltlonIGS(index),10,'r*');
tecIGS_interp = interp2(igsData.latitude',igsData.longitude',tecIGS',tecData.latitude',tecData.longitude');
mseIGS = mean((tecIGS_interp' - tec).^2,'all','omitnan');
title({['MSE IGS= ' num2str(mseIGS)],igsData.time{t}});

ha(3) = subplot(nrow,ncol,3);
plot_geo_tec(lat,lon,tecSH_ICLS,time);
% colorbar('off');
index = find(tecSH_ICLS<=0);
hold on;
scatterm(lat(index),ltlon(index),10,'r*');
mseSH = mean((tecSH_ICLS - tec).^2,'all','omitnan');
title({['Order = ' num2str(order) ' \mu = ' num2str(mu)],...
    ['MSE SH = ' num2str(mseSH)]});

ha(4) = subplot(nrow,ncol,4);
plot_geo_tec(lat,lon,tecSH,time);
% colorbar('off');
index = find(tecSH<=0);
hold on;
scatterm(lat(index),ltlon(index),10,'r*');
mseSH = mean((tecSH_ICLS - tec).^2,'all','omitnan');
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

mseigs(t) = mseIGS;
% msesh_cgm(t) = mseSH_CGM;
msesh(t) = mseSH;

% for m = 6:8
% caxis(ha(m),[-16,16]);
% colormap(ha(m),dmap);
% setm(ha(m),'FFaceColor',[0.8 0.8 0.8]);
% end

for m = 1:numel(ha)
ha(m).Position = pos{m};
end

% frame = getframe(fig);
% disp(t);
% writeVideo(v,frame);
% close(fig);
end
% close(v);
%%
scatter(msesh,msesh_cgm);hold on;
plot([0,16],[0,16]);
xlabel('MSE SH GEO'); ylabel('MSE SH CGM');
%%
scatter(msesh,mseigs);hold on;
plot([0,16],[0,16]);
xlabel('MSE SH GEO'); ylabel('MSE SH IGS');
