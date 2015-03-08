function output_wave = mcreatenoise2rho(lowfrequency, highfrequency,  spectrumlevelleft, spectrumlevelright, rho, duration, gatelength, samplefreq, infoflag)
% function output_wave = ...
%  mcreatenoise2rho(lowfrequency, highfrequency,  ...
%                spectrumlevelleft, spectrumlevelright, rho,  ...
%                duration, gatelength, samplefreq, infoflag)
%
%-------------------------------------------------------------------------
% Makes a bandpass noise and stores it as a 'wave' signal
% Frequency of noise specified as lower and higher frequencies
% Only IID and interaural correlation (rho) of noise can be specified.
%-------------------------------------------------------------------------
%
% Input parameters
%    lowfrequency       = lower cutoff frequency (Hz)
%    highfrequency      = higher cutoff frequency (Hz)
%    spectrumlevelleft  = spectrum level of left channel of 
%                           noise band (dB re 1.0)
%    spectrumlevelright = spectrum level of right channel of
%                           noise band (dB re 1.0)
%    rho                = interaural correlation
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
% The noise is constructed in the frequency domain and then
% converted to a waveform using an inverse FFT
%
%
% Examples:
% to create a noise from 300 Hz to 700 Hz, 40-dB spectrum level, 
% correlation 0.0 (i.e, "Nu") , 10-ms raised-cosine gates and using a 
% sampling frequency of 20000 Hz, type:
% >> wave1 = mcreatenoise2rho(300, 700, 40, 40, 0, 250, 10, 20000, 1);
%
% to use a correlation of -1 (i.e., "Npi") instead:
% >> wave1 = mcreatenoise2rho(300, 700, 40, 40, -1, 250, 10, 20000, 1);
%
%
% Uses Licklider/Dzendolet three-noise method of making a decorrelated noise
% see also Akeroyd/Summerfield (JASA May 1999 vol 105(5) p. 2812),
% but modified to allow for correlations < 0
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

% in the Licklider/Dzendolet method the common:independent
% noises are in a power ratio of rho:(1-rho)

% make common noise
powerfactor = abs(rho);
if infoflag >= 1,
   fprintf('creating common noise: relative power             = %.2f ...\n', powerfactor);
   end;
commonwave = mcreatenoise2(lowfrequency, highfrequency, spectrumlevelleft, ...
   spectrumlevelright, 0, 0, duration, gatelength, samplefreq, 0);
if rho >= 0 
   commonwave.leftwaveform = commonwave.leftwaveform * sqrt(powerfactor);
   commonwave.rightwaveform = commonwave.rightwaveform * sqrt(powerfactor);
else
   if infoflag >= 1,
      fprintf('inverting one channel of common noise to get negative correlation ...\n');
   end;
   commonwave.leftwaveform = commonwave.leftwaveform * sqrt(powerfactor);
   commonwave.rightwaveform = -1 * commonwave.rightwaveform * sqrt(powerfactor);
end;


% make independent noise for left channel
powerfactor = 1-abs(rho);
if infoflag >= 1,
   fprintf('creating first independent noise: relative power  = %.2f ...\n', powerfactor);
   end;
indywave1 = mcreatenoise2(lowfrequency, highfrequency, spectrumlevelleft, ...
      spectrumlevelright, 0, 0, duration, gatelength, samplefreq, 0);
indywave1.leftwaveform = indywave1.leftwaveform * sqrt(powerfactor);
indywave1.rightwaveform = indywave1.rightwaveform * sqrt(powerfactor);


% make independent noise for right channel
powerfactor = 1-abs(rho);
if infoflag >= 1,
   fprintf('creating second independent noise: relative power = %.2f ...\n', powerfactor);
   end;
indywave2 = mcreatenoise2(lowfrequency, highfrequency, spectrumlevelleft, ...
      spectrumlevelright, 0, 0, duration, gatelength, samplefreq, 0);
indywave2.leftwaveform = indywave2.leftwaveform * sqrt(powerfactor);
indywave2.rightwaveform = indywave2.rightwaveform * sqrt(powerfactor);

% add up
leftwaveform = commonwave.leftwaveform + indywave1.leftwaveform;
rightwaveform = commonwave.rightwaveform + indywave2.rightwaveform;

% save 
output_wave = mwavecreate(leftwaveform, rightwaveform, samplefreq,infoflag);
output_wave.generator = mfilename;     % string containing what code made the stimulus

if infoflag >= 1
   fprintf('storing waveform to workspace as wave structure .. \n');
end;


if infoflag >= 1,
   fprintf('\n');
end;



% the end!
%-----------------------------------------------


