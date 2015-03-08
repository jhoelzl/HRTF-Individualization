function Y = minph(X)

% Input:
%   X = set of HRIRs
%
% Output: 
%   Y = set of minimum phase HRTFs

%We consider only the minimum phase
[n,m] = size(X);
Xmin  = zeros(n,m);
for k =1:n
[xorg Xmin(k,:)] = rceps(X(k,:));
end

% we want log-frequency domain
Xf = fft(Xmin,m,2);

Y = Xf;
