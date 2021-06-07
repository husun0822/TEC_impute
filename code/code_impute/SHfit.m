%% Fit Spherical Harmonics over mask-out/no-mask-out data
% disp(1);
% args = GetCommandLineArgs();
% p = str2num(args{1});
function [] = SHfit(p)
    load('datelist_365.mat');
    date = datelist{p};

    mad = load(sprintf('%s%s%s', './madrigal_mat_SH_LT/2017/gps17', date, 'g.mat'));
    addpath(genpath("./madrigal_mat_SH_LT"));
    local_time = mlttosunfixedlon(mad.tecData.local_time);

    SH_fit = zeros(181,361,288);
    for t=1:288
        frame = mad.tecData.tec_local_time_MedianFilter(:,:,t);
        [SH, SH_rmneg, output] = SHfit_ICLS(frame,mad.tecData.latitude,local_time,11,0.1,30);
        SH_fit(:,:,t) = SH_rmneg;
    end

    save(sprintf('%s%s%s', './madrigal_mat_SH_LT/SH_2017/SH_17', date, '.mat'), 'SH_fit');
    disp(p);
end
% disp("Done!");

%%
