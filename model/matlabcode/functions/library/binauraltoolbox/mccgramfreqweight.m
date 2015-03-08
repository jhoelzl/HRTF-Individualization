function [output_correlogram, output_freqweight] = mccgramfreqweight(correlogram, fswitch, infoflag);
% function [output_correlogram, output_freqweight] = 
% mccgramfreqweight(correlogram, fswitch, infoflag);
%
%-------------------------------------------------------------------
% Applies a frequency-weighting function to a correlogram
%-------------------------------------------------------------------
%
% Input parameters:
%    correlogram = 'correlogram' structure as defined in mccgramcreate.m
%    fswitch    = freq weighting function to use: can be
%                  'stern' (    = Stern et al. (1988)
%                  'raatgever'  = Raatgever (1980)
%                  'mld'        = Masking-level difference function (Akeroyd and Summerfield, 1999)
%    infoflag   = 1: report some information while running only
%               = 0  dont report anything
%
% Output parameters:
%    output_correlogram = the input correlogram weighted by p(tau)
%    output_delayweight = the delay-weighting function in a correlogram structure
%
%
% Example:
% to apply Stern et al's weighting to a previously-made correlogram cc1, 
% and store the weighted correlogram in cc2 and the weighting-
% function itself in ccw, type:
% >> [cc2 ccw] = mccgramfreqweight(cc1, 'stern', 1);
%
%
% Citations:
% Akeroyd MA and Summerfield AQ (1999)  "A fully temporal account 
%  of the perception of dichotic pitches," Br. J.Audiol., 33(2), 
%  106-107 . 
% Raatgever, J. (1980).  On the binaural processing of stimuli 
%  with different interaural phase relations, (Doctoral 
%  dissertation, Delft University of Technology, The Netherlands). 
% Stern RM, Zeiberg AS and Trahiotis C (1988).  "Lateralization 
% of complex binaural stimuli: A weighted image model", J. Acoust. 
% Soc. Am., 84, 156-165 (erratum: J. Acoust. Soc. Am., 90, 2202).
%
%
% Thanks to Klaus Hartung for speeding the code up
%
% MAA Winter 2001 2i01
%--------------------------------------------------------

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




% define and clear central-weighting function
% (create by copying then changing input)
freqweight = correlogram;
freqweight.title = 'frequency-weighting function';
freqweight.data = zeros(freqweight.nfilters, freqweight.ndelays); 


switch fswitch
   
case 'raatgever'
   % This is Raatgever's fit to his data representing the dominance 
   % of certain frequencies in binaural localization
   %
   % See Raatgever J (1980) especially p. 64 eq. IV.1
   %
   if (infoflag >= 1)
      fprintf('creating Raatgever''s freq-weighting ...\n');
   end;
   for filter=1:correlogram.nfilters
      freq = correlogram.freqaxishz(filter);   
      if (freq < 600)
         freqweight.data(filter, :) = exp(-1.0 * power(((freq/300.0)-2.0), 2.0));
      else 
         freqweight.data(filter, :) = exp(-1.0 * power(((freq/600.0)-1.0), 2.0));
      end;
   end;
   
   
case 'stern'
   % This is Stern et al's fit to Raatgever's data representing 
   % the dominance of certain frequencies in binaural localization
   %
   % see Stern RM, Zeiberg AS, Trahiotis C (1988) 
   % (especially the q(f) function on p. 160)
   %
   if (infoflag >= 1)
      fprintf('creating Stern et al''s freq weighting function ...\n');
   end;
   for filter=1:correlogram.nfilters
      freq = correlogram.freqaxishz(filter);   
      if freq > 1200
         freq = 1200;
      end;
      b1 = -9.38272e-2;
      b2 = 1.12586e-4;
      b3 = -3.99154e-8;
      pwr = -1*(b1*freq + b2*freq^2 + b3*freq^3);
      answer = power(10.0, pwr/10);
      freqweight.data(filter, :) = answer;
   end;
  
  
case 'mld'
   % this is a fit to the N0S0-N0Spi masking level difference 
   % as a function of frequency 
   %
   % The fit is described in p 12-13 of a poster presented at the
   % BSA Short Papers Meeting on Experimental Studies of 
   % Hearing and Deafness, London, Autumn 1998,
   % A PDF version of the poster can be downloaded from my website/
   %
   % The fit is a 'roex' function which gives a maximum MLD of
   % about 12 dB at 300 Hz
   %
   if (infoflag >= 1)
      fprintf('creating freq-weighting function as fit to N0S0-N0Spi MLD ...\n');
   end;
   roex_p = 0.0046;
   roex_r = 0.125893; % -9 dB 
   roex_reffreq = 300.0; % Hz
   for filter=1:correlogram.nfilters
      freq = correlogram.freqaxishz(filter);   
      freqweight.data(filter, :) = (1.0-roex_r) * (1.0 + (freq - roex_reffreq)*roex_p) ...
         * exp( -1.0 *(freq - roex_reffreq)*roex_p) + roex_r;
   end;
   
   
otherwise
   fprintf('%s: error! unknown frequency-weight ''%s''\n\n', mfilename, fswitch);
   return;
   return;
   
end;


% apply weight (but copy first to get index values ok)
if (infoflag >= 1)
   fprintf('applying function ... \n');
end;
correlogram2 = correlogram;
correlogram2.data = freqweight.data .* correlogram.data;

% reset names
correlogram2.freqweight = fswitch;
freqweight.freqweight = fswitch;
freqweight.modelname = mfilename;

% return values
output_correlogram = correlogram2;
output_freqweight = freqweight;

if infoflag >= 1
   fprintf('\n');
end;
  
  
  
% the end
%----------------------------------
