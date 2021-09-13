function irregulardays = importfile(filename, dataLines)
    %IMPORTFILE Import data from a text file
    %  IRREGULARDAYS = IMPORTFILE(FILENAME) reads data from text file
    %  FILENAME for the default selection.  Returns the data as a table.
    %
    %  IRREGULARDAYS = IMPORTFILE(FILE, DATALINES) reads data for the
    %  specified row interval(s) of text file FILENAME. Specify DATALINES as
    %  a positive scalar integer or a N-by-2 array of positive scalar
    %  integers for dis-contiguous row intervals.
    %
    %  Example:
    %  irregulardays = importfile("/Users/jiaenren/TEC_impute/data/irregular_days.csv", [2, Inf]);
    %
    %  See also READTABLE.
    %
    % Auto-generated by MATLAB on 06-Sep-2021 18:59:35
    
    %% Input handling
    
    % If dataLines is not specified, define defaults
    if nargin < 2
        dataLines = [2, Inf];
    end
    
    %% Setup the Import Options
    opts = delimitedTextImportOptions("NumVariables", 3);
    
    % Specify range and delimiter
    opts.DataLines = dataLines;
    opts.Delimiter = ",";
    
    % Specify column names and types
    opts.VariableNames = ["year", "month", "day"];
    opts.VariableTypes = ["double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    
    % Import the data
    irregulardays = readtable(filename, opts);
    
end