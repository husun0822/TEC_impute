%% create a tall timetable to process madrigal tec data
tec_dir = '/Users/jiaenren/Dropbox (University of Michigan)/TEC_201709/Data/Madrigal/hdf5';
year = 2005; 
tall = tectall([tec_dir '/' num2str(year)]);

%% make tec histogram
h1 = histogram(tall.tec, 0:5:500);
xscale('log');

%% make dtec histogram
h2 = histogram(tall.dtec, 0:1:100);
xscale('log');