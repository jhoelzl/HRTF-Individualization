function [H,C,L] = sh_decomp(X,N,phi)
%
%% Spherical Harmonics decomposition of HRTF data
%
% Usage

%% Init
[n,m] = size(X);
phi   = phi(:);

% create signals to be decomposed
[Xf,Xf0]  = log_f(X,0);
%Xf  = minph(X);

%% SH
C = chebyshev12(N,phi);
% normalize
nrmlz=ones(1,2*N+1)/sqrt(2*pi);
nrmlz(N+1)=nrmlz(N+1)/sqrt(2);
C=C*diag(nrmlz);
%ind = cr_ind(N);
%C = C(:,ind);
condition_number = cond(C'*C)
L  = (4*pi/n)*C'*Xf;%(inv(C'*C)*C')*Xf; % inv(C)*Xf;

%% Resynthesis
%Xn = C*L; %+ repmat(Xf0,1,m); % reconstructed HRTFs 

%minimum phase reconstruction
H  = zeros(n,m);
for j=1:n
    f   = C(j,:)*L;
    mag = 10.^(f(1,:)./20);
    ph = imag(hilbert(-log(mag)));
    H(j,:) = real(ifft(mag.*exp(sqrt(-1)*ph)));
end


%% Plots
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
% figure
% semilogx(fax,20*log10(abs(f(1:m/2+1))))
% hold
% semilogx(fax,20*log10(abs(fn(1:m/2+1))),'r--')
% hold
% grid
% ylabel('dB')
% xlabel('frequency in Hz')
% axis tight


end