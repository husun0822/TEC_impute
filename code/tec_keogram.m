% This code load vista tec data, extract and plot keograms at different
% local times, and save the extracted keogram data as .mat file.

% The input vista tec data files must be in .mat format.

% Jiaen Ren (jiaenren@umich.edu) 

%% specify data and output directory
tecVista_directory = '/Users/jiaenren/Dropbox (University of Michigan)/TEC_201709/Data/VISTA_SH/VISTA';
output_data_directory = '/Users/jiaenren/ionoplot/data/vista_keogram';
output_figure_directory = '/Users/jiaenren/ionoplot/plots/vista_keogram';

%% specify dates for plotting
dates = datetime(2016,3,6):datetime(2016,3,7);
% local times with the order that they are shown in the figure subplots
local_time = [9,6,12,3,15,0,18,21];
% local_time = 12:15;
% if true, combine multiple dates of data into one file/figure; if false,
% create one file/figure for each single day given
combined = false;

%%
if combined
    % extract keogram data farom vista tec map
    keogram_data = get_keograms_at_time(tecVista_directory, dates);
    % make keogram plot for each local time specified
    fig = plot_keogram_at_local_times(keogram_data, local_time, [-90,90]);
    output_name = [num2str(yyyymmdd(dates(1))) '-' num2str(yyyymmdd(dates(end)))];
    % save figure as png
    %     print(fig,'-dpng','-r300',[output_figure_directory '/' output_name]);
    fig.PaperType = 'a2';
    fig.PaperOrientation='landscape';
    print(fig,'-dpdf','-fillpage',[output_figure_directory '/' output_name]);
    % save keogram data
    save([output_data_directory '/' output_name], 'keogram_data');
    close(fig);
else
    % apply the same procedure above but for each single day
    for time = dates
        keogram_data = get_keograms_at_time(tecVista_directory, time);
        if isempty(keogram_data.keogram)
            continue
        end
        fig = plot_keogram_at_local_times(keogram_data, local_time, [-90, 90]);
        print(fig,'-dpng','-r300',[output_figure_directory '/' num2str(yyyymmdd(time))]);
        save([output_data_directory '/' num2str(yyyymmdd(time))], 'keogram_data');
        close(fig);
    end
end
