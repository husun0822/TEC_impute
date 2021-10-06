function [tecTimeTable] = load_vista(dataDirectory, times)
    %load_vista load vista tec data within the given time into a timetable
    
    timeStr = unique(cellstr(datestr(times,'yymmdd')));
    n = numel(timeStr);
    tables = cell(n,1);
    for i = 1:n
        tstr = timeStr{i};
        flist = dir([dataDirectory '/**/*' tstr '*.mat']);
        if numel(flist)>1
            flist = flist(1);
        elseif numel(flist)<1
            warning(['No file match pattern: ' [dataDirectory '/**/*' tstr '*.mat'] ...
                ' Try running dir(pattern) to debug.']);
        end
        tables{i}=arrayfun(@(c) load_vista_mat([c.folder '/' c.name]), flist, ...
            'UniformOutput',false);
    end
    tecTimeTableCells = vertcat(tables{:});
    tecTimeTable = vertcat(tecTimeTableCells{:});
end

function output = load_vista_mat(path)
    tecData = load(path);
    if ~isfield(tecData,'tecData')
        output.tecData = tecData;
    else
        output = tecData;
    end
    if ~isfield(output.tecData, 'latitude') || ~isfield(output.tecData, 'local_time')
        % create time grid
        [~,name,~] = fileparts(path);
        names = split(name,'_');
        date_str = names{end};
        stime = datetime(date_str,'InputFormat','yyMMdd');
        timeGrid = stime+minutes(2.5):minutes(5):stime+days(1);
        output.tecData.time = cellstr(datestr(timeGrid,'yyyy-mm-dd/HH:MM:SS'));
        % create global latitude/local time grid
        tec_size = size(output.tecData.imputed);
        latLimits = [-90 90];
        ltLimits = [0 24];
        gratSize = tec_size(1:2);
        [latGrid, ltGrid] = meshgrat(latLimits, ltLimits, gratSize);
        output.tecData.latitude = latGrid;
        output.tecData.local_time = ltGrid;
    end
end
