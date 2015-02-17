function [output_q, output_bwmin] = mstandarderbparameters()
% function [output_q, output_bwmin] = 
% mstandarderbparameters()
%
% -----------------------------------------------------------------
% Returns the q-factor and bwmin values used in the Glasberg and 
% Moore (1990) ERB function
% q = 9.3; bwmin = 24.7
%------------------------------------------------------------------
% 
% Input parameters:
%   none
%
% Output parameters
%   q     = quality factor
%   bwmin = minimum bandwidth, hz
%
% Example:
% >> [q bw] = mstandarderbparameters;
%
% Citations: 
% Glasberg BR and Moore BCJ (1990). "Derivation of auditory filter 
% shapes from notched-noise data," Hearing Research, 47,103-138.
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



% the Glasberg & Moore (1990) equation for relating a frequency 
% in Hz to a frequency in ERB number is
%
% F_erb = 1000*ln(10) * log(4.368*F_hz + 1)
%         -----------       -------
%         24.673*4.368       1000
%
%       = 21.3log(4.7*F_hz + 1)
%                 -------
%                  1000
%
% The Holdsworth/Patterson parameterisation of this is
%
% F_erb = q * ln(F_hz + 1)
%               -----
%                bw.q
%
% where q is the 'quality factor' and bw is 'bwmin' or the 
% minimum bandwidth.
%
% Thus the values of q and bwemin are given by
%
% q =    1000          
%     ------------
%     24.673*4.368
%
% bwmin =    1000     
%         ---------
%         4.368 * q


output_q = 1000/(24.673*4.368);
output_bwmin = 1000/(4.368*output_q);


% For the Glasberg & Moore (1990) values, these equations give:
%   q     =  9.2789
%   bwmin = 24.673
%
% The values used in Slaney's Auditory Toolbox were:
%   q     =  9.26449
%   bwmin = 24.7
%
% The values in the UNIX version of AIM were
%   q     =  9.265
%   bwmin = 24.7              
 


% the end
%--------------------------------