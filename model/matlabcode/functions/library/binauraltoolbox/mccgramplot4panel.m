function null = mccgramplot4panel(correlogram, optional_markersize, optional_linewidth)
% function null = mccgramplot4panel(correlogram, optional_markersize, optional_linewidth)
%
%------------------------------------------------------------------
% Plots a binaural correlogram in the 4-panel format 
% used by mcorrelogram.m
%------------------------------------------------------------------
%
% Input parameters
%    correlogram         = 'correlogram' structure as defined in mccgramcreate.m
%    optional_markersize = size of the crosses and asterisks
%    optional_linewidth  = linewidth of the crosses and asterisks
%
% Output parameters:
%    none
%
% The parameters 'optional_markersize' and 'optional_linewidth'
% are used in mccgramplot2dsqrt to plot symbols marking
% the tracks of the maxima. They are optional and do not 
% need to be specified.  The default values are:
%    markersize : 5
%    linewidth  : 1
% If either are set to 0 then the + and * are not plotted
%
%
% Examples:
% to plot a previously-made correlogram cc1, type:
% >> mccgramplot4panel(cc1);
%
% to plot a previously-made correlogram cc1 using super-big 
% and super-wide symbols,
% type:
% >> mccgramplot4panel(cc1, 10, 2);
%
% to plot a previously-made correlogram cc1 but without nay
% symbols, type:
% >> mccgramplot4panel(cc1, 0, 0);
%
%
% See mcorrelogram.m for another example.
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


   
   
% get variable names
programname = mfilename;
waveformname = inputname(1);


% this code is copied from mcorrelogram
screenwidth = 1024; 
screenheight = 768; 
aspectratio = screenwidth/screenheight; % used so a width=height figure actually looks square
figurewidth = 600; % pixels


% define the size  of the upcoming four-panel plots
% matlab's 'position' is a 4-member array: [x y width height]:   
%   (x, y) is of bottom lefthand corner of picture, relative to bottom left-hand corner of screen, in pixels I think
%   (width, height) is of figure, in pixels I think
position_figure1_xy = [100 85];
position_figure2_xy = [120 65];
position_figure3_xy = [140 45];
position_figure1_wh = [figurewidth*aspectratio, figurewidth];
position_figure2_wh = [figurewidth*aspectratio, figurewidth];
position_figure3_wh = [figurewidth*aspectratio, figurewidth];


% plot the correlogram in a variety of forms in figure 
set(gcf, 'Name', [programname, ' : input = ', waveformname, ' ... correlograms']);
set(gcf, 'Position', [position_figure3_xy position_figure3_wh]);


if (correlogram.nfilters > 1)
   fprintf('plotting 3-dimensional correlogram in figure %d.1 using mccgramplot3dmesh \n', gcf);
   subplot(2,2,1);
   mccgramplot3dmesh(correlogram);
   zlabel('Crossproduct');
   title(['3d correlogram']);

   fprintf('plotting 3-dimensional correlogram in figure %d.2 using mccgramplot3dsurf \n', gcf);
   subplot(2,2,2);
   mccgramplot3dsurf(correlogram);
   zlabel('Crossproduct');
   title(['3d correlogram']);

   subplot(2,2,3);
   fprintf('plotting 2-dimensional correlogram in figure %d.3 using mccgramplot2dsqrt \n', gcf);
   if nargin == 1 
      mccgramplot2dsqrt(correlogram);
   else
      mccgramplot2dsqrt(correlogram, optional_markersize, optional_linewidth);
   end;
   zlabel('Crossproduct');
   title(['2d correlogram with local and overall maxima']);

   subplot(2,2,4);
   fprintf('plotting across-freq average in figure %d.4 using mccgramplotaverage \n', gcf);
   mccgramplotaverage(correlogram);
   title(['Across-frequency average']);
end;


if (correlogram.nfilters == 1)
   % plot across-frequency average only as for a single-channel model that is
   % the same as the function in that channel
   subplot(2,2,4);
   fprintf('plotting across-freq average in figure %d.4 using mccgramplotaverage \n', gcf);
   mccgramplotaverage(correlogram);
   title(['Across-frequency average']);
end;


fprintf('\n');



% the end!
%----------------------------------------------------------