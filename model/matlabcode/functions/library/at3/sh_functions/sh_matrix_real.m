function Y=sh_matrix_real(nmax,phi,theta)

% function Y=sh_matrix_real(nmax,phi,theta);
% Evaluates all real-valued normalized spherical harmonics 
% at the angles phi...azimuth, theta...zenith
% up to the order nmax. 
% Y has the dimensions length(phi) x (nmax+1)^2
%
% Implementation by Franz Zotter, Institute of Electronic Music and Acoustics
% (IEM), University of Music and Dramatic Arts (KUG), Graz, Austria
% http://iem.at/Members/zotter, 2008.
%
% This code is published under the Gnu General Public License, see
% "LICENSE.txt"
%
%
theta=theta(:);
phi=phi(:);

% azimuth harmonics
T=chebyshev12(nmax,phi);
P=legendre_a(nmax,theta);
normlz=sh_normalization_real(nmax);

Y=zeros(length(theta),(nmax+1)^2);
% nt0=nmax+1
% np0=(n+1)(n+2)/2
% ny0=(n+1)^2-n
nt0=nmax+1;
np0=1;
ny0=1;
for n=0:nmax
   m=0:n;
   Y(:,ny0+m) = repmat(normlz(np0+abs(m)),length(theta),1) .* P(:,np0+abs(m)) .* T(:,nt0+m);
   m=-n:-1;
   Y(:,ny0+m) = -repmat(normlz(np0+abs(m)),length(theta),1) .* P(:,np0+abs(m)) .* T(:,nt0+m);
   np0=np0+n+1;
   ny0=ny0+2*n+2;
end

