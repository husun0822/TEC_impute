%% Fit Spherical Harmonics over mask-out/no-mask-out data
mad = load('./data-path-mask-out/');
addpath(genpath("./code-path-to-SHfit_ICLS/"));
local_time = mlttosunfixedlon(local_time);

SH_fit = zeros(181,361,288);
for t=1:288
    frame = tec_mask(:,:,t);
    [SH, SH_rmneg, output] = SHfit_ICLS(frame,latitude,local_time,11,0.1,30);
    SH_fit(:,:,t) = SH_rmneg;
end
disp("Done!");

%%
save('savename','SH_fit');