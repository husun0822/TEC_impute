function [coeff_ICLS,output] = ICLS(N,coeff,SH,lat,lon,order)
    
    neg_index = find(SH <= 0);
    if isempty(neg_index)
        coeff_ICLS = coeff;
        output = [];
        return
    end
    c = 0.01 + zeros(size(neg_index));
    neg_lats = lat(neg_index);
    neg_lons = lon(neg_index);
    [G,~] = get_matrix(neg_lats,neg_lons,order);
    
    M = G*(N\G');
    w = G * coeff - c;
    [~,x,output] = LCPSolve(M,w);
    % options = optimoptions('quadprog','MaxIterations',500);
    % [x,fval,exitflag,output] = quadprog(2*M,w,-M,w,[],[],0*w,[],[],options);
    coeff_ICLS = coeff + N\G' * x;
end