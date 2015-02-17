function output_wave = mwavecreate(leftwaveform, rightwaveform, samplefreq, infoflag);
% function output_wave = ...
% mwavecreate(leftwaveform, rightwaveform, samplefreq, infoflag);
%
% ------------------------------------------------------------------
% Fills a 'wave' structure with a stereo waveform
%-------------------------------------------------------------------
% 
% Input parameters:
%    leftwaveform  = waveform for left channel
%    rightwaveform = waveform for right channel
%    samplefreq    = sampling rate, Hz
%    infoflag:     = 1 print some information while running
%                    0 dont print anything
% 
% Output parameters:
%    output_wave   = 'wave' structure
%
% 
% Example: 
% to create 1 cycle of a diotic sinusoid and then
% store as a 'wave', type:
% >>  leftwaveform  = sin(0:0.01:2*pi);  
% >>  rightwaveform = sin(0:0.01:2*pi);
% >>  wave1 = mwavecreate(leftwaveform, rightwaveform, 20000, 1);
%
%
% The two waveforms should have the same length.
%
%
% version 1.0 (January 20th 2001)
% MAA Winter 2001 
%--------------------------------

% ******************************************************************
% This MATLAB software was developed by Michael A Akeroyd for 
% supporting research at the University of Connecticut
% and the University of Sussex.  It is made available
% in the hope that it may prove useful. 
% 
% Any for-profit use or redistribution is prohibited. No warranty
% is expressed or implied. All rights reserved.
% 
%    Contact address:
%      Dr Michael A Akeroyd,
%      Laboratory of Experimental Psychology, 
%      University of Sussex, 
%      Falmer, 
%      Brighton, BN1 9QG, 
%      United Kingdom.
%    email:   maa@biols.susx.ac.uk 
%    webpage: http://www.biols.susx.ac.uk/Home/Michael_Akeroyd/
%  
% ******************************************************************


% transpose if necessary
if (size(leftwaveform, 2) > 1)
   if infoflag >= 1
      fprintf('transposing left waveform ...\n');
   end;
   leftwaveform = leftwaveform';
end;
if (size(rightwaveform, 2) > 1)
   if infoflag >= 1
      fprintf('transposing right waveform ...\n');
   end;
   rightwaveform = rightwaveform';
end;


% abort if different durations
if length(leftwaveform) ~= length(rightwaveform)
   fprintf('%s: error! length of left and right waveforms is not the same:\n', mfilename); 
   fprintf('(left length = %d samples, right: length = %d samples)\n', length(leftwaveform), length(rightwaveform));
   fprintf('\n');
   output_wave = [];
   return;
end;


% measure values on waveforms
duration_samples = length(leftwaveform);
duration_ms = duration_samples/samplefreq*1000;

rmsamp1 = sqrt(mean(leftwaveform .* leftwaveform));
linearpower1 = mean(leftwaveform .* leftwaveform);
linearenergy1 = linearpower1*(duration_ms/1000);

rmsamp2 = sqrt(mean(rightwaveform .* rightwaveform));
linearpower2 = mean(rightwaveform .* rightwaveform);
linearenergy2= linearpower2*(duration_ms/1000);


% stop the dB conversion later from crashing by adding a 
% small constant
linearpower1 = linearpower1 + 1e-99;
linearpower2 = linearpower2 + 1e-99;
linearenergy1 = linearenergy1 + 1e-99;
linearenergy2 = linearenergy2 + 1e-99;


%------------------------------------------------------

% create data structure
if infoflag >= 1
   fprintf('creating ''wave'' structure ...\n');
end;
wave.generator = mfilename;               % string containing what code made the stimulus
wave.leftwaveform = leftwaveform;         % string with name of matlab code that created correlogram
wave.rightwaveform = rightwaveform;       % string with name of matlab code that created correlogram
wave.samplefreq = samplefreq;             % sampling rate, Hz

wave.duration_samples = duration_samples; % duration, samples
wave.duration_ms = duration_ms;           % duration, msecs

wave.leftmax = max(wave.leftwaveform);          % maximum amplitude
wave.leftmin = min(wave.leftwaveform);          % minimum amplitude
wave.leftrms = rmsamp1;                         % rms amplitude
wave.leftpower_db = 10.0*log10(linearpower1);   % power in signal, dB
wave.leftenergy_db = 10.0*log10(linearenergy1); % energy in signal, dB

wave.rightmax = max(wave.rightwaveform);        % maximum amplitude
wave.rightmin = min(wave.rightwaveform);        % minimum amplitude
wave.rightrms = rmsamp2;                        % rms amplitude
wave.rightpower_db = 10.0*log10(linearpower2);  % power in signal, dB
wave.rightenergy_db = 10.0*log10(linearenergy2);% energy in signal, dB
   
wave.overallmax = max([abs(wave.leftmin), abs(wave.leftmax), abs(wave.rightmin), abs(wave.leftmax)]);  
                                                 % largest sample value, irrespective of sign
                                                 
% get normalized correlation of left and right waveformrs as well
% (must come near end as mnormcorr takes a 'wave' stucture as input)   
wave.normalizedrho = mwavenormcorr(wave, 0);     % normalized correlation


%------------------------------------------------

if infoflag >= 1
   fprintf('waveform statistics : \n');
   fprintf('  samplingrate                = %.0f Hz\n'         , wave.samplefreq);
   fprintf('  power (left, right)         = %.1f dB  %.1f dB\n', wave.leftpower_db, wave.rightpower_db);
   fprintf('  energy (left, right)        = %.1f dB  %.1f dB\n', wave.leftenergy_db, wave.rightenergy_db);
   fprintf('  maximum (left, right)       = %.1f     %.1f   \n', max(wave.leftmax), max(wave.rightmax));
   fprintf('  minimum (left, right)       = %.1f     %.1f   \n', min(wave.leftmin), min(wave.rightmin));
   fprintf('  rms amplitude (left, right) = %.1f     %.1f   \n', min(wave.leftrms), min(wave.rightrms));
   fprintf('  duration                    = %d samples = %.2f msecs\n', wave.duration_samples, wave.duration_ms);
   fprintf('  normalized correlation      = %.4f\n', wave.normalizedrho);
end;


% return values
output_wave = wave;

  
% the end
%--------------------------------