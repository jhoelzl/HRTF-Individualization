function output = merbfilterbank(x, fcoefs)
% function output = merbfilterbank(x, fcoefs)
%
%-------------------------------------------------------------------
% Applies a gammatone filterbank to a monaural waveform
%-------------------------------------------------------------------
%
% This is the same as "ERBFilterBank.m" in Malcolm Slaney's
% Auditory Toolbox. 
%
% See mgammatonefilterbank.m for an example.
%
%
% version 1.0 (Jan 20th 2001)
% MAA Winter 2001 
%------------------------------------------------------------
%
% Slaney's comments:
%
% Process an input waveform with a gammatone filter bank. This function 
% takes a single sound vector, and returns an array of filter outputs, one 
% channel per row.
%
% The fcoefs parameter, which completely specifies the Gammatone filterbank,
% should be designed with the MakeERBFilters function.  If it is omitted,
% the filter coefficients are computed for you assuming a 22050Hz sampling
% rate and 64 filters regularly spaced on an ERB scale from fs/2 down to 100Hz.
%

% Malcolm Slaney @ Interval, June 11, 1998.
% (c) 1998 Interval Research Corporation  
% Thanks to Alain de Cheveigne' for his suggestions and improvements.

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




if nargin < 1
	error('Syntax: output_array = ERBFilterBank(input_vector[, fcoefs]);');
end

if nargin < 2
	fcoefs = MakeERBFilters(22050,64,100);
end

if size(fcoefs,2) ~= 10
	error('fcoefs parameter passed to ERBFilterBank is the wrong size.');
end
 
if size(x,2) < size(x,1)
	x = x';
end

A0  = fcoefs(:,1);
A11 = fcoefs(:,2);
A12 = fcoefs(:,3);
A13 = fcoefs(:,4);
A14 = fcoefs(:,5);
A2  = fcoefs(:,6);
B0  = fcoefs(:,7);
B1  = fcoefs(:,8);
B2  = fcoefs(:,9);
gain= fcoefs(:,10);	

output = zeros(size(gain,1), length(x));
for chan = 1: size(gain,1)
	y1=filter([A0(chan)/gain(chan) A11(chan)/gain(chan) ...
		   A2(chan)/gain(chan)], ...
				[B0(chan) B1(chan) B2(chan)], x);
	y2=filter([A0(chan) A12(chan) A2(chan)], ...
				[B0(chan) B1(chan) B2(chan)], y1);
	y3=filter([A0(chan) A13(chan) A2(chan)], ...
				[B0(chan) B1(chan) B2(chan)], y2);
	y4=filter([A0(chan) A14(chan) A2(chan)], ...
				[B0(chan) B1(chan) B2(chan)], y3);
	output(chan, :) = y4;
end

if 0
	semilogx((0:(length(x)-1))*(fs/length(x)),20*log10(abs(fft(output))));
end



% the end!
%--------------------------------------------------