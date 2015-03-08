function output_wave = mwavecat(wave1, wave2, silence_ms, infoflag);
% function output_wave = 
% mwavecat(wave1, wave2, silence_ms, infoflag);
%
%--------------------------------------------------------------------
% Concatenates two 'wave' signals. A portion of
% silence can be placed in between if needed
%--------------------------------------------------------------------
% 
% Input parameters
%    wave1      = 'wave' structure (goes first in result)
%    wave2      = 'wave' structure (goes second in result)
%    silence_ms = duration of silence to put between waves
%    infoflag   = 1 print some information while running
%                 0 dont print anything
% 
% Output parameters
%    output_wave = 'wave' structure
%
%
% The two waves should have the same duration and sampling rate.
%
%
% Examples:
% to make a 500-Hz diotic tone and a 1000-Hz diotic tone
% and then to put them in sequence, with the 500-Hz tone
% first, followed by the 1000-Hz tone, and separated by
% 250-ms of silence, type:
% >> wave1 = mcreatetone(500, 60, 60, 0, 0, 250, 10, 20000, 1);
% >> wave2 = mcreatetone(1000, 60, 60, 0, 0, 250, 10, 20000, 1);
% >> wave3 = mwavecat(wave1, wave2, 250, 1);
%
%
% to instead put the 1000-Hz first and with no silence
% inbetween, type:
% >> wave1 = mcreatetone(500, 60, 60, 0, 0, 250, 10, 20000, 1);
% >> wave2 = mcreatetone(1000, 60, 60, 0, 0, 250, 10, 20000, 1);
% >> wave3 = mwavecat(wave2, wave1, 0, 1);
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



% check sampling rates
if (wave1.samplefreq ~= wave2.samplefreq)
   fprintf('%s: error! sampling frequency of waves #1 and wave #2 differ:\n', mfilename); 
   fprintf('(samplefreq #1 = %d Hz, samplefreq #2 = %d Hz)\n', wave1.duration_samples, wave2.duration_samples);
   fprintf('\n');
   output_wave = [];
   return;
end;


% concatenate waveforms with silence
if (infoflag >=1)
   fprintf('concatenating waves ... \n');
end;
if (silence_ms >= 0)
   nsamples = silence_ms/1000*wave1.samplefreq;
   silence = zeros(nsamples, 1);
   leftwaveform = [wave1.leftwaveform; silence; wave2.leftwaveform];
   rightwaveform = [wave1.rightwaveform; silence; wave2.rightwaveform];
else
   leftwaveform = [wave1.leftwaveform; wave2.leftwaveform];
   rightwaveform = [wave1.rightwaveform; wave2.rightwaveform];
end;


% create wave = return value
output_wave = mwavecreate(leftwaveform, rightwaveform, wave1.samplefreq, infoflag);


   
% the end
%--------------------------------