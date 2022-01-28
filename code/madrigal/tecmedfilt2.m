function [ filtered_tec_grid ] = tecmedfilt2( tec_grid, sz )
%   Apply a median filter with a given kernel size to a TEC map

    if nargin<2
        sz = 3;
    end
    
    if length(sz)==1
        sz = [sz sz];
    end

    if any(mod(sz,2)==0)
        error('kernel size SZ must be odd)')
    end

    % pad grid to make longitude wrap around
    margin=(sz-1)/2;
    filter_grid = [tec_grid(:, end-(margin-1):end), tec_grid];
    filter_grid = [filter_grid, tec_grid(:, 1:margin)];

    % call nanmedfilt2
    filtered_tec_grid = nanmedfilt2(filter_grid, sz);

    % get rid of padded columns
    filtered_tec_grid = filtered_tec_grid(:, (1+margin):(end-margin));

end

