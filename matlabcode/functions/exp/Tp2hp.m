function hp = Tp2hp(tp)
%function hp=tp2hp(tp) 
% converts from (theta,phi) coordinates where az is cc 0=>2pi and el 0=>pi 
% to hoop coordinates where az is c -180=>0=>+180, el +/-90
% two cols of data are assumed [theta phi]
% tp is a matrix with [theta phi] being the columns and the samples as rows
% p is a matrix with [az el] being the columns and the samples as rows
hp=tp;
for n=1:size(tp,1)
    hp(n,1) = - tp(n,2);
    if hp(n,1)<-pi
        hp(n,1) = 2*pi + hp(n,1);
    end
%   hp(n,1) = 2*pi - tp(n,2);
	hp(n,2) = pi/2 - tp(n,1);
end
% hp(hp>pi,1) = hp(hp>pi,1) - 2*pi;
hp = hp .* 180 / pi;

% This is more like spherical coordinates