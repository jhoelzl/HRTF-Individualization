function [Y,Y0] = log_f(X,c);

% Input:
%   X... vector or matrix of HRIRs
%
% Output:
%   Y...vector/matrix of centered log frequency spectra

%We consider only the minimum phase
[n,m] = size(X);

% we want log-frequency domain
Xf = fft(X,m,2);
ph = angle(Xf);

Xf_log = 20*log10(abs(Xf));

if c==1
    % Substract mean, center data
    Xf0_log = mean(Xf_log,2);
    Xfc_log = Xf_log - repmat(Xf0_log,1,m);
    Y = Xfc_log;
    Y0 = Xf0_log;
else
    Y  = Xf_log;
    Y0 = 0;
end