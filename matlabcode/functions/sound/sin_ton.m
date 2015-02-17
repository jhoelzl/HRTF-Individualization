function[s] = sin_ton(f0,d) 


freqs = f0;
duration = d;

for i = 1:length(freqs)

fs = 44100;
dt = 1/fs;

t = [0:dt:duration];

s=sin(2*pi*freqs(i)*t);
%sound(s,sampleFreq);
% wavName = sprintf(?tone%d.wav?,freqs(i));
% wavwrite(s,sampleFreq,16,wavName);

end

end