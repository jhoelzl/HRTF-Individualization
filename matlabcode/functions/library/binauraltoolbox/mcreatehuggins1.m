function output_wave = mcreatehuggins1(transitioncf, transitionbw, centerfreq, bandwidth, spectrumlevelleft, spectrumlevelright, itd, ipd, duration, gatelength, samplefreq, infoflag)
% function output_wave = ...
% mcreatehuggins1(transitioncf, transitionbw, 
%                 centerfreq, bandwidth, ...
%                 spectrumlevelleft, spectrumlevelright, itd, ipd,  ...
%                 duration, gatelength, samplefreq, infoflag)
%
%--------------------------------------------------------------------
% Makes a Huggins pitch using a bandpass noise as a carrier.
% Frequency of noise specified as centerfrequency and bandwidth
%--------------------------------------------------------------------
%
% Input parameters:
%    transitioncf       = center frequency of Huggins transition (Hz)
%    transitionbw       = 0->2pi width of transition band
%                           (percent of center frequency)
%    centerfreq         = center frequency of noise band (Hz)
%    bandwidth          = bandwidth of noise band (Hz)
%    spectrumlevelleft  = spectrum level of left channel of 
%                           noise band (dB re 1.0)
%    spectrumlevelright = spectrum level of right channel of
%                           noise band (dB re 1.0)
%    itd                = interaural time delay (microseconds)
%                           (positive ITDs corresponds to right-channel leading)
%    ipd                = interaural phase delay (degrees)
%                           (positive IPDs corresponds to right-channel leading)
%    duration           = duration of noise (milliseconds)
%    gatelength         = duration of raised-cosine gates applied to
%                            onset and offset (milliseconds)
%    samplefreq         = sampling frequency (Hz)
%    infoflag           = 1 : print some information while running
%                         0 : dont print anything
%
% Output parameters:
%    output_wave = 'wave' structure, using the format defined 
%                  in mwavecreate.m
%
%
% The noise is constructed in the frequency domain and then
% converted to a waveform using an inverse FFT
%
%
% Examples:
% to create a Huggins pitch at 600 Hz and of 16% bandwidth,
% carried on a noise of 500-Hz center frequency, 1000-Hz bandwidth,
% 40-dB spectrum level, 0-us ITD, 0-degrees IPD, 250-ms duration,
% 10-ms raised-cosine gates and using a sampling frequency of
% 20000 Hz, type:
% >> wave1 = mcreatehuggins1(600, 16, 500, 1000, 40, 40, 0, 0, 250, 10, 20000, 1);
%
%
% version 1.0 (January 20th 2001)
% MAA Winter 2001 
%--------------------------------

%-----------------------------------------------------------
% 
% "Binaural auditory processing toolbox for MATLAB Software"
% 
% **  Licence Agreement **
% 
% The "Binaural auditory processing toolbox for MATLAB" software
% was developed by Michael Akeroyd for supporting research at 
% MRC IHR. It is based on earlier work at the University of 
% Connecticut (funded by the NIH) and the University of Sussex 
% (funded by the MRC).  It is made available to the academic
% community in the hope that it may prove useful.  
% 
% Definitions:
% TOOLBOX means the "Binaural auditory processing toolbox for 
%   MATLAB" software package and any associated documentation,
%   whether electronic or printed.
% USER means any person or organisation that uses the TOOLBOX.
% ACADEMIC means not-for-profit.
% 
% By using the TOOLBOX, the USER hereby agrees to the following conditions:
% 
% Grant:
% The TOOLBOX is copyrighted by MRC from 2001 to 2004, and
% protected by European Copyright Law.  All rights are reserved worldwide.
% MRC grants USER the royalty free right under MRC Copyright and
% MRC intellectual property rights to use TOOLBOX for ACADEMIC
% purposes only.  If USER wishes to use TOOLBOX for commercial
% for-profit purposes then USER will contact MRC for a commercial licence. 
%         
% Contact address:
%   Dr Michael A Akeroyd,
%   MRC Institute of Hearing Research,
%   Glasgow Royal Infirmary,
%   (Queen Elizabeth Building),
%   16 Alexandra Parade,
%   Glasgow, G31 2ER, United Kingdom
% 
%   maa@ihr.gla.ac.uk
%   http://www.ihr.gla.ac.uk  http://www.ihr.mrc.ac.uk
% 
% USER will not pass the TOOLBOX to any other party unless it is
% accompanied by this Licence Agreement.
% 
% Disclaimer:
% MRC makes no representation or warranty with respect to TOOLBOX
% and specifically disclaims any implied warranties of merchantability
% and fitness for a particular purpose or that use of TOOLBOX
% will not infringe any third party rights.
% 
% MRC reserves the right to revise TOOLBOX and to make changes
% therein from time to time without obligation to notify any person
% or organisation of such revision or changes.
% 
% While MRC will make every effort to ensure the accuracy of TOOLBOX,
% neither MRC nor its employees or agents may be held responsible
% for errors, omissions or other inaccuracies or any consequences
% thereof.  The MRC will not be liable in any way for any losses
% howsoever caused by the use of TOOLBOX, such losses to include
% but not be limited to loss of profit, business interruption, 
% loss of business information, or other pecuniary loss, including
% but not limited to special incidental consequential or other damages.
% 
%-----------------------------------------------------------




if infoflag >= 1
  fprintf('This is %s.m\n', mfilename);
end;

% abort if the duration is 0 
if duration <= 0 
   fprintf('%s: error! duration <= 0\n\n', mfilename); 
   output_wave= [];
   return;
end;

% abort if the centerfreq < 0
if centerfreq <= 0 
   fprintf('%s: error! center frequency < 0\n\n', mfilename); 
   output_wave= [];
   return;
end;
   
% abort if the bandwidth <= 0
if bandwidth <= 0 
   fprintf('%s: error! bandwidth <= 0\n\n', mfilename); 
   output_wave= [];
   return;
end;
   
% abort if the samplefreq is 0 
if samplefreq <= 0 
   fprintf('%s: error! samplefreq <= 0\n\n', mfilename); 
   output_wave = [];
   return;
end;
   
% abort if the twice gate duration is > overall duration
if (2*gatelength > duration) 
   fprintf('%s: error! total gate duration (=%.1f ms) > overall duration (=%.1f ms)\n\n', 2*gatelength, duration); fprintf('\n', mfilename); 
   output_wave = [];
   return;
end;
   
% abort if no output specified 
if nargout ~= 1 
   fprintf('%s: error! 1 output argument must be specified\n\n', mfilename);
   output_wave = [];
   return;
end;


%---------------------------------------------------


% define length of waveform in samples and FFT sizes
nsamples = duration/1000*samplefreq;
% make even so that mfft1sid doesn't fall over
if (mod(nsamples, 2) == 1)
   nsamples = nsamples + 1;
   end;
samplerate = 1/samplefreq;
timevector = 0:samplerate:((nsamples-1)*samplerate);
hzperpoint = (1/(nsamples.*samplerate)); % resolutiuon of FFT, Hz
halfbandwidth = bandwidth/2;
lowfrequency = centerfreq-halfbandwidth;
highfrequency = centerfreq+halfbandwidth;

if (lowfrequency<0)
   lowfrequency = 0;
end;

lowcut = round(lowfrequency/hzperpoint)+1;
highcut = round(highfrequency/hzperpoint)+1;
numcomponents = (highcut-lowcut)+1;

if infoflag >= 1,
   fprintf('creating %d-point FFT buffer with %d sampling rate ...\n', nsamples, samplefreq);
   fprintf('FFT resolution = %.2f Hz \n', hzperpoint);
   fprintf('center frequency: %.1f Hz  bandwidth: %.0f Hz\n', centerfreq, bandwidth);
   fprintf('lowest frequency : %.1f Hz (rounded to %.1f Hz) \n', lowfrequency, round(lowfrequency/hzperpoint)*hzperpoint);
   fprintf('highest frequency: %.1f Hz (rounded to %.1f Hz) \n', highfrequency, round(highfrequency/hzperpoint)*hzperpoint);
   fprintf('number of FFT components included = %d\n', numcomponents);
end;

% define and fill the FFT buffer; fill with normal-distribution random real/imag complex numbers 
if infoflag >= 1,
   fprintf('creating random real/imag complex pairs ...\n');
   end;
spectrumbuffer_complex = zeros(1,nsamples);
spectrumbuffer_complex(:,lowcut:highcut) = randn(1,numcomponents) + i*randn(1,numcomponents);
% inverse fft to get a monaural waveform
if infoflag >= 1,
   fprintf('inverse FFTing for waveform ...\n');
   end;
waveform0 = real(ifft(spectrumbuffer_complex));

% normalize so expected power is 1.0
if infoflag >= 1,
   fprintf('normalizing power ...\n');
   end;
expectedpower = (1./nsamples).^2.*numcomponents;
waveform0 = waveform0./expectedpower.^0.5;

% fft again to get magnitude/phase components to allow 
if infoflag >= 1,
   fprintf('getting phase spectrum ...\n');
   end;
fftspectrum1 = mfft1side(waveform0, samplefreq, nsamples, 0);
% format of fftspectrum is : column 1 = frequency, hz
%                                   2 = magnitude
%                                   3 = phase, radians

% do the ITD by generating a linear phase shift
if infoflag >= 1,
   fprintf('time-delaying phase spectrum of right channel by %.0f usecs ...\n', itd);
end;
phaseshift = zeros(1,length(fftspectrum1)); 
for f=1:length(fftspectrum1)
   freq = fftspectrum1(f, 1);
   if freq > 0
      period = 1/freq;
      phaseshift(f) = (itd/1000000)/period*(2*pi); % itd is in usecs 
   else % freq = 0 is dc
      phaseshift(f) = 0;
      end;
   end;
   
% add phase shift
if infoflag >= 1,
   fprintf('phase-shifting phase spectrum of right channel by %d degs ...\n', ipd);
end;
for f=1:length(fftspectrum1)
   phaseshift(f) = phaseshift(f) + (ipd/360.0*(2*pi)); % ipd is in degs
   end;

% apply the phase shift to a copy of the fft spectrum
fftspectrum2 = fftspectrum1; % column 1 is frequency, 2 is magnitude, 3 is phase
fftspectrum2(:, 3) = fftspectrum2(:, 3)+ phaseshift'; 


%---------------------------------------------------

% create huggins transition
if infoflag == 1,
   fprintf('  creating 0-2pi phase-shift transition in left channel ...\n');
end;
freqs = fftspectrum1(:,1); % extract frequencys from the FFT spectrum
lowfftfreqindex = 1;
highfftfreqindex = 1;

% convert the transition bandwidth into FFT freq points by getting
% the upper and lower limits
for n=length(freqs):-1:1
   if freqs(n) >= (transitioncf - (transitionbw/100/2 * transitioncf))
      lowfftfreqindex = n;
      end;
   end;
for n=1:1:length(freqs)
   if freqs(n) <= (transitioncf + (transitionbw/100/2 * transitioncf))
      highfftfreqindex = n;
      end;
   end;
if infoflag == 1,
   fprintf('  bottom freq = %.1f Hz (=0 radians)\n', freqs(lowfftfreqindex));
   fprintf('  middle freq = %.1f Hz (=pi radians)\n', 0.5*(freqs(lowfftfreqindex) + freqs(highfftfreqindex)));
   fprintf('  top freq    = %.1f Hz (=2pi radians)\n', freqs(highfftfreqindex));
   fprintf('  range       = %.1f Hz = %d FFT points)\n', freqs(highfftfreqindex) - freqs(lowfftfreqindex), highfftfreqindex-lowfftfreqindex);
end;

% create the Huggins phase shift: linear 0-2pi transition
counter = 1;
for n=lowfftfreqindex:highfftfreqindex
   hugginsphaseshift(counter) = (n-lowfftfreqindex)/(highfftfreqindex-lowfftfreqindex) *2*pi;
   counter = counter+1;
end;

% apply to the fft
fftspectrum1(lowfftfreqindex: highfftfreqindex, 3) = fftspectrum1(lowfftfreqindex: highfftfreqindex, 3)+ hugginsphaseshift'; 


%---------------------------------------------------

% do the inverse FFTs to get the waveforms
waveform1=minversefft1side(fftspectrum1, samplefreq, 0);
waveform2=minversefft1side(fftspectrum2, samplefreq, 0);


%---------------------------------------------------


% gate using raised cosines 
if (gatelength > 0)
   if infoflag >= 1
      fprintf('applying %.1f-ms raised cosine gates ...\n', gatelength);
   end;
   onsetlength_samples = gatelength*samplefreq/1000;  %gate length is in msecs
   offsetlength_samples = onsetlength_samples;
   onsetgate = 0:1:onsetlength_samples-1;
   onsetgate = 0.5 - 0.5*cos(pi*(mod(onsetgate, onsetlength_samples)/onsetlength_samples));
   offsetgate = 0:1:offsetlength_samples-1;
   offsetgate = 0.5 - 0.5*cos(pi*(mod(offsetgate, offsetlength_samples)/offsetlength_samples));
   offsetgate = fliplr(offsetgate);
   middlegate = linspace(1,1, (nsamples - onsetlength_samples - offsetlength_samples));  
   % special switch is totla gate duration = overall duration
   if ((onsetlength_samples + offsetlength_samples) == nsamples)
      middlegate = [];
   end;
   gate = [onsetgate, middlegate, offsetgate];
   waveform1 = waveform1.*gate;
   waveform2 = waveform2.*gate;

else
   if infoflag >= 1
      fprintf('no gates applied \n');
   end;
  
end;


% Set amplitudes so spectrum level is correct
% The above normalization means that the overall expected power is 1.0 (0 db)
% The spectrumlevel calculation is therefore to *multiply* the final buffer
% by a constant such that its overall power is spectrumlevel+10log(bwidth)
% and that "overall power" is the numerical result of 10log10(x^2/t)
% (so 32767 comes out at +90 or so).
%

overalllevel_db = spectrumlevelleft + 10*log10(bandwidth);
if infoflag >= 1
   fprintf('setting spectrum level of left channel to %.1f dB (overall level = %.1f dB)...\n', spectrumlevelleft, overalllevel_db);
end;
meanpower1_db = 10.0*log10(mean(waveform1.*waveform1));
waveform1 = waveform1 * 10^(overalllevel_db/20);

overalllevel_db = spectrumlevelright + 10*log10(bandwidth);
if infoflag >= 1
   fprintf('setting spectrum level of right channel to %.1f dB (overall level = %.1f dB)...\n', spectrumlevelright, overalllevel_db);
end;
meanpower2_db = 10.0*log10(mean(waveform2.*waveform2));
waveform2 = waveform2 * 10^(overalllevel_db/20);


%---------------------------------------------------

% save 
output_wave = mwavecreate(waveform1, waveform2, samplefreq,infoflag);
output_wave.generator = mfilename;     % string containing what code made the stimulus

if infoflag >= 1
   fprintf('storing waveform to workspace as wave structure .. \n');
end;


if infoflag >= 1,
   fprintf('\n');
end;


% the end!
%-----------------------------------------------


