function [tecTimeTable] = tectall(dataDirectory)
    %TECTALL creates a tall time table to access tec data
    
    % create a file store out of all hdf5 files in the directory
    tecDataStore = fileDatastore(dataDirectory, 'ReadFcn', @h5readtable, ...
                                'UniformRead', true, 'FileExtensions', '.hdf5');
    
    % create a time table to access the tec data
    tecTall = tall(tecDataStore);

    % make a tall time table
    tecTimeTable = table2timetable(tecTall);

end


% function [tecTable] = h5readtable(filename)
%     % read hdf5 file
%     tecTable = struct2table(h5read(filename, '/Data/Table Layout'));
%     
%     % remove possible altitude column to make things uniform
%     if ismember('gdalt', tecTable.Properties.VariableNames)
%         tecTable.gdalt = [];
%     end
%     
%     % roll date columns into one column
%     tecTable.dates = datetime(tecTable.year, tecTable.month, tecTable.day, tecTable.hour, tecTable.min, tecTable.sec);
%     
%     % remove unnecessary table fields 
%     tecTable.year = [];
%     tecTable.month = [];
%     tecTable.day = []; 
%     tecTable.hour = [];
%     tecTable.min = [];
%     tecTable.sec = [];
%     tecTable.recno = [];
%     tecTable.kindat = [];
%     tecTable.kinst = [];
%     tecTable.ut1_unix = [];
%     tecTable.ut2_unix = [];
% %     tecTable.dtec = [];
% end

