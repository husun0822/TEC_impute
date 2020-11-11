igs = load('../data/gps_tec15min_igs_20170908_v01.mat');
mad = load('../data/gps170908g.005.mat');
addpath(genpath('../code')); % add all folders in code to path
%% output as video
% v = VideoWriter('../tec_test','MPEG-4');
% v.FrameRate = 10;
% open(v);
%%
for i = 1:1%numel(mad.tecData.time)
    
    % madrigal data
    timeStr = mad.tecData.time{i};
    time = datetime(timeStr,'InputFormat','yyyy-MM-dd/HH:mm:ss');
    lat = mad.tecData.latitude;
    lon = mad.tecData.longitude;
    tec = mad.tecData.tec_MedianFilter(:,:,i);
    tec_CGM = mad.tecData.tec_cgm_MedianFilter(:,:,i);
    tec_CGM_SH = mad.tecData.tec_cgm_SH(:,:,i);
    mlat = mad.tecData.mlat;
    mlt = mad.tecData.mlt;
    coastmlat = mad.tecData.coastmlat(:,i);
    coastmlt = mad.tecData.coastmlt(:,i);
    
    % igs data
    % i: time index for madrigal, t: time index for igs
    % since madrigal time resolution = 5 min, igs time resolution = 15 min, 
    % 3 madrigal frames correspond to 1 igs frame
    t = ceil(i/3);
    timeStr_IGS = igs.tecData.time{t};
    time_IGS = datetime(timeStr_IGS,'InputFormat','yyyy-MM-dd/HH:mm:ss');
    lat_IGS = igs.tecData.latitude;
    lon_IGS = igs.tecData.longitude;
    tec_IGS = igs.tecData.tec(:,:,t);
    mlat_IGS = igs.tecData.mlat;
    mlt_IGS = igs.tecData.mlt;
    tec_CGM_IGS = igs.tecData.tec_cgm_MedianFilter(:,:,t);
    coastmlat_IGS = igs.tecData.coastmlat(:,t);
    coastmlt_IGS = igs.tecData.coastmlt(:,t);
    
    % create a figure
    fig = figure('Position',[27 155 1396 800]);
    fig.PaperOrientation = 'landscape';
    
    % create nrow-by-ncol subplots
    nrow = 2;
    ncol = 3;
    [ha,pos] = tight_subplot(nrow,ncol,0.01,0.05,0.05);
    
    % set coloar bar range for TEC map
    colorRange = [0 30];
    
    % geographic local time coordinates with median filter
    ha(1) = subplot(nrow,ncol,1);
    [~,cb] = plot_geo_tec(lat,lon,tec,time);
    caxis(ha(1),colorRange);
    cb.Label.String = 'Total Electron Content (TECU)';
    title({[timeStr ' UT'],'Geographic Local Time'});
    
    % cgm mlt coordinates with median filter
    ha(2) = subplot(nrow,ncol,2);
    [~,cb] = plot_cgm_tec(mlat,mlt,tec_CGM,coastmlat,coastmlt);
    caxis(ha(2),colorRange);
    cb.Label.String = 'Total Electron Content (TECU)';
    title({[timeStr ' UT'],'Geomagnetic Local Time'});
    
    % cgm mlt coordinates, spherical harmonic fitting
    ha(3) = subplot(nrow,ncol,3);
    [~,cb] = plot_cgm_tec(mlat,mlt,tec_CGM_SH,coastmlat,coastmlt);
    caxis(ha(3),colorRange);
    cb.Label.String = 'Total Electron Content (TECU)';
    title({[timeStr ' UT'],'SH fitting in Geomagnetic Local Time'});
    
    % geographic local time coordinates, IGS GIM
    ha(4) = subplot(nrow,ncol,4);
    [~,cb] = plot_geo_tec(lat_IGS,lon_IGS,tec_IGS,time_IGS);
    caxis(ha(4),colorRange);
    cb.Label.String = 'Total Electron Content (TECU)';
    title({[timeStr ' UT'],'IGS GIM in Geographic Local Time'});
    
    % cgm mlt coordinates, IGS GIM 
    ha(5) = subplot(nrow,ncol,5);
    [~,cb] = plot_cgm_tec(mlat_IGS,mlt_IGS,tec_CGM_IGS,coastmlat_IGS,coastmlt_IGS);
    caxis(ha(5),colorRange);
    cb.Label.String = 'Total Electron Content (TECU)';
    title({[timeStr ' UT'],'IGS GIM in Geomagnetic Local Time'});
    
    % cgm mlt coordinates, spherical harmonic fitting
    ha(6) = subplot(nrow,ncol,6);
    [~,cb] = plot_cgm_tec(mlat,mlt,tec_CGM_SH,coastmlat,coastmlt);
    caxis(ha(6),colorRange);
    cb.Label.String = 'Total Electron Content (TECU)';
    title({[timeStr ' UT'],'SH fitting in Geomagnetic Local Time'});
    
    % adjust subplot positions produced by tight_subplot
    for k = 1:numel(ha)
        ha(k).Position = pos{k};
    end

% % save figure as pdf
%     print(fig,'tec_maps_','-fillpage','-dpdf');
% 
% % capture figure as a video frame
%     frame = getframe(fig);
%     disp(i);
%     writeVideo(v,frame);
%     close(fig);
end