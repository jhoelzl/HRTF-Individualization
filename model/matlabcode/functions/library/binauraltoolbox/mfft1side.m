function output_spectrum = mfft1side(waveform, samplefreq, nfftpoints, infoflag)
% function output_spectrum = ...
% mfft1side(waveform, samplingfreq, nfftpoints, infoflag)
%
%-------------------------------------------------------------------
% Returns the magnitude and phase of the FFT of a monaural waveform
% Interface to the MATLAB function 'fft'
%-------------------------------------------------------------------
%
% Input parameters:
%   waveform     = monaural waveform (*not* a 'wave' signal
%   samplefreq   = sampling frequency (Hz)
%   nfftpoints   =:number of points in FFT
%   infoflag     = 2: plot figures and report some information while running
%                = 1: report some information while running only
%                = 0  dont report anything
%
%
% Output parameters:
%   output_spectrum = matrix of frequencies x FFT results.
%                     column 1 = FFT frequencies (Hz)
%                     column 2 = magnitudes (linear units not dB)
%                     column 3 = phases (radians)
%
% Figures:
%  figure 1 plots the phase spectrum
%  figure 2 plots the magnitude spectrum
%
% Examples:
% to plot the 2048-point FFT of the left channel of the 'wave' 
% signal wave1 (see mcreatetone1.m), using a sampling rate
% of 20000 Hz, type:
% >> fftmatrix = mfft1side(wave1.leftwaveform, 20000, 2048, 2);
%
% See also mcreatenoise1.m for another example.
%
% Thanks to Les Bernstein for supplying this function
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


if size(waveform, 2) > 1
   % transpose
   waveform = waveform';
end;

hzperpoint = samplefreq/nfftpoints; % resolution of FFT, Hz
if infoflag >= 1,
   fprintf('creating %d-point FFT buffer with %.0 Hz sampling rate ...\n', nfftpoints, samplefreq);
   fprintf('FFT resolution = %.2f Hz \n', hzperpoint);
end;

% create the frequency vector
freqvector = (samplefreq/2)*(0:(nfftpoints/2))/(nfftpoints/2);

% FFT
if infoflag >= 1
   fprintf('FFTing ... \n');
end;
complexspectrum = fft(waveform, nfftpoints);

% get magnitude and phase spectra
magnitudespectrum = abs(complexspectrum);
phasespectrum = angle(complexspectrum);

% discard half of the array but preserve DC and the nyquist frequyency
if infoflag >= 1
   fprintf('discarding negative frequencies ... \n');
end;
magnitudespectrum(((nfftpoints/2)+2):nfftpoints) = [];
phasespectrum(((nfftpoints/2)+2):nfftpoints) = [];

% double magnitudes (to account for half the spectrum being removed)
if infoflag >= 1
   fprintf('doubling magnitudes... \n');
end;
magnitudespectrum(2:nfftpoints/2) = 2*magnitudespectrum(2:nfftpoints/2);

% scale by number of points in FFT
if infoflag >= 1
   fprintf('scaling by number of points in FFT ... \n');
end;
magnitudespectrum = magnitudespectrum/nfftpoints;

% plot if required
if (infoflag >= 2)
   close 
   close;
   
   symbol = 'o-'; % 'o'= circles  '-'=lines joining the circles
   symbolsize = 2;
   
   figure(1);
   fprintf('plotting phase spectrum in figure %d ...\n', gcf);
   plot(freqvector, phasespectrum, symbol, 'Markersize', symbolsize);
   xlabel('Frequency (Hz)');
   ylabel('Phase (radians)')
   grid on;
   
   figure(2);
   fprintf('plotting magnitude spectrum in figure %d ...\n', gcf);
   plot(freqvector, 20*log10(magnitudespectrum), symbol, 'Markersize', symbolsize);
   xlabel('Frequency (Hz)');
   ylabel('Magnitude (dB)')
   grid on;
   
   
end;

% convert to columns for final output
if infoflag >= 1
   fprintf('storing answers as %dx%d matrix ...\n', length(freqvector), 3);
   fprintf('(%d frequencies = %d/2 + 1 (for 0-Hz component))\n', length(freqvector), nfftpoints);
end;
output_spectrum = [freqvector' magnitudespectrum phasespectrum];

if infoflag >= 1
   fprintf('\n');
end;

% the end!
%------------------------------------
