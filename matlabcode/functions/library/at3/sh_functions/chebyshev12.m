function T=chebyshev12(nmax,phi)

% function T=chebyshev12(nmax,phi);
% Evaluates all circular harmonics 
% at the angles phi up to the order nmax. 
% using the recurrence for the Chebyshev
% polynomials of the first and second kind
% T has the dimensions length(phi) x 2nmax+1
%
% Implementation by Franz Zotter, Institute of Electronic Music and Acoustics
% (IEM), University of Music and Dramatic Arts (KUG), Graz, Austria
% http://iem.at/Members/zotter, 2008.
%
% This code is published under the Gnu General Public License, see
% "LICENSE.txt"
%
%

phi=phi(:);

% Chebyshev polynomials 1st and 2nd kind 
% trigonometric recurrence
% for azimuth harmonics (sin, cos)
T1=[cos(phi),sin(phi)];
T=zeros(length(phi),2*nmax+1);
% cos(0*phi)
T(:,nmax+1)=1;
if (nmax>0)
  % cos(1*phi), sin(1*phi)
  T(:,nmax+1+[1 -1])=T1;
  for k=1:length(phi)
     % rotation matrix R
     % [ cos(phi), -sin(phi)
     %   sin(phi),  cos(phi) ]
     % multiplied to [cos(m*phi) sin(m*phi)] * R = [cos((m+1)*phi) sin((m+1)*phi)]
     R=[T1(k,:);-T1(k,2), T1(k,1)];
     % npo... n+1, because array n=0 lies at position 1 in MATLAB array ...
     for n=2:nmax
         T(k,nmax+1+[n -n])=T(k,nmax+1+[n-1 -n+1])*R;
     end
  end
end

