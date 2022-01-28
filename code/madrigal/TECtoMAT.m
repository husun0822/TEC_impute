%% add necessary functions to path
addpath(genpath('../madmatlab'));
%% download Madrigal TEC data to home directory
% set home directory to save the downloaded data (need to use escape characters for wget)
home_dir = '/Users/jiaenren/Dropbox\ \(University\ of\ Michigan\)/TEC_201709/Data/Madrigal';
home_dir_no_esc = strrep(home_dir,'\',''); % home directory with no \
tec_dir = [home_dir '/hdf5']; % directory to save the original TEC data
tec_dir_no_esc = strrep(tec_dir,'\','');
for i = 2018:2018
    year = num2str(i);
    downloadtec(year, tec_dir, false);
end
%% process original hdf5 file and save as mat file
for i = 2018:2018
    year = num2str(i);
    file = 'gps*.hdf5';
    % set the directory to save the output mat files
    out_dir = [home_dir_no_esc '/mat_dtec/' year];
    if ~isfolder(out_dir)
        mkdir(out_dir);
    end
    file_list = dir([tec_dir_no_esc '/' year '/' file]);
    for j = 1:numel(file_list) % error (2012,j=48)
        fname = file_list(j).name;
        folder = file_list(j).folder;
        disp(fname);
        TECh5toMAT(fname, folder, out_dir);
    end
end