function output_correlation = mwavenormcorr(wave, infoflag);
% function output_correlation = 
% mwavenormcorr(wave, infoflag);
%
% --------------------------------------------------
% returns the normalized correlation of a 'wave' signal
% -------------------------------------------------
%
% Input:
%  wave        =  input wave structure
%  infoflag        = 1: report some information while running only
%                  = 0  dont report anything
%
% Outputs:
%  output_correlation: normalized correlation
% 
% Example: 
% to measure the normalized correlation of a previously-made 'wave'
% signal 'wave1' (e.g., mcreatetone), type:
% >> rho = mwavenormcorr(wave1, 1);
%
% For another example see mwavecreate.m
%
%
% The normalized correlation is 
%                 sum(left(n) x right(n)
%   rho = ------------------------------------
%         sqrt(sum(left(n)^2)) * sqrt(sum(right(n)^2))
%
% see Bernstein LR and Trahiotis C (1996)
% "On the use of the normalized correlation as an index of
% interaural envelope correlation"
% J. Acoust. Soc. Am., 100, 1754-1763.
%
%
% Thanks to Les Bernstein for supplying this function
%
%
% version 1.0 (January 20th 2001)
% MAA Winter 2001 
%--------------------------------------------------------

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


numerator = sum(wave.leftwaveform.*wave.rightwaveform);
denominator = ((sum(wave.leftwaveform.^2))^0.5.*(sum(wave.rightwaveform.^2))^0.5);

if (denominator ~= 0)
   rho = numerator/denominator;
else % no signal. so give a silly value
   rho = -999999;
end;


if (infoflag >= 1)
   fprintf('normalized correlation = %.4f\n', rho);
   fprintf('\n');
end;


%------------------------------------

% return values
output_correlation = rho;


% the end!
%-----------------------------------------------