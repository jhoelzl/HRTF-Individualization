function null = mwaveplot(wave, channelflag, starttime, endtime)
% function null = mwaveplot(wave, channelflag, starttime, endtime)
%
%------------------------------------------------------------------
% Plots (and reports some statistics) of a 'wave' signal
%------------------------------------------------------------------
%
% Input parameters:
%    wave        = 'wave' signal
%    channelflag = 'stereo' plot both channels
%                  'left'   plot left channel only
%                  'right'  plot right channel only
%    startime    = starting point of plot (milliseconds) (see below)
%    endtime     = ending point of plot (milliseconds) (see below)
%
% Output paramerss:
%    none
%
% Figures:
%    figure 1 plots the waveforms
%
%
% Then startime and endtime are specified in ms.  If a value of -1
% is used for 'starttime' then the plot starts at t=0. If a
% value of -1 is used for the end time the plot ends at the actual
% end of the waveform
%
% 
% Examples: 
% to plot the full waveform of both channels of a previously-made 
% signal wave1 (see mcreatetone), type:
% >> mwaveplot(wave1, 'stereo', -1, -1);
%
% to plot the left channel only, type:
% >> mwaveplot(wave1, 'left', -1, -1);
%
% to plot the first 10-ms of both channels, type:
% >> mwaveplot(wave1, 'stereo', 0, 10);
%
% to plot the last 10-ms of both channels, type:
% >> mwaveplot(wave1, 'stereo', wave1.duration_ms-10, -1);
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

   
   
programname = mfilename;
waveformname = inputname(1);
   

% make a time vector for uses as the x-axis
% subtract one because the first sample is at t=0
timeaxis_samples = (1:1:length(wave.leftwaveform)) -1;
timeaxis_ms = timeaxis_samples/wave.samplefreq*1000;

% get correct range of plot
if starttime == -1
   starttime_samples = 0;
else    
   starttime_samples = starttime/1000*wave.samplefreq;
end;
if endtime == -1
   endtime_samples = wave.duration_samples;
else    
   endtime_samples = endtime/1000*wave.samplefreq;
end;
% give some sensible values if hose values are outside the range
if starttime_samples <0 
   starttime_samples = 0;
end;
if endtime_samples > wave.duration_samples
   endtime_samples = wave.duration_samples;
end;
if endtime_samples <= starttime_samples
   fprintf('%s: error! starttime must be < enddtime \n\n', mfilename);
   fprintf('\n'); 
   return;
end;      
plotstart = starttime_samples/wave.samplefreq*1000;
plotend = endtime_samples/wave.samplefreq*1000;

% because vectors start indexing at 1
starttime_samples = starttime_samples+1;

plotxaxis = timeaxis_ms(starttime_samples:endtime_samples);
plotyaxis1 = wave.leftwaveform(starttime_samples:endtime_samples);
plotyaxis2 = wave.rightwaveform(starttime_samples:endtime_samples);


% clear figure
close;

% define size of plot 
% (these values are the same as those in mcorrelogram)
screenwidth = 1024; 
screenheight = 768; 
aspectratio = screenwidth/screenheight; % used so a width=height figure actually looks square
figurewidth = 600; % pixels
position_figure1_xy = [100 85];
position_figure1_wh = [figurewidth*aspectratio, figurewidth];


% plot pictures of waveform
switch channelflag
   
case 'stereo'
   figure(1);
   set(gcf, 'Name', [programname, ' : input = ', waveformname, ' ... waveforms']);
   set(gcf, 'Position', [position_figure1_xy position_figure1_wh]);
   subplot(2,1,1);
   plot(plotxaxis, plotyaxis1);
   axesrange = axis;
   axesrange(1) = plotstart; 
   axesrange(2) = plotend; 
   axesrange(3) = -1*wave.overallmax;
   axesrange(4) = wave.overallmax;
   axis(axesrange);
   xlabel('Time (ms)');
   ylabel('Amplitude');
   title('Left waveform');
   
   subplot(2,1,2);
   plot(plotxaxis, plotyaxis2);
   axesrange=axis;
   axesrange(1) = plotstart; 
   axesrange(2) = plotend; 
   axesrange(3) = -1*wave.overallmax;
   axesrange(4) = wave.overallmax;
   axis(axesrange);
   xlabel('Time (ms)');
   ylabel('Amplitude');
   title('Right waveform');
   
case 'left'
   figure(1);
   set(gcf, 'Name', [programname, ' : input = ', waveformname, ' ... waveforms']);
   set(gcf, 'Position', [position_figure1_xy position_figure1_wh]);
   plot(plotxaxis, plotyaxis1);
   axesrange=axis;
   axesrange(1) = plotstart; 
   axesrange(2) = plotend; 
   axesrange(3) = -1*wave.overallmax;
   axesrange(4) = wave.overallmax;
   axis(axesrange);
   xlabel('Time (ms)');
   ylabel('Amplitude');
   title('Left waveform');
   
case 'right'
   figure(1);
   set(gcf, 'Name', [programname, ' : input = ', waveformname, ' ... waveforms']);
   set(gcf, 'Position', [position_figure1_xy position_figure1_wh]);
   plot(plotxaxis, plotyaxis2);
   axesrange=axis;
   axesrange(1) = plotstart; 
   axesrange(2) = plotend; 
   axesrange(3) = -1*wave.overallmax;
   axesrange(4) = wave.overallmax;
   axis(axesrange);
   xlabel('Time (ms)');
   ylabel('Amplitude');
   title('Right waveform');
   
otherwise
   fprintf('%s: error! invalid channelflag ''%s''\n', mfilename, channelflag);
   fprintf('\n'); 
   return;
end;



  
   
   
% the end!
%-------------------------------------------------
