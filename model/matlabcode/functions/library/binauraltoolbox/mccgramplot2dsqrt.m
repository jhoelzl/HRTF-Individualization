function null = mccgramplot2dsqrt(correlogram, optional_markersize, optional_linewidth)
% function null = 
% mccgramplot2dsqrt(correlogram, 
% optional_markersize, optional_linewidth)
%
%-------------------------------------------------------------------
% Plots a 2d-correlogram with overlaid maxima tracks  
%-------------------------------------------------------------------
%
% Input parameters
%    correlogram         = 'correlogram' structure as defined in mccgramcreate.m
%    optional_markersize = size of the crosses and asterisks
%    optional_linewidth  = linewidth of the crosses and asterisks
%
% Output parameters:
%    none
%
%
% The values in correlogram.data are square-rooted first as this
% looks better for high-frequencies of speech.
% In addition, extra symbols are plotted, marking the tracks
% of the local and overall maxima in each frequency channel:
%     * = overall maximum in each frequency channel
%     + = local (3-point) maxima in each frequency channel
%
% The parameters 'optional_markersize' and 'optional_linewidth'
% are optional and do not need to be specified.  The default values 
% are:
%    markersize : 5
%    linewidth  : 1
% If either are set to 0 then the + and * are not plotted
%
% 
% Examples:
% to plot a previously-made correlogram cc1, type:
% >> mccgramplot2dsqrt(cc1);
%
% to plot a previously-made correlogram cc1 using super-big 
% and super-wide symbols,
% type:
% >> mccgramplot2dsqrt(cc1, 10, 2);
%
% to plot a previously-made correlogram cc1 but without nay
% symbols, type:
% >> mccgramplot2dsqrt(cc1, 0, 0);
%
% See mccgramplot4panel.m for another example.
%
%
%
% Thanks to Chris Darwin for this code.
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


   
   
hold off;

if nargin == 1 
   % defaults for asterisks/stars
   markersize = 5;
   linewidth = 1;
else
   % the values are defined in the command line
   markersize = optional_markersize;
   linewidth = optional_linewidth;
end;

% correct the data for the sqrt transform
plotdata = zeros(correlogram.nfilters, correlogram.ndelays);
for f=1:correlogram.nfilters
   for d=1:correlogram.ndelays
      if (correlogram.data(f, d) >= 0)
         plotdata(f, d) = sqrt(correlogram.data(f, d));
      else
         plotdata(f, d) = -1 * sqrt(-1*correlogram.data(f, d));
      end;
   end;
end;

% plot!
pcolor(correlogram.delayaxis, correlogram.freqaxiserb, plotdata);
hold on;
colormap(jet);
shading('interp');

switch correlogram.type
case 'binauralcorrelogram' ; 
   title('Binaural correlogram');
case 'autocorrelogram' ; 
   title('Autocorrelogram');
end;

% reset freq axes to filterbank limits
oldaxes = axis;
[filter_q, filter_bwmin] = mstandarderbparameters;
xmin = correlogram.mindelay;  
xmax = correlogram.maxdelay;  
ymin = mhztoerb(correlogram.mincf,filter_q, filter_bwmin, 0);
ymax = mhztoerb(correlogram.maxcf,filter_q, filter_bwmin, 0);
axis([xmin xmax ymin ymax]);
maxislabels_freq('ytick', 'yticklabel');
ylabel('Frequency (Hz)');
maxislabels_delay(correlogram.type);

% get both types of maxima
maximums=[];
for filter=1:correlogram.nfilters,
   bestpeak = -99999;
   bestposition = -99999;
   for delay=2:(correlogram.ndelays-1)
      % plot local maxima as '+'
      if ((correlogram.data(filter, delay) > correlogram.data(filter, delay+1)) & ...
            (correlogram.data(filter, delay) > correlogram.data(filter, delay-1)))
         if ((markersize <= 0) | (linewidth <= 0))
            % dont plot
         else
            plot(correlogram.delayaxis(delay), correlogram.freqaxiserb(filter), 'w+', 'Linewidth', linewidth, 'Markersize', markersize);
         end;
      end;
      if (correlogram.data(filter, delay) > bestpeak)
         bestpeak = correlogram.data(filter, delay);
         bestposition = delay;
      end;
   end;
   % plot local maxima as '*'  
   if ((markersize <= 0) | (linewidth <= 0))
      % dont plot if size of width = 0
   else
      % do plot
      plot(correlogram.delayaxis(bestposition), correlogram.freqaxiserb(filter), 'w*', 'Linewidth', linewidth, 'Markersize', markersize);
   end;
end;

hold off



% the end!
%---------------------------------------------------------------------------
