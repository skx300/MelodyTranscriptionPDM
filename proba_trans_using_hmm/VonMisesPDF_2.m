function [ z ] = VonMisesPDF_2( F0,DELTA_F0,M,K,a,b,mu)
%VONMISESPDF_2 Yang-Maezawa distribution without stretching parameters.
%   Input:
%   @F0: the f0.
%   @DELTA_FO: the first order diference of f0.
%   @M: the middle point. (Usually the Midi number)
%   @K and a, b, mu: parameter for Von Mises distribution to change the width.
%   Output:
%   @z: the distribution.

    %create Von Mises distribution
    r = sqrt((F0-M).^2+(DELTA_F0).^2);
    
    cosTheta = (F0-M)./r;
    sinTheta = (DELTA_F0)./r;
    
    cosAll = cosTheta.*cos(mu)+sinTheta.*sin(mu);
    
    %normalization constant
%     normConst = (2*pi*besselj(0,K)*gamma(1+b)*a^(-b));
    normConst = 1;
       
    z = exp(K*(2*cosAll.^2-1)-a*r).*r.^(b-1)/normConst;
    
    %let the hole equal to maxmum value
    z(isnan(z)) = max(max(z));
    
%     z = z./sum(sum(z)); %make them sum to 1

end

