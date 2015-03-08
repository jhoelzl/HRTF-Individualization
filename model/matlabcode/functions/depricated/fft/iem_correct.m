function [ hrir_out ] = iem_correct( hrir_in )

% correct error in measurements
% several bins of hrtfs were zero

hrtf_mag = abs(fft(hrir_in));
hrtf_phase = angle(fft(hrir_in));

% Prove all pins are positive
hrtf_mag(find(hrtf_mag<1e-5))=1e-5;

hrir_out = real(ifft(hrtf_mag.*exp(j*hrtf_phase)));

size(hrir_in)
size(hrir_out)

plot(hrir_in,'b')
hold on
plot(hrir_out,'r')

end