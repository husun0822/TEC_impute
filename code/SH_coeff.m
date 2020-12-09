function f = SH_coeff(coeff,lat,lon)
order = sqrt(length(coeff))-1;
f = zeros(size(lat));
sinBeta = sind(lat);
for l = 0:order
    P = legendre(l,sinBeta);
    for m = 0:l
        j = l^2 + l + m + 1;
        if m == 0
            if l == 0
                f = f + coeff(j) * P * normalized(l,m);
            else
                f = f + coeff(j) * squeeze(P(m+1,:,:)) * normalized(l,m);
            end
        else
            f = f + coeff(j) * squeeze(P(m+1,:,:)) * normalized(l,m) .* sind(m*lon);
            j = l^2 + l - m + 1;
            f = f + coeff(j) * squeeze(P(m+1,:,:)) * normalized(l,m) .* cosd(m*lon);
        end
    end
end
end