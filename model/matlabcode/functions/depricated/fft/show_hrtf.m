function show_hrtf(hrir)

figure
N = 512;
fs = 44100;

hrtf = abs(fft(hrir,N));

freq = (0 : (N/2)-1)*fs/N;
cutoff = ceil(N/2);

   % HRIR
   subplot(3,1,1)
   plot(hrir);
   grid
   title('HRIR');
   xlabel('Time [ms]');
   
   % HRTF
   subplot(3,1,2)
   plot(freq,20*log10(abs(hrtf(1:cutoff))));
   grid
   title('HRTF');
   ylabel('dB');
   xlabel('Frequency [[Hz]');

end
