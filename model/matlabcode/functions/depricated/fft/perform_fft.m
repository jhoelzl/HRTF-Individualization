function [fft_mag,fft_phase,freq] = perform_fft(input,fs)

% Perform FFT for real-valued input
%
% INPUT
% input =       hrir of database
%
% OUTPUT
% fft_mag =     FFT magnitude of input
% fft_phase =   FFT Phase
% freq =        frequency axis


% default value for fs
if (nargin ==1)
   fs = 44100; 
end

N = 1024;

hrtf = fft(input,N);
%hrtf = fft(input,N)/length(input);

freq = (0 : (N/2)-1) * fs / N;
cutoff = ceil(N/2);

fft_mag = 20*log10(2*abs(hrtf(1:cutoff)));
fft_phase = angle(hrtf);

%fft_mag = 2*abs(hrtf(1:cutoff));

end
