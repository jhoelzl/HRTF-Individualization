function null = mcallccdisplay(correlogram)
% function null = mcallccdisplay(correlogram)
%
%---------------------------------------------------------------
% MATLAB interface for calling Windows 95 program 'ccdisplay.exe'
% for displaying correlograms in three dimensions
%----------------------------------------------------------------
%
% Input parameters:
%    correlogram  = 'correlogram' structure as defined in mccgramcreate.m
%
% Output parameters:
%    none
%
% The program ccdisplay.exe should be in the same directory
% as this function.
% 
% Example;
% to display the previously-made correlogram cc1, type:
% >> mcallccdisplay(cc1);
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

   
   
% set the path to be the same directory as this function
thisfile = which(mfilename);
stringindex = findstr(thisfile, mfilename);
pathname = thisfile(1:stringindex-1);

% define the name of the temporary file
filename='tempmatlab.bcc';

% save correlogram in a ccdisplay.exe-friendly format
ccname = inputname(1);
msaveccdisplay(filename, correlogram, ccname);

% call ccdisplay.exe program and return to MATLAB
executablename='ccdisplay.exe';
fprintf('calling Windows-95 program %s ...\n', executablename);
fprintf('(using path %s)\n', pathname);
[s,w] = dos([pathname,executablename, ' ', filename, ' &']);

fprintf('\n');
fprintf('returning to MATLAB workspace.\n');
fprintf('\n');


% the end!
%------------------------------------------------------------
