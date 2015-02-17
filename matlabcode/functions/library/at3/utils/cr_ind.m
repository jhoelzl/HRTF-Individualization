function ind = cr_ind(N);
% N is order of spherical harmonics
% converts 3D to 2D
% 
% input:
%   N = spherical Harmonics order 
% output:
%   ind = indexes where the 2D harmonics are

N=N;
mi    = zeros(N+1,1);
mi(1) = 1;
for x=2:N+1
    sp    = (x-1)*2;
    mi(x) = sp + mi(x-1);
end

ind = zeros((N+1)^2,1);
for n=2:N+1
    ind(mi(n))   = mi(n)-(n-1);
    ind(mi(n)+1) = mi(n)+(n-1);
end
nb = find(ind);
ind = [1 ; ind(nb)];
end
