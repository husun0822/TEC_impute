function [A,R] = get_matrix(lats,lons,order)
k = (order+1)^2;
n = length(lats);
A = zeros(n,k);
R = zeros(k,k);
ms = [0:order]' * reshape(lons,1,[]);
sinBeta = sind(lats);
for l = 0:order
    P = legendre(l,sinBeta);
    for m = 0:l
        j = l^2 + l + m + 1;
        R(j,j) = l^2*(l^2+1)^2;
        if m == 0
            A(:,j) = P(m+1,:) * normalized(l,m);                    %------------an0
        else
            A(:,j) = P(m+1,:) * normalized(l,m) .* sind(ms(m+1,:));         %------------bnm
            j = l^2 + l - m + 1;
            A(:,j) = P(m+1,:) * normalized(l,m) .* cosd(ms(m+1,:));         %------------anm
        end
    end
end
end