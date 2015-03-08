function f_hz = merbtohz(f_erb, q, bwmin, infoflag)
% function f_hz = 
% merbtohz(f_erb, q, bwmin, infoflag)
%
% ----------------------------------------------------------------
% Transforms a frequeny from units of ERB number to units of Hz
%-----------------------------------------------------------------
% 
% Input parameters:
%   f_erb     = frequency (ERB number)
%   q        = q factor 
%   bwmin    = bwmin factor
%   infoflag = 1  report answer to terminal window as well 
%              0 dont report anything
%
% Output parameters:
%   f_hz    = frequency (Hz)
%
% If values of -1 are used for 'q' or 'bwin' then the
% standard values (9.3, 24.7, respectively) are used instead
%
% Example:
% to convert 10.746 from ERB number to Hz, using the 
% standard values of q and bwmin, type:
% >> f_hz = merbtohz(10.746, -1, -1, 1);
% or
% >> [q bw] = mstandarderbparameters;
% >> f_hz = merbtohz(10.746, q, bw, 1);
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

   
   
% Glasberg/Moore eqn (see p. 138, 'erbtofq' function in
% Glasberg BR and Moore BCJ (1990). "Derivation of auditory filter 
% shapes from notched-noise data," Hearing Research, 47,103-138.
% c1 = 24.673;
% c2 = 4.368;
% c3 = 1000*log(10)/(c1*c2); % natural log
% f_hz = 1000*((10^(f_erb/c3)-1.0)/c2);


if q == -1
   [q  blank] = mstandarderbparameters;
end;
if bwmin == -1
   [blank bwmin] = mstandarderbparameters;
end;


f_hz = q * bwmin * (exp(f_erb/q) -1);


if infoflag == 1
   fprintf('%.1f ERBs -> %.3f Hz\n', f_erb, f_hz);
   fprintf('\n');
end;
   
   
% the end
%--------------------------------