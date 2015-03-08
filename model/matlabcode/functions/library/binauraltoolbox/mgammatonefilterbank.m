function [output_filteredwaves, output_fbankcfs, output_nfilters, output_lowfreq, output_highfreq, output_q, output_bwmin] = mgammatonefilterbank(lowfreq, highfreq, density, monowaveform, samplefreq, infoflag)
% function [output_filteredwaves, output_fbankcfs, output_nfilters, output_lowfreq, output_highfreq, output_q, output_bwmin] = 
% mgammatonefilterbank(lowfreq, highfreq, density, 
%                      monowaveform, samplefreq, infoflag)
% 
%--------------------------------------------------------
% Filters a monaural waveform using a gammatone filterbank
%--------------------------------------------------------
%
%
% Input parameters:
%   lowfreq    = low freq of filterbank (Hz).
%   highfreq   = nominal upper freq of filterbank (Hz).
%   density    = spacing of filters (filters per ERB).
%   waveform   = inputwaveform, must be mono (*not* a 'wave')
%   samplefreq = sampling freq (Hz)
%   infoflag   = 1: report some information while running
%              = 0  dont report anything
%
% Output parameters:
%   output_filteredwaves: = matrix of time waveforms of filter outputs 
%   output_fbankcfs       = vector of the center frequencies of each channel (Hz)
%   output_nfilters       = number of channels 
%   output_lowfreq        = true lowest center frequency of the filterbank (Hz)
%   output_highfreq       = true highest center frequency of the filterbank (Hz)
%   output_q              = 'q' factor of filters (see mstandarderbparameters.m)
%   output_bwmin          = 'bwmin' parameter of filters (see mstandarderbparameters.m)
%
%
% The value of 'highfreq' is nominal as the actual highest 
% frequency is determined by the spacing of the filters: 
% the present code places them at 1/density from lowfreq,
% with the last filter at (or just above) 'highfreq'.
% The true highfreq is returned in output_highfreq.
%
% If the value of density is equal to 0 then *one* filter 
% is used whose center frequency is equal to lowfreq.
%
%  
% Examples: 
% to apply a gammatone filterbank, from 47.4 to 1694 Hz, using
% 1 filter per ERB, to the left-channel waveform of a 'wave'
% signal, type:
% >> [multichanneloutput, cfs, n, lf, hf, q, bw] = mgammatonefilterbank(47.4, 1690, 1, wave1.leftwaveform, wave1.samplefreq, 1);
% 
% to apply a single gammatone filter at 500 Hz to the
% left-channel waveform of a 'wave' signal, type:
% >> [multichanneloutput, cfs, n, lf, hf, q, bw] = mgammatonefilterbank(500, 1690, 0, wave1.leftwaveform, wave1.samplefreq, 1);
%
% See mcorrelogram.m for another example.
%
% The code is taken from Malcolm Slaney's Auditory Toolbox.
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


% these arrays contain the filter centerfreqs in ERBs and Hz
clear cfarray_erbs;
clear cfarray_hz;


% define the q/bwmin parameters of the filters.
[filter_q, filter_bwmin] = mstandarderbparameters;


if (density == 0)
   % make one filter whose center frequency = lowfreq
   lowfreq_erbs = mhztoerb(lowfreq, filter_q, filter_bwmin, 0);
   cfarray_erbs = lowfreq_erbs;
end;


if (density > 0)
   % make a filterbank
   % centerfreqs are lowfreq_erb
   %                 lowfreq_erb + 1/density
   %                 lowfreq_erb + 2/density
   %                 lowfreq_erb + 3/density, etc
   lowfreq_erbs = mhztoerb(lowfreq, filter_q, filter_bwmin, 0);
   highfreq_erbs = mhztoerb(highfreq, filter_q, filter_bwmin, 0);
   cfarray_erbs = lowfreq_erbs:1/density:highfreq_erbs;
   cfarray_erbs = cfarray_erbs'; % transpose as the output format appears critical
   % add one extra filter to ensure high freq is included in the freq range
   topfreq = cfarray_erbs(size(cfarray_erbs,1));
   cfarray_erbs  = [cfarray_erbs; topfreq+1/density];
end;


% convert those values from ERB number to Hz
nfilters = size(cfarray_erbs,1);
for n=1:nfilters
   cfarray_hz(n) = merbtohz(cfarray_erbs(n), filter_q, filter_bwmin, 0);
end;
cfarray_hz = cfarray_hz'; % transpose as the output format appears critical
   
if infoflag >= 1
   fprintf('gammatone filtering from %.1f to %.1f Hz (=%.2f to %.2f ERB number)\n', lowfreq, max(cfarray_hz), lowfreq_erbs, max(cfarray_erbs))
   fprintf('number of channels = %d \n', nfilters)
   fprintf('density            = %.1f channels per ERB\n', density)
   fprintf('q-factor = %.5f    bwmin = %.3f\n', filter_q, filter_bwmin)
end;


% create the filterbank coefficents
% 'mmakeerbfilters' is the same as MakeERBFilters from Slaney's Auditory Toolbox
fbankcoefs = mmakeerbfilters(samplefreq, cfarray_hz, lowfreq, filter_q, filter_bwmin);
fbankcfs = cfarray_hz;

% apply the filterbank!
% 'merbfilterbank' is the same as ERBFilterbank from Slaney's Auditory Toolbox
output_filteredwaves = merbfilterbank(monowaveform, fbankcoefs);

% get the other return values
output_fbankcfs = cfarray_hz;
output_nfilters = size(cfarray_hz,1);
output_highfreq = max(cfarray_hz);
output_lowfreq = min(cfarray_hz);
output_q = filter_q;
output_bwmin = filter_bwmin;



% the end!
%------------------------------------------------------------------------