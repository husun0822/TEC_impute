print('in matlab')
%% Fit Spherical Harmonics over mask-out/no-mask-out data
%%%%  Initialize the Umich Cluster profiles
setupUmichClusters
print('setup successed')
%%%%  We get from the environment the number of processors
p = str2num(getenv('SLURM_NTASKS'));
% args = GetCommandLineArgs();
% p = str2num(args{1});

if p < 10
    date = sprintf('%s%d','090',p);
else
    date = sprintf('%s%d','09',p);
end
    
mad = load(sprintf('%s%s%s', './madrigal_mat_SH_LT/mask/TEC_', date, '_mask.mat'));
addpath(genpath("./madrigal_mat_SH_LT"));
local_time = mlttosunfixedlon(mad.local_time);

SH_fit = zeros(181,361,288);
for t=1:288
    frame = mad.tec_mask(:,:,t);
    [SH, SH_rmneg, output] = SHfit_ICLS(frame,mad.latitude,local_time,11,0.1,30);
    SH_fit(:,:,t) = SH_rmneg;
end
% disp("Done!");

%%
save(sprintf('%s%s%s', './madrigal_mat_SH_LT/SH/SH_', date, '.mat'), 'SH_fit');
