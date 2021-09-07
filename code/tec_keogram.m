% This code load vista tec data, extract and plot keograms at different
% local times, and save the extracted keogram data as .mat file.

% The input vista tec data file must include both madrigal tec and vista
% tec data. Use add_vista_to_madrigal first to create such data file.

% Jiaen Ren (jiaenren@umich.edu) 

%% specify data and output directory
tecVista_directory = '/Users/jiaenren/ionoplot/data/tec_vista';
output_data_directory = '/Users/jiaenren/ionoplot/data/vista_keogram';
output_figure_directory = '/Users/jiaenren/ionoplot/plots/vista_keogram';

%% specify dates for plotting
dates = datetime(2020,4,20):datetime(2020,4,22);
% local times with the order that they are shown in the figure subplots
local_time = [9,6,12,3,15,0,18,21];
% local_time = 12:15;
% if true, combine multiple dates of data into one file/figure; if false,
% create one file/figure for each single day given
combined = true;

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
        fig = plot_keogram_at_local_times(keogram_data, local_time);
        print(fig,'-dpng','-r300',[output_figure_directory '/' num2str(yyyymmdd(time))]);
        save([output_data_directory '/' num2str(yyyymmdd(time))], 'keogram_data');
        close(fig);
    end
end
