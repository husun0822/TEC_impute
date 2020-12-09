function [SH,SH_ICLS,output] = SHfit_ICLS(tec,lat,lon,order,mu,niter)
    %Generates spherical harmonics least square fitting of gobal TEC map
    %with missing values
    % Input:
    % tec - 2D matrix of raw TEC data 
    % lat - 2D matrix of latitude grid
    % lon - 2D matrix of longitude grid
    % order - scalar, max order of spherical harmonics used for the fitting
    % mu - scalar, coefficient of regularization
    % niter - scalar >=1, number of interations of applying inequality constrains to
    %         eliminate negative TEC values in the output
    % 
    % Output:
    % SH - 2D matrix of the fitted TEC map, without inequality constrains
    % SH_ICLS - 2D matrix of the fitted TEC map with applying the inequality 
    %           constrains niter times
    % output - 1 by 2 vector showing the output message of the LCP solver used in 
    %           the last iteration of inequality constrains. The first component 
    %           is a 1 if the algorithm was successful, and a 2 if a ray termination 
    %           resulted.  The second component is the number of iterations performed 
    %           in the outer loop within the solver.
    
    b = tec(~isnan(tec));
    lats = lat(~isnan(tec));
    lons = lon(~isnan(tec));
    
    [A,R] = get_matrix(lats,lons,order); % get coefficient matrix for the least square problem
    B = A'*A + mu*R; % formulate the coefficient matrix with regularization
    y = A'*b;
    
    N = B'*B;
    coeff = N\B' * y; % solve the LS coefficients using pseudo inverse
    
    SH = SH_coeff(coeff,lat,lon); % reconstruct the TEC map with the obtained coefficients
    
    % applying inequality constrains once and reconstruct the resulting TEC map
    [coeff_ICLS,output] = ICLS(N,coeff,SH,lat,lon,order);
    SH_ICLS = SH_coeff(coeff_ICLS,lat,lon);
    
    % applying inequality constrains for niter-1 more times
    for i = 1:niter-1
%         disp(['Iteration ' num2str(i)]);
        if isempty(find(SH_ICLS <= 0,1))
            break
        else
            [coeff_ICLS,output] = ICLS(N,coeff_ICLS,SH_ICLS,lat,lon,order);
            %         disp(['Output:' num2str(output)]);
            SH_ICLS = SH_coeff(coeff_ICLS,lat,lon);
        end
    end
    % if after all the iterations there are still negative TEC values 
    % somewhere, assign the min postive TEC values to those locations
    if ~isempty(find(SH_ICLS <= 0,1))
        SH_ICLS(SH_ICLS<=0) = min(SH_ICLS(SH_ICLS>0));
    end
    
end