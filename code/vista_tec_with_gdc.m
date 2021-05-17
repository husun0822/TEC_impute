% this script create VISTA tec maps with GDC satellite trajectories

year = '2015'; % year
time_range = [datetime(2015,6,22,18,0,0), datetime(2015,6,27,3,0,0)]; % [start date, end date]
color_map = load('tec_color_map.mat'); % customized colormap
% madrigal tec directory
mad_dir = '/Users/jiaenren/Dropbox (University of Michigan)/TEC_201709/Data/Madrigal';
% vista tec directory
vista_dir = '/Users/jiaenren/Dropbox (University of Michigan)/TEC_201709/Data/VISTA_SH/VISTA/';
% gdc directory
GDC_Directory = '/Users/jiaenren/Dropbox (University of Michigan)/GDC_Ephemeris/';

%% load gdc data
addpath(GDC_Directory);
% need to make sure Phase number covers the dates given
flist = dir([GDC_Directory 'Phase_1b/*.txt']); 
for k = 1:numel(flist)
    fname = [flist(k).folder '/' flist(k).name];
    gdc.(['G' num2str(k)]).gdc_table = read_gdc_txt(fname);
    gdc.(['G' num2str(k)]).times = datetime(gdc.(['G' num2str(k)]).gdc_table.Time,...
        'InputFormat','yyyy-MM-dd/HH:mm:ss.SSS');
end
%% main loop for making plots
date_string = cellstr(datestr(dateshift(time_range(1),"start",'day'):...
    dateshift(time_range(2),"start",'day'),'mmdd'));
for j = 1:numel(date_string)
    %% load data
    date_str = date_string{j};
    % madrigal tec mat file
    mad_file = dir([mad_dir '/' year '/*' date_str '*.mat']);
    mad = load([mad_file.folder '/' mad_file.name]);
    % vista tec mat file
    im_file = dir([vista_dir '/' year '/*' date_str '*.mat']);
    im = load([im_file.folder '/' im_file.name]);
    tec_imputed_maps = im.imputed;
    %%
    for i = 1:numel(mad.tecData.time)
        
        timeStr = mad.tecData.time{i};
        time = datetime(timeStr,'InputFormat','yyyy-MM-dd/HH:mm:ss');
        
        % only make plot for the time range specified
        if time < time_range(1)
            continue
        elseif time > time_range(2)
            break
        end
        
        % madrigal data
        lat = mad.tecData.latitude;
        lon = mad.tecData.longitude;
        lt = mad.tecData.local_time;
%         tec = mad.tecData.tec_MedianFilter(:,:,i);
        tec = mad.tecData.tec(:,:,i);
        
        % imputed maps
        tec_imputed = tec_imputed_maps(:,:,i);
        
%         % SH maps
%         tec_SH = sh.SH_fit(:,:,i);
        
        % create a figure
        fig = figure('Position',[27 155 1396 800]);
        fig.PaperOrientation = 'landscape';
        
        % create nrow-by-ncol subplots
        nrow = 1;
        ncol = 3;
        [ha,pos] = tight_subplot(nrow,ncol,[0.01 0.01],0.05,0.05);
        
        % set coloar bar range for TEC map
        colorRange = [0 50];
        
        % geographic local time coordinates, tec imputed map
        n = 1;
        ha(n) = subplot(nrow,ncol,n);
        [~,cb1] = plot_lt_tec(lat,lt,tec_imputed,time);
        caxis(ha(n),colorRange);
        cb1.Position = [0.0781 0.3164 0.2371 0.0200];
        cb1.Label.String = 'Total Electron Content (TECU)';
        title({[timeStr ' UT'],'Madrigal TEC map'});
        
        % geographic local time coordinates, tec imputed map
        n = 2;
        ha(n) = subplot(nrow,ncol,n);
        [~,cb2] = plot_lt_tec(lat,lt,tec_imputed,time);
        caxis(ha(n),colorRange);
        cb2.Position = [0.5020 0.21 0.3030 0.02];
        cb2.Label.String = 'Total Electron Content (TECU)';
        title({[timeStr ' UT'],'Madrigal TEC map'});
        % convert to polar view plot
        polar_view_ax(ha(n), 'north', color_map.tec_color_map);
        
        % geographic local time coordinates, tec imputed map
        n = 3;
        ha(n) = subplot(nrow,ncol,n);
        [~,cb3] = plot_lt_tec(lat,lt,tec_imputed,time);
        delete(cb3);
        caxis(ha(n),colorRange);
        title({[timeStr ' UT'],'Madrigal TEC map'});
        % convert to polar view plot
        polar_view_ax(ha(n), 'south', color_map.tec_color_map);
        
        % adjust subplot positions produced by tight_subplot
        for k = 1:numel(ha)
            ha(k).Position = pos{k};
            colormap(ha(k),color_map.tec_color_map);
            
            % plot gdc data
            for g = 1:numel(flist)
                sate = gdc.(['G' num2str(g)]);
                time_index = find(sate.times == time);
                range = 100;
                range_index = time_index-range:time_index+range;
                sate_lat = sate.gdc_table.Lat(range_index);
                sate_lt = sate.gdc_table.LT(range_index);
                sate_sflon = mlttosunfixedlon(sate_lt,12);
                plotm(sate_lat,sate_sflon,'-','LineWidth',1.6,'Color',[0.99,0.99,0.99],'Parent',ha(k));
                scatterm(sate_lat(1+range),sate_sflon(1+range),100,'wo','LineWidth',3,...
                    'Parent',ha(k));
                textm(sate_lat(1+range),sate_sflon(1+range),[' G' num2str(g)],...
                    'Color','magenta','FontSize',15,'Parent',ha(k));
            end
        end
        
        fig.PaperType = 'A2';
        fig.Renderer = 'painters';
        
%         % save figure as ps
%         print(fig,[GDC_Directory 'vista_gdc_20161012'],'-bestfit','-dpsc','-append');
            
%         % save figure as fig
%         savefig(fig,['./fig/' strrep(timeStr,'/','-') '.fig'],'compact');

        % save figure as png
        print(fig,[GDC_Directory 'plots/vista_gdc_20150622/' datestr(time,'yyyymmdd_HHMM')],'-dpng','-r300');
        
        close(fig);
    end
end