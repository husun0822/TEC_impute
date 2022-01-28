function TECh5toMAT(fname,folder,outFolder)
% Process original Madrigal TEC file in .hdf5 format and save as .mat
% format.
% 
% fname (string) - file name of original Madrigal TEC file .hdf5
% folder (string) - directory of the original Madrigal TEC file
% outFolder (string) - directory to save the output .mat file

    % load TEC data in .hdf5 format
    [tecTable] = h5readtable([folder '/' fname]);
    
    % get timestamps 
    times = unique(tecTable.dates);
    ntime = numel(times);

    % create global latitude/longitude grid
    latLimits = [-90 90];
    lonLimits = [-180 180];
    gratSize = [181,361];
    [latGrid, lonGrid] = meshgrat(latLimits, lonLimits, gratSize);
    
    % create matrices to hold data
    TEC = zeros([gratSize,ntime]);
    dTEC = zeros([gratSize,ntime]);
    TEC_MedianFilter = zeros([gratSize,ntime]);
    
    %% loop through timestamps and populate the matrices with data
    for i = 1:ntime

        time = times(i);

        % find and extract tec data at current time
        data = tecTable(tecTable.dates==time,:);

        % check if empty
        if isempty(data)
            warning('No TEC data at time: %s', datestr(time));
        end

        gdlat = data.gdlat; % latitude
        glon = data.glon; % longitude
        tec = data.tec; % TEC
        dtec = data.dtec; % TEC uncertainty

        % populate grid with tec data
        % change grid numerical type to int to make populating easier
        tecGrid = zeros(size(latGrid));
        dtecGrid = zeros(size(latGrid));
        tecGridCount = zeros(size(latGrid));
        tol = 0.1;
        for m = 1:length(tec)
            latindex = find(abs(latGrid(:,1) - gdlat(m)) <= tol);
            lonindex = find(abs(lonGrid(1,:) - glon(m)) <= tol);
            tecGrid(latindex,lonindex) = tecGrid(latindex,lonindex)+tec(m);
            dtecGrid(latindex,lonindex) = dtecGrid(latindex,lonindex)+dtec(m);
            tecGridCount(latindex,lonindex) = tecGridCount(latindex,lonindex)+1;
        end
        tecGrid(tecGridCount==0)=nan;
        tecGrid = tecGrid./tecGridCount;
        dtecGrid(tecGridCount==0)=nan;
        dtecGrid = dtecGrid./tecGridCount;
        TEC(:,:,i) = tecGrid;
        dTEC(:,:,i) = dtecGrid;

        % apply 3x3 median filter to the TEC data
        medianFilterSize = [3,3];
        if any(medianFilterSize~=[1,1])
            tecGrid_Filtered = tecmedfilt2(tecGrid, medianFilterSize);
            TEC_MedianFilter(:,:,i) = tecGrid_Filtered;
        end
    end
    
    %% create a struct object to save all the data
    tecData.tec = TEC;
    tecData.dtec = dTEC;
    tecData.tec_MedianFilter = TEC_MedianFilter;
    tecData.time = cellstr(datestr(times,'yyyy-mm-dd/HH:MM:SS'));
    tecData.latitude = latGrid;
    tecData.longitude = lonGrid;
    
    % convert data in geographic coordinates to local time coordinates
    [tec_local_time, ~] = get_tec_local_time(tecData.tec, tecData.longitude, tecData.time);
    [dtec_local_time, ~] = get_tec_local_time(tecData.dtec, tecData.longitude, tecData.time);
    [tec_local_time_MedianFilter, ltGrid] = get_tec_local_time(tecData.tec_MedianFilter, tecData.longitude, tecData.time);
    tecData.tec_local_time = tec_local_time;
    tecData.dtec_local_time = dtec_local_time;
    tecData.tec_local_time_MedianFilter = tec_local_time_MedianFilter;
    tecData.local_time = ltGrid;
    
    % save the struct object in a .mat file
    names = strsplit(fname,'.');
    save([outFolder '/' names{1} '.mat'],'tecData','-v7');
end