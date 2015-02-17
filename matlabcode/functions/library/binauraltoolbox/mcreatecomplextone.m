function output_wave = mcreatecomplextone(parameterfile, overallgain_db, gatelength_ms, samplefreq, infoflag)
% function output_wave = 
% mcreatecomplextone(parameterfile, overallgain_db, 
%                    gatelength_ms, samplefreq, infoflag)
% 
%-------------------------------------------------------------------
% Makes a complex tone with parameter values determined 
% by a text file
%-------------------------------------------------------------------
% 
% Input parameters:
%    parameterfile = text file containing specifications of each 
%                      component of the complex
%    overallgain_db= additional gain applied to all components (dB)
%    gatelength_ms = length of raisedcosine onset/offset, applied to 
%                      each component *before* adding up for the 
%                      sum (milliseconds)
%    samplefreq    = sampling frequency, Hz
%    infoflag      = 1 : print some information while running
%                    0 : dont print anything
%
% Output parameters:
%    output_wave = 'wave' structure, using the format defined 
%                  in mwavecreate.m
%
%
% Ordering of values in each line of the parameter file is:
%   freq         Hz
%   level(left)  dB
%   level(right) dB
%   phase        degrees (assumes 'sin' generator)(-999 is code for random)
%   starttime    msecs
%   end          msecs
%   itd          usecs
%   ipd          degrees
% All lines in the parameter file beginning with '%' are ignored
%
% 
% Example:
% to create a complex tone with parameters defined by 
% 'complextonefile1.txt', with 0-dB overall gain, 10-ms raised-cosine
% gates and 20000-Hz sampling rate, type:
% >> wave1 = mcreatecomplextone('complextonefile1.txt', 0, 10, 20000, 1);
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



if infoflag == 1
   fprintf('This is %s.m\n', mfilename);
end;
   
% abort if no output specified 
if nargout ~= 1 
   fprintf('%s: error! one output argument must be specified\n\n', mfilename); 
   output_wave = [];
   return;
end;
   

%----------------------------------
   
sampleduration=1/samplefreq;

% load parameters
parameter = load(parameterfile);
ncomps = size(parameter, 1);

% sort the parameter file into ascending-frequency order
parameter = sortrows(parameter, [1]);

freqlist = parameter(:,1); % Hz
powerleftlist = parameter(:,2); % overall, dB
powerrightlist = parameter(:,3); % overall, dB
phaselist = parameter(:,4); % degs (-999 is code for random phase)
startlist = parameter(:,5); % ms
endlist = parameter(:,6); % ms
itdlist = parameter(:,7); % usecs
ipdlist = parameter(:,8); % ms

overallgain_amp = 10^(overallgain_db/20);

% get longest duration
maxduration_ms = max(endlist);
nsamples = maxduration_ms / 1000 * samplefreq;

% abort if the duration is 0 
if nsamples == 0 
   output_stereowaveform = [];
   return;
end;

signalsum_l = linspace(0,0,nsamples);
signalsum_r = linspace(0,0,nsamples);


%---------------------------------
% make each component ... 

if infoflag == 1
   fprintf('  freq (left|right starting phase) (left|right level, gain) itd|ipd  start|end times\n');
end;
   
for n = 1:ncomps
   
   % define real time of each sample
   duration_ms = endlist(n) - startlist(n);
   localnsamples = duration_ms / 1000 * samplefreq;
   startsilencesamples = startlist(n) / 1000 * samplefreq;
   endsilencesamples = nsamples - localnsamples - startsilencesamples;
   sampletime = 0:sampleduration:((localnsamples-1)*sampleduration);

   % define powers
   % get amplitude of tone
   amplitudeleft = 10^(powerleftlist(n)/20) * sqrt(2);
   amplituderight = 10^(powerrightlist(n)/20) * sqrt(2);
   amplitudeleft = amplitudeleft * overallgain_amp;
   amplituderight = amplituderight * overallgain_amp;
      
   % define phases
   freq = freqlist(n);
   angularfreq=2*pi*freq;
   
   % convert IPD to a time delay
   itd = itdlist(n);
   ipd = ipdlist(n);
   trueitd = itd + (1000000/freq)*ipd/360.0; % usecs

   % set ITD so that right leads left (and its in microsecs)
   phase_left = 0; % radians
   phase_right = phase_left + (2*pi*trueitd/(1000000/freq)); % radians
 
   if infoflag == 1
      fprintf('%d: %.0f Hz  (%.3f %.3f rads)  (%.2f %.2f +%.2f dB)   %.0f|%.0f us|degs    start|end = %.0f %.0f ms\n', n, freq, phase_left, phase_right, powerleftlist(n), powerrightlist(n), overallgain_db, itd, ipdlist(n), startlist(n), endlist(n));
   end;
 
   % make left and right channels
   tone_l = amplitudeleft * sin(angularfreq.*sampletime + phase_left);
   tone_r = amplituderight * sin(angularfreq.*sampletime + phase_right);
   
   % gate using raised cosines 
   if (gatelength_ms > 0)
      onsetlength_samples = gatelength_ms*samplefreq/1000;  %gate length is in msecs
      offsetlength_samples = onsetlength_samples;
      onsetgate = 0:1:onsetlength_samples-1;
      onsetgate = 0.5 - 0.5*cos(pi*(mod(onsetgate, onsetlength_samples)/onsetlength_samples));
      offsetgate = 0:1:offsetlength_samples-1;
      offsetgate = 0.5 - 0.5*cos(pi*(mod(offsetgate, offsetlength_samples)/offsetlength_samples));
      offsetgate = fliplr(offsetgate);
      middlegate = linspace(1,1, (localnsamples - onsetlength_samples - offsetlength_samples));  
      gate = [onsetgate, middlegate, offsetgate];
      signal_l = tone_l.*gate;
      signal_r = tone_r.*gate;
   else
      signal_l = tone_l;
      signal_r = tone_r;
   end;
   
   % add the silences
   if startsilencesamples > 0 
      silence = linspace(0,0,startsilencesamples);
      signal_l = [silence signal_l];
      signal_r = [silence signal_r];
   end;
   if endsilencesamples > 0 
      silence = linspace(0,0,endsilencesamples);
      signal_l = [signal_l silence];
      signal_r = [signal_r silence];
   end;
      
   % add to wave
   signalsum_l = signalsum_l + signal_l;
   signalsum_r = signalsum_r + signal_r;
   
end;
   
   
%---------------------------------------------------



% store 
output_wave = mwavecreate(signalsum_l, signalsum_r, samplefreq,infoflag);
output_wave.generator = mfilename;

if infoflag >= 1
   fprintf('storing waveform to workspace as wave structure .. \n');
end;


if infoflag >= 1,
   fprintf('\n');
end;


% the end 
%--------------------------------------------