function normlz=sh_normalization_real(nmax);

% function normlz=sh_normalization_real(nmax);
% finds the normalization coefficients for 
% the real-valued spherical harmonics up to order
% nmax. dimension: 1 x (nmax+1)^2
%
% Implementation by Franz Zotter, Institute of Electronic Music and Acoustics
% (IEM), University of Music and Dramatic Arts (KUG), Graz, Austria
% http://iem.at/Members/zotter, 2008.
%
% This code is published under the Gnu General Public License, see
% "LICENSE.txt"
%
%

normlz=zeros(1,(nmax+1)*(nmax+2)/2);

% recursive implementation, Franz Zotter:
% for normalization of (n,0) from the value in (0,0)
% column position in the array is (n,m)=(n,0)+n
% and n0=(n,0)
normlz(1)=sqrt(1/(2*pi));
n0=2;
for n=1:nmax
   normlz(n0)=normlz(1)*sqrt(2*n+1);
   n0=n0+n+1;
end

% recurrence for (n,m) from (n,m-1)
n0=2;
for n=1:nmax
   for m=1:n
      normlz(n0+m)=-normlz(n0+m-1) / sqrt((n+m)*(n-m+1));
   end
   n0=n0+n+1;
end

n0=1;
oneoversqt=1/sqrt(2);
for n=0:nmax
   normlz(n0)=oneoversqt * normlz(n0);
   n0=n0+n+1;
end

