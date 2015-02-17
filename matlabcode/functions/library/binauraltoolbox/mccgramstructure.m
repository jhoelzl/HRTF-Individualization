function output_correlogram = mccgramstructure(modelname, transduction, samplefreq, lowfreq, highfreq, filterdensity, nfilters,q, bwmin, mindelay, maxdelay, ndelays, typeswitch);
% function output_correlogram = 
% mccgramstructure(modelname, transduction, samplerate, 
%                  lowfreq, highfreq, filterdensity, 
%                  nfilters, q, bwmin, 
%                  mindelay, maxdelay, ndelays, typeswitch);
%
% -----------------------------------------------------------
% Fills a 'correlogram' structure with data and information.
% More information (data, cfs, delays) is filled in by
% mcorrelogram.m
%-----------------------------------------------------------
% 
% Input parameters:
%    modelname     = string with name of function that created correlogram
%    transduction  = string containing type of neural transduction
%    samplerate    = sampling rate (Hz)
%    lowfreq       = nominal lower freq of filterbank (Hz)
%    highfreq      = nominal lower freq of filterbank (Hz)
%    filterdensity = density of filters (filters per ERB)
%    nfilters      = number of filters
%    q             = q-factor of filters
%    bwmin         = bwmin-factor of filters
%    mindelay      = left-hand edge of delayaxis (usecs)
%    maxdelay      = left-hand edge of delayaxis (usecs)
%    ndelays       = number of delays
%    typeswitch    = 'binauralcorrelogram' or 'autocorrelogram'
%                    (used to set us or ms units in the plots)
% 
% Output parameters:
%    output_correlogram = correlogram structure
%
%
% See mcorrelogram.m for an example.
%
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




cc1.title = '';                 % title string
cc1.type = typeswitch;          % 'binauralcorrelogram' or 'autocorrelogram'
cc1.modelname = modelname;      % string with name of function that created correlogram
cc1.transduction = transduction;% string containing type of compression
cc1.samplefreq = samplefreq;    % sampling rate, Hz

cc1.mincf = lowfreq;            % nominal lower freq of filterbank, Hz
cc1.maxcf = highfreq;           % nominal upper freq of filterbank, Hz
cc1.density = filterdensity;    % density of filters, filters per ERB
cc1.nfilters = nfilters;        % number of filters
cc1.q = q;                      % q factor of filters; see mgammatonefilterbank
cc1.bwmin = bwmin;              % bwmin factor of filters; see mgammatonefilterbank

cc1.mindelay = mindelay;        % left-hand edge of delayaxis, usecs
cc1.maxdelay = maxdelay;        % right-hand edge of delayaxis, usecs
cc1.ndelays = ndelays;          % number of delays

cc1.freqaxishz = zeros(nfilters, 1); % 1xNf vector of filter center frequencies, Hz
cc1.freqaxiserb = zeros(nfilters, 1);% 1xNf vector of filter center frequencies, ERB number
cc1.powerleft = zeros(nfilters, 1);  % 1xNf vector of power in each channel, Hz
cc1.powerright = zeros(nfilters, 1); % 1xNf vector of power in each channel, Hz
cc1.delayaxis = zeros(1, ndelays);   % 1xNd vector of delay points, usecs

cc1.freqweight = 'null';         % string defining what frequency weighting was applied
cc1.delayweight = 'null';        % string defining what delay weighting (=p(tau)) was applied

cc1.data = zeros(nfilters, ndelays); % NfxNd matrix containing points in correlogram
   
   
% return values
output_correlogram = cc1;


   
% the end
%--------------------------------