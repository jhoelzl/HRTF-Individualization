function [H,C,L] = pca_decomp(X,r)

%% Principal Component Analysis
% 
% Usage: 
%   pc = my_PCA(X,r)
%
% Input:
%   X = Matrix of data (IR's), rows are the observations, coloums the variables
%   r = amount of principal components
%
% Output:
%   H = reconstructed HRIRs
%   C = weights
%   L = basis filters
%
% Author:
%   Fabio Kaiser, 20/3/10, Graz

%% TO DO

%% Init
[n,m] = size(X);
[Xf,Xf0]  = log_f(X,1);
%Xf  = minph(X);

%% PCA
% build covariance matrix (size(V)=p*p)
%COV = cov(Xfc');                         % removes mean automatically
% get Eigenvectors and eigenvalues
%[C,D] = eig(full(COV));                  % V is the feature matrix
%compare:
C  = princomp(Xf');
% take r vectors
C  = C(:,1:r); 
condition_number = cond(C'*C)
% calculate reconstruction filters
L   = C'*Xf;%(inv(C'*C)*C')*Xf; % pinv(C)
    

%% Resynthesis
%Xn = C*L + repmat(Xf0,1,m);

%minimum phase reconstruction
H  = zeros(n,m);
for j=1:n
    f   = C(j,:)*L + repmat(Xf0(j),1,m);
    mag = 10.^(f(1,:)./20);
    ph = imag(hilbert(-log(mag)));
    H(j,:) = real(ifft(mag.*exp(sqrt(-1)*ph)));
end

%% Plots
% calculate new data set for evaluation


 % in samples
h  = X(7,:);
f  = fft(h);
hn = H(7,:);%sxphase(10.^(Xn(7,1:m/2+1)/20),itd);%10.^(Xn(7,:)./20).*exp(-1i*itd);
fn = fft(hn);
fax = 1:44100/m:44100;
fax = fax(1:m/2+1);

% plots
% figure
% subplot(2,1,1)
% plot(h)
% hold
% plot(hn,'r--')
% grid
% ylabel('Amplitude')
% xlabel('time in samples @ 44100Hz')
% title('blue = real HRTF, red dashed = recostructed')
% axis tight

%subplot(2,1,2)
% semilogx(fax,20*log10(abs(f(1:m/2+1))))
% hold
% semilogx(fax,20*log10(abs(fn(1:m/2+1))),'r--')
% grid
% ylabel('dB')
% xlabel('frequency in Hz')
% axis tight


end

%% Alternatives

% get minimum phase HRTFs
% Mag    = abs(Xf);
% ph     = angle(Xf);
% % get rid of mean
% min_ph = imag((hilbert((-log(Mag))'))');
% Xf_min = Mag.*exp(-i*min_ph);




