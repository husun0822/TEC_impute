%% specify path and dates

% figure output folder
% plot_foler = '/Users/jiaenren/ionoplot/plots/vista/';
plot_foler = '/Users/jiaenren/Dropbox (University of Michigan)/TEC_201709/plots/vista/';

% madrigal data path
mad_dir = '/Users/jiaenren/Dropbox (University of Michigan)/TEC_201709/Data/Madrigal/mat';

% SH data path
sh_dir = '/Users/jiaenren/Dropbox (University of Michigan)/TEC_201709/Data/VISTA_SH/SH/low_order';

% vista data path
vista_dir = '/Users/jiaenren/Dropbox (University of Michigan)/TEC_201709/Data/VISTA_SH/VISTA/VISTA/low_order';

% year and date for the plots, make sure the data paths have the data
% needed for the year and date given
year = 2018;
% either specify several dates
date_string = {'180826'};
% or make plots for every day in the year
% date_string = cellstr(datestr(datetime(year,1,1):datetime(year,12,31), 'yymmdd'));

% only make plots within a specific time interval
time_range = [datetime(year,1,1,0,0,0), datetime(year,12,31,23,59,59)];
% time_range = [datetime(year,9,7,23,50,0), datetime(year,9,8,0,10,0)];

% load customized color map
color_map = load('tec_color_map.mat');

%% uncomment this block and other related codes if you want the output plots as video
% v = VideoWriter(['vista_tec_' num2str(year)],'MPEG-4');
% v.FrameRate = 10;
% open(v);

%% loop through each day
for j = 1:numel(date_string)
    date_str = date_string{j};
    
    % load data files for the day
    vista_file = dir([vista_dir '/*/*' date_str '*.mat']);
    if isempty(vista_file)
        error(['VISTA data not found for ' date_str]);
    end
    vista = load([vista_file.folder '/' vista_file.name]);
    tec_imputed_maps = vista.imputed;
    
    mad_file = dir([mad_dir '/*/*' date_str '*.mat']);
    if isempty(mad_file)
        error(['Madrigal data not found for ' date_str]);
    end
    mad = load([mad_file.folder '/' mad_file.name]);
    
    sh_file = dir([sh_dir '/*/*' date_str '*.mat']);
    if isempty(sh_file)
        error(['SH data not found for ' date_str]);
    end
    sh = load([sh_file.folder '/' sh_file.name]);
    
    %% make plots for each time step
    for i = 1:numel(mad.tecData.time)
        
        % current datetime
        timeStr = mad.tecData.time{i};
        time = datetime(timeStr,'InputFormat','yyyy-MM-dd/HH:mm:ss');
        
        % set figure output path
        plot_path = [plot_foler '/' num2str(year) '/' date_str];
        if ~exist(plot_path,'dir')
            mkdir(plot_path)
        end
        
        % set figure name
        time_str = strsplit(timeStr, '/');
        fig_name = strrep(time_str{2},':','-');
        
        % skip if plot file already exists
        if exist([plot_path '/' fig_name '.png'],'file')
            continue
        end
        
        % only make plots within the time interval
        if time < time_range(1)
            continue
        elseif time > time_range(2)
            break
        end
        
        % madrigal data
        lat = mad.tecData.latitude;
        lon = mad.tecData.longitude;
        lt = mad.tecData.local_time; % local time grid for vista maps
        tec = mad.tecData.tec_MedianFilter(:,:,i);
        
        % imputed maps
        tec_imputed = tec_imputed_maps(:,:,i);
        
        % SH maps
        tec_SH = sh.SH_fit(:,:,i);
        
        % create a figure
        fig = figure('Position',[27 155 1396 800], 'Renderer','painters');
        fig.PaperOrientation = 'landscape';
        
        % create nrow-by-ncol subplots
        nrow = 2;
        ncol = 3;
        [ha,pos] = tight_subplot(nrow,ncol,[0.01 0.01],0.05,0.05);
        
        % set coloar bar range for TEC map
        colorRange = [0 40];
        
        % geographic local time coordinates with median filter
        n = 1;
        ha(n) = subplot(nrow,ncol,n);
        [~,cb] = plot_geo_tec(lat,lon,tec,time);
        caxis(ha(n),colorRange);
        cb.Label.String = 'Total Electron Content (TECU)';
        title({[timeStr ' UT'],'Madrigal TEC map'});
        
        % geographic local time coordinates, SH fit
        n = 2;
        ha(n) = subplot(nrow,ncol,n);
        [~,cb] = plot_lt_tec(lat,lt,tec_SH,time);
        caxis(ha(n),colorRange);
        cb.Label.String = 'Total Electron Content (TECU)';
        title({[timeStr ' UT'],'SH fit'});
        
        % geographic local time coordinates, tec imputed map
        n = 3;
        ha(n) = subplot(nrow,ncol,n);
        [~,cb] = plot_lt_tec(lat,lt,tec_imputed,time);
        caxis(ha(n),colorRange);
        cb.Label.String = 'Total Electron Content (TECU)';
        title({[timeStr ' UT'],'Imputed TEC map'});
        
        % geographic local time coordinates with median filter
        n = 4;
        ha(n) = subplot(nrow,ncol,n);
        [~,cb] = plot_geo_tec(lat,lon,tec,time);
        caxis(ha(n),colorRange);
        cb.Label.String = 'Total Electron Content (TECU)';
%         title({[timeStr ' UT'],'Madrigal TEC map'});
        
        % geographic local time coordinates, SH fit
        n = 5;
        ha(n) = subplot(nrow,ncol,n);
        [~,cb] = plot_lt_tec(lat,lt,tec_SH,time);
        caxis(ha(n),colorRange);
        cb.Label.String = 'Total Electron Content (TECU)';
%         title({[timeStr ' UT'],'SH fit'});
        
        % geographic local time coordinates, tec imputed map
        n = 6;
        ha(n) = subplot(nrow,ncol,n);
        [~,cb] = plot_lt_tec(lat,lt,tec_imputed,time);
        caxis(ha(n),colorRange);
        cb.Label.String = 'Total Electron Content (TECU)';
%         title({[timeStr ' UT'],'Imputed TEC map'});
        
        % to polar view
        color_map = load('tec_color_map.mat');
        fig = polar_view(fig,color_map.tec_color_map);
        
        % adjust subplot positions produced by tight_subplot         
        for k = 1:numel(ha)
            colormap(ha(k),color_map.tec_color_map);
            ha(k).Position = pos{k};
        end
        
        cbs = findall(fig,'Type','ColorBar');
        for k = 1:ncol
            cbs(k+ncol).Position(1) = cbs(k).Position(1);
            cbs(k+ncol).Position(3) = cbs(k).Position(3);
        end
        
        fig.PaperType = 'A2';
        % save figure as png
        print(fig, [plot_path '/' fig_name], '-dpng');
        % save figure as a single ps file
%         print(fig,'vista_tec_20170528','-bestfit','-dpsc','-append');
        % save fig as fig
%         savefig(fig,['./fig/' strrep(timeStr,'/','-') '.fig'],'compact');
        
%         % uncomment this block to capture figure as a video frame
%         frame = getframe(fig);
%         disp(i);
%         writeVideo(v,frame);

        close(fig);
    end
end
% close(v);
