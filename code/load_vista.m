function [tecTimeTable] = load_vista(dataDirectory, times)
    %load_vista load vista tec data within the given time into a timetable
    
    timeStr = unique(cellstr(datestr(times,'yymmdd')));
    n = numel(timeStr);
    tables = cell(n,1);
    for i = 1:n
        tstr = timeStr{i};
        flist = dir([dataDirectory '/*' tstr '*']);
        tables{i}=arrayfun(@(c) load([c.folder '/' c.name],'tecData'), flist, ...
            'UniformOutput',false);
    end
    tecTimeTableCells = vertcat(tables{:});
    tecTimeTable = vertcat(tecTimeTableCells{:});
end