function P=legendre_a(nmax,theta)

% function P=legendre_a(nmax,theta);
% Evaluates all associated legendre functions 
% at the angles theta up to the order nmax
% using the three-term recurrence of the Legendre functions.
% P has dimensions length(theta) x (nmax+1)(nmax+2)
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

P=zeros(length(theta),(nmax+1)*(nmax+2)/2);
costheta=cos(theta);
sintheta=sin(theta);

P(:,1)=1;
% first iteration for n=m from n-1=m-1:
% column position in the array is (n,m)=(n,0)+m
% nmo0=(n-1,0), and n0=(n,0)
nmo0=1;
n0=2;
for n=1:nmax
      P(:,n0+n)=-(2*n-1)*P(:,nmo0+n-1).*sintheta;
      nmo0=n0;
   n0=n0+n+1;
end

% second iteration for n,m from n-1,m and n-2,m:
% column position in the array is (n,m)=(n,0)+m
% nmt0=(n-2,0), nmo0=(n-1,0), n0=(n,0)
nmt0=0;
nmo0=1;
n0=2;
for n=1:nmax
   for m=0:n-1
      if (m<=n-2)
         P(:,n0+m) = (...
	   (2*n-1) * costheta .* P(:,nmo0+m) ...
	  -(n+m-1) * P(:,nmt0+m)...
	             )/(n-m);
      else
         P(:,n0+m) = (...
	   (2*n-1) * costheta .* P(:,nmo0+m) ...
	             )/(n-m);
      end
   end
   nmt0=nmo0;
   nmo0=n0;
   n0=n0+n+1;
end
 
