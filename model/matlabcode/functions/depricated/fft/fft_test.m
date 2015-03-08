function  fft_test()
close all

IEM = db_import('iem',1,1,1,2);

% Choose one HRIR pair
left = IEM(:,get_matrixvalue_iem(1)+4-1);
right = IEM(:,(get_matrixvalue_iem(1)+24+4-1));  
       
% Calculate FFT
N = 1024;
fs = 44100;
freq = (0 : (N/2)-1) * fs / N;
cutoff = ceil(N/2);

fft_left = fft(left,N);

mag_left = (abs(fft_left(1:cutoff)));
mag_left_all2 = abs(fft_left)
phase_left = angle(fft_left);

mag_left_all = mirror(mag_left);

figure
plot(mag_left_all2)
hold on
plot(mag_left_all,'r')

mag_left_all - mag_left_all2


[hrtf_ready_re, hrtf_ready_im] = pol2cart(phase_left,mag_left_all);
hrtf_ready = hrtf_ready_re + i*hrtf_ready_im;

hrir_left = real(ifft(hrtf_ready));


figure
plot(left)
hold on
plot(hrir_left(1:512),'r')


end

