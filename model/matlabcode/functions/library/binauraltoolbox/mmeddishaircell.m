function [output_multichannelprobability] = mmeddishaircell(multichanneldata, haircelltypestring, samplefreq, infoflag)
% function [output_multichannelprobability] = 
% mmeddishaircell(multichanneldata, haircelltypestring, samplefreq, infoflag)
%
%--------------------------------------------------------
% Passes a multichannel mono waveform through the Meddis (1988) haircell.
%--------------------------------------------------------
%
% Input parameters:
%   multichanneldata = first output of mgammatonefilterbank
%   haircelltype     = which spntaneous-rate fiber to use: can be
%                      'high' or
%                      'medium'
%                      (see below)
%   samplefreq       = sampling frequency (Hz)
%   infoflag         = 1: report some information while running
%                      0  dont report anything
%
% Output parameters:
%   output_multichannelprobability = time waveform of probability of firing 
%                            (same format as first output of mgammatonefilterbank)
%
%
% This is Klaus Hartung's super-fast implementation of the BASIC code in
% Meddis Hewitt and Shackleton (1990) JASA vol 87 p. 1813-1816
% "Implementation details of a computation model of the inner hair-cell/
% auditory-nerve synapse", which implements the Meddis (1986, 1988) haircell.
% Its optimised for multichannel MATLAB processing.
%
% Parameters of 'high' haircell taken from Table I (p. 1815)
% Parameters of 'medium' haircell taken from Table II (p. 1815)
%
%
% Thanks to Klaus Hartung for speeding the code up
% 
% version 1.0 (Jan 20th 2001)
% MAA Winter 2001 
%----------------------------------------------------------------

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

   
   
epochlength_secs = 1/samplefreq;  % seconds

[nfilter,nsamples] = size(multichanneldata);
  
initialduration_ms = 10; % milliseconds
endduration_ms     = 10; % milliseconds
if (infoflag >=2)
   fprintf('adding %.1f ms of silence to beginning of signal\n', initialduration_ms);
end;
if (infoflag >=2)
   fprintf('adding %.1f ms of silence to end of signal\n', endduration_ms);
end;
initialduration_samples = initialduration_ms*samplefreq/1000;
endduration_samples = endduration_ms*samplefreq/1000;

initialsilence = zeros(nfilter,initialduration_samples);
endsilence = zeros(nfilter,endduration_samples);

fullwaveform = [initialsilence multichanneldata endsilence];
duration_seconds = length(fullwaveform)/samplefreq;
[nfilter,fullwaveformsamples] = size(fullwaveform);

% Adjust amplitude so that a tone of 30 dB power corresponds
% to a rms level of 1.0. Since all code assumes that rms=1 corresponds
% to a power of 0 dB (=20*log10(1)), it appears that the conversion
% factor is 10^(30/20)
if (infoflag >= 1)
   fprintf('adjusting signal amplitude so power=30 dB => rms= 1.0\n');
end;
fullwaveform = fullwaveform / (10^(30/20));


% define haircell parameters: see Table II in Meddis et al (1990)
switch haircelltypestring
case 'high'
   M = 1;
   A = 5;
   B = 300;
   g = 2000;
   y = 5.05;
   L = 2580;
   r = 6580;
   x = 66.31;
   h = 50000;
   
case 'medium' 
   M = 1;
   A = 10;
   B = 3000;
   g = 1000;
   y = 5.05;
   L = 2500;
   r = 6580;
   x = 66.31;
   h = 50000;
   
otherwise
   fprintf('!abort: unknown haircell type ''%s''\n', haircelltypestring);
   return;
  
end;

% adjust rate using epoch lengths
gdt = g * epochlength_secs;
ydt = y * epochlength_secs;
ldt = L * epochlength_secs;
rdt = r * epochlength_secs;
xdt = x * epochlength_secs;
hdt = h * epochlength_secs;

% Initial values: assume a history of infinite silennce
% so use equations from section V of paper
k = g*A/(A+B);
c = k*y*M / (y*(L+r) + k*L);
q = c*(L+r)/k;
w = c*r/x;
spontrate = (c * hdt)*samplefreq;

if (infoflag >= 1)
   fprintf('assuming infinite history of silence: spontaneous rate = %.0f per second\n', spontrate);
end;

% set initial reservoir contents at spontaneous levels
kt = g * A/(A + B);
q = c * (L+r)/kt;                   % free transmitter
c = M * y * kt / (L*kt + y*(L+r));  % cleft contents
w = c*r/x;                          % reporcessing store

% clear output arrays
probability = zeros(nfilter,fullwaveformsamples);

if (infoflag >= 1)
   fprintf('running for %d samples = %.1f ms ... \n', length(fullwaveform), length(fullwaveform)/samplefreq*1000);
   fprintf('t (ms) = ');
end;

for n = 1:fullwaveformsamples % n = sample number;
   time = n/samplefreq;
   
   if (infoflag >= 1)
      if(mod(n, 1000) == 0)
         fprintf(' %.0f', n/samplefreq*1000);
      end;
      if(mod(n, 20000) == 0)
         fprintf('\n');
      end;
   end;
   

   st = fullwaveform(:,n);
   limiteSt = max(st+A,0);
   kt = (gdt*limiteSt)./(limiteSt+B);
   
   % compute change quantities
   replenish=max(ydt * (M-q),0);
   eject = kt .* q;
   loss = ldt .* c;
   reuptake = rdt .* c;
   reprocess = xdt .* w;
   
   % now update reservoir quantities
   q = q + replenish - eject + reprocess;
   c = c + eject - loss - reuptake;
   w = w + reuptake - reprocess;
   
   probability(:,n) = hdt*c;
   
end;

% return values
output_multichannelprobability = probability;  % multichannel, in same format as made by mgammatonefilterbank


if (infoflag >= 1)
   fprintf('\n');
end;

% the end!
%------------------------------------------------------------------------