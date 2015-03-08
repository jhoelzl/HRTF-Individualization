function null = msaveccdisplay(filename, correlogram, variablename)
% function null = 
% msaveccdisplay(filename, correlogram, variablename)
%
%-------------------------------------------------------------------
% Saves a correlogram in a format that can be read by ccdisplay.exe
%-------------------------------------------------------------------
%
% Input parameters:
%    filename     = where the saved data goes
%    correlogram  = structure as defined in mccgramcreate.m
%    variablename = name of data (eg cc1; saved in output file)
%
% Output parameters:
%    none
%
% Example:
% to save the previously-made correlogram 'cc1' in the file
% 'correlogram1.bcc' and give the variable the name '#1', type:
% >> msaveccdisplay('correlogram1.bcc', cc1, '#1');
%
% See mcallccdisplay.m for another example.
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

   
 
timeid = clock;


% save header ...
fprintf('writing header to %s ...\n', filename);
fid = fopen(filename, 'w');

% this version saves the centerfreqs direct in the correlogram
fprintf('(including filter center frequencies in output file)\n');
%dencf=0;                               

% write the header
fprintf(fid, '#header for ccdisplay file\n');
fprintf(fid, '#matlabname=%s\n', variablename);
fprintf(fid, '#title=%s\n', correlogram.title);
fprintf(fid, '#model=%s\n', correlogram.modelname);
fprintf(fid, '#compression=%s\n', correlogram.transduction);
fprintf(fid, '#freqweight=%s\n', correlogram.freqweight);
fprintf(fid, '#delayweight=%s\n', correlogram.delayweight);
fprintf(fid, '#frequencychannels=%d\n', correlogram.nfilters);
fprintf(fid, '#filterbankcontrol=correlogramindex\n');
fprintf(fid, '#mincf=%.2f\n', correlogram.mincf);
fprintf(fid, '#maxcf=%.2f\n', correlogram.maxcf);
fprintf(fid, '#dencf=%.1f\n', correlogram.density);
fprintf(fid, '#quality=%.5f\n', correlogram.q);
fprintf(fid, '#bwmin=%.5f\n', correlogram.bwmin);
fprintf(fid, '#delaystart_ms=%.3f\n', correlogram.mindelay/1000); % ms not us
fprintf(fid, '#delaystop_ms=%.3f\n', correlogram.maxdelay/1000);  % ditto
fprintf(fid, '#delaysamples=%.3f\n', correlogram.ndelays);
fprintf(fid, '#samplerate=%.0f\n', correlogram.samplefreq);
fprintf(fid, '#date=%dd-%dm-%dy\n', timeid(3), timeid(2), timeid(1));
fprintf(fid, '#time=%dh:%dm:%.0fs\n', timeid(4), timeid(5), timeid(6));
fprintf(fid, '#format=dos\n');
fprintf(fid, '#header created by %s\n', mfilename);
fprintf(fid','#end\n');


% create a (nfilters+1)x(ndelays) array for saving the data and 
% freq axis in
ccdata = zeros(correlogram.nfilters, correlogram.ndelays+1);
% fill the first column with the frequencies in Hz
ccdata(:,1) = correlogram.freqaxishz;
% fill the rest with the data
ccdata(1:correlogram.nfilters , 2:correlogram.ndelays+1) = correlogram.data;

fprintf('writing %dx%d data points to %s ...\n', correlogram.nfilters, correlogram.ndelays, filename);
fwrite(fid, ccdata, 'float32');
fclose(fid);

fprintf('\n');


% the end!
%------------------------------------------------------------
