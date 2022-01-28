%% create a tall timetable to process madrigal tec data
tec_dir = '/Users/jiaenren/Dropbox (University of Michigan)/TEC_201709/Data/Madrigal/hdf5';
year = 2005; 
tall = tectall([tec_dir '/' num2str(year)]);

%% make tec and dtec histogram
ax1 = subplot(2,1,1);
h1 = histogram(tall.tec, 0:5:600);
ax2 = subplot(2,1,2);
h2 = histogram(tall.dtec, 0:1:100);

%% adjust scale
ax1.YScale = 'log';
ax2.YScale = 'log';