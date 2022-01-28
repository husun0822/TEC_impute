function [tecTable] = h5readtable(filename)
    % read hdf5 file
    tecTable = struct2table(h5read(filename, '/Data/Table Layout'));
    
    % remove possible altitude column to make things uniform
    if ismember('gdalt', tecTable.Properties.VariableNames)
        tecTable.gdalt = [];
    end
    
    % roll date columns into one column
    tecTable.dates = datetime(tecTable.year, tecTable.month, tecTable.day, tecTable.hour, tecTable.min, tecTable.sec);
%     tecTable.dates = datetime(1970,1,1) + seconds(h5read(filename, '/Data/Array Layout/timestamps')) + minutes(2.5);
    
    % remove unnecessary table fields 
    tecTable.year = [];
    tecTable.month = [];
    tecTable.day = []; 
    tecTable.hour = [];
    tecTable.min = [];
    tecTable.sec = [];
    tecTable.recno = [];
    tecTable.kindat = [];
    tecTable.kinst = [];
    tecTable.ut1_unix = [];
    tecTable.ut2_unix = [];
%     tecTable.dtec = [];
    
end