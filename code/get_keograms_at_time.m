function keogram_data = get_keograms_at_time(tecVistaDirectory, dates)
    % extract keogram_data for dates specified from the data directory
    
    vistaData = load_vista(tecVistaDirectory,dates);
    n = numel(vistaData);
    keo = cell(n,3);
    for i = 1:n
        [keogram, time_grid, lat_grid] = get_keogram(vistaData(i).tecData, 'tec_vista');
        keo{i,1} = keogram;
        keo{i,2} = time_grid;
        keo{i,3} = lat_grid;
    end
    keogram_data.keogram = cat(2,keo{:,1});
    keogram_data.time_grid = cat(2,keo{:,2});
    keogram_data.lat_grid = cat(2,keo{:,3});
end
