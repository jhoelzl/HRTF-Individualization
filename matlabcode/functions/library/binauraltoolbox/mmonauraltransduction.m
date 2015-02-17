function [multichanneldata2, output_powervector, output_maxvector] = mmonauraltransduction(multichanneldata, transduction, samplerate, infoflag);
% function [multichanneldata2, output_powervector, output_maxvector] = 
% mmonauraltransduction(multichannelinput, transduction, 
%                       samplerate, infoflag);
% 
%----------------------------------------------------------------
% Applies a model of neural transduction to the multichannel
% output of a gammatone filterbank.
%-----------------------------------------------------------------
%
% Input parameters:
%   multichanneldata  = first output of mgammatonefilterbank
%   transduction      =  type of neural transduction applied to the 
%                        output of the gammatone filters. Can be one of:
%                     'linear'       = dont do anything
%                     'hw'           = linear + halfwave rectification
%                     'log'          = halfwave rectification + log compression
%                     'power'        = halfwave rectification + power-law (^0.4) compression of waveform
%                     'envelope'     = halfwave rectification + power-law (^0.2 then ^2) compression of envelope
%                     'v=3'          = halfwave rectification + power-law (^3) expansion of waveform
%                     'meddishigh'   = Meddis et al (1990) haircell, high-spontaneous rate
%                     'meddismedium' = Meddis et al (1990) haircell, medium-spontaneous rate
%  samplerate        = sampling frequency (Hz)
%  infoflag          = 1: report some information while running
%                    = 0  dont report anything
%
% Output:
%   multichanneldata2  = transduced input, same format as first output of mgammatonefilterbank
%   output_powervector = power in each channel (dB)  
%                         (measured *after* transduction)
%   output_maxvector   = maximum value in each channel
%                         (measured *after* transduction)
% 
% See mcorrelogram.m for another example.
%
%
% Citations:
% 'v=3' expansion
% Shear GD (1987) "Modeling the dependence of auditory lateralization
% on frequency and bandwidth", (Masters thesis, Department of 
% Electrical and Computer Engineering, Carnegie-Mellon 
% University, Pittsburgh)
% Stern RM and Shear GD (1996). "Lateralization and detection of 
% low-frequency binaural stimuli: Effects of distribution of 
% internal delay", J. Acoust. Soc. Am., 100, 2278-2288
%
%
% Envelope compression:
% Bernstein LR and Trahiotis C (1996)"The normalized correlation:
% Accounting for binaural detection across center frequency,"
% J. Acoust. Soc. Am., 100, 3774-3784.
% Bernstein LR, van de Par S, and Trahiotis C (1999) "The 
% normalized correlation: Accounting for NoSpi thresholds 
% obtained with Gaussian and 'low-noise' masking noise," 
% J. Acoust. Soc. Am., 106, 870-876.
%
%
% Meddis haircell :
% Meddis R (1986). "Simulation of mechanical to neural transduction
%  in the auditory receptor," J. Acoust. Soc. Am. 79, 702-711.
% Meddis R (1988). "Simulation of auditory-neural transduction: 
%  Further studies," J. Acoust. Soc. Am. 83, 1056-1063.
% Meddis R Hewitt M and Shackleton TM (1990). "Implementation 
%  details of a computational model of the inner-haircell/
%  auditory-nerve synapse," J. Acoust. Soc. Am. 87, 1813-1816.
%
%
% Thanks to Klaus Hartung for speeding the code up.
% Thanks to Les Bernstein for supplying the envelope-compression code.
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



switch transduction
   
case 'linear'
   % dont do anything
   if infoflag >= 1
      fprintf('''%s'' = not doing anything ... \n', transduction);
   end;
   multichanneldata2 = multichanneldata;
      
      
case 'hw'
   % halfwave rectify 
   if infoflag >= 1
      fprintf('''%s'' = halfwave rectification only ... \n', transduction);
   end;
   multichanneldata2 = mhalfwaverectify(multichanneldata);
   
   
case 'log'
   % halfwave rectify then log compression
   if (infoflag >= 1)
      fprintf('''%s'' = halfwave rectification then 20*log10 compression \n', transduction);
      fprintf('(assuming all values <1 become 0.0) ... \n');
   end;
   multichanneldata = mhalfwaverectify(multichanneldata);
   multichanneldata2 = multichanneldata;
   temp1 = find(multichanneldata2 < 1);
   multichanneldata2(temp1) = ones(size(temp1));
   multichanneldata2 = 20*log10(multichanneldata2);
   

   
case 'power'
   % halfwave rectify then powerlaw compression of waveform
   compress1 = 0.4;
   if infoflag >= 1
      fprintf('''%s'' = halfwave rectification then power-law compression (to %.1f) ... \n', transduction, compress1);
   end;
   multichanneldata = mhalfwaverectify(multichanneldata);
   multichanneldata2 = multichanneldata .^ compress1;
   
   
case 'v=3'
   % halfwave rectify then powerlaw expansion of waveform
   % Included as Shear (1987) used it.
   compress1 = 3;
   if infoflag >= 1
      fprintf('''%s'' = halfwave rectification then power-law expansion (to %.1f) ... \n', transduction, compress1);
   end;
   multichanneldata = mhalfwaverectify(multichanneldata);
   multichanneldata2 = multichanneldata .^ compress1;
   
   
case 'envelope'
   % halfwave rectify then full envelope compression ...
   %
   % The envelope compression itself is from Bernsten, van de Par
   % and Trahiotis (1996, especially the Appendix). The
   % lowpass filtering is from Berstein and Trahiotis (1996,
   % especially eq 2 on page 3781). 
   %
   % envelope compression using Weiss/Rose lowpass filter
   compress1 = 0.23;
   compress2 = 2.0;
   if (infoflag >= 1)
      fprintf('''%s'' = envelope compression (to %.2f) then halfwave rectification (to %.2f) ... \n', transduction, compress1, compress2);
   end;
   % define lowpass filter
   cutoff = 425; %Hz
   order = 4;
   if (infoflag >= 1)
     fprintf('(including %.0f-Hz cutoff %d-order lowpass filter)\n', cutoff, order);
   end;
   lpf = linspace(0, samplerate/2, 10000);
   f0 = cutoff * (1./ (2.^(1/order)-1).^0.5);
   lpmag = 1./ (1+(lpf./f0).^2) .^ (order/2);
   lpf=lpf ./ (samplerate/2);
   f=[lpf];
   m=[lpmag];
   lowpassfiltercoefficients = fir2(256, f, m, hamming(257));
   % compress each filter! 
   if (infoflag >= 1)
      fprintf('doing frequency channel # ');
   end;
   nfilters = size(multichanneldata, 1);
   for filter=1:nfilters,
      if (infoflag >= 1)
         fprintf(' %.0f', filter);
         if mod(filter,20) ==0
            fprintf('\n');
         end;
      end;
      % get envelope
      envelope = abs(hilbert(multichanneldata(filter,:)));
      % compress the envelope to a power of compression1, while maintaining
      % the fine structure. 
      compressedenvelope = (envelope.^(compress1 - 1)).*multichanneldata(filter,:);
      % rectify that compressed envelope 
      rectifiedenvelope = compressedenvelope;
      findoutput = find(compressedenvelope<0);
      rectifiedenvelope(findoutput) = zeros(size(findoutput));
      % raise to power of compress2
      rectifiedenvelope = rectifiedenvelope.^compress2;
      % overlap-add FIR filter using the fft
      multichanneldata2(filter,:) = fftfilt(lowpassfiltercoefficients, rectifiedenvelope);
   end;
   
   if (infoflag >= 1)
      fprintf('\n');
   end;
   
   
case 'meddishigh'
   % Meddis et al (1990) haircell, high spontaneous rate ...
   if (infoflag >= 1)
      fprintf('''%s''= applying Meddis et al (1990) hair cell (high-spontaneous rate) ... \n', transduction);
   end;
   % Uses Klaus Hartung's implentation of the Meddis haircell so does
   % the whole filterbank in one go.
   % Note that the haircell adds a small silence at the beginning 
   % and end
   % See mmeddishaircell.m for more information.
   multichanneldata2 = mmeddishaircell(multichanneldata, 'high', samplerate, infoflag);
   
   
   
case 'meddismedium'
   % Meddis et al (1990) haircell, medium spontaneous rate ...
   if (infoflag >= 1)
      fprintf('''%s'' = applying Meddis et al (1990) hair cell (medium-spontaneous rate) ... \n', transduction);
   end;
   % Uses Klaus Hartung's implentation of the Meddis haircell so does
   % the whole filterbank in one go.
   % Note that the haircell adds a small silence at the beginning 
   % and end
   % See mmeddishaircell.m for more information.
   multichanneldata2 = mmeddishaircell(multichanneldata, 'medium', samplerate, infoflag);


otherwise
   % unknown compression value
   fprintf('%s: error! nknown compression type ''%s''\n', mfilename, compression);
   return;
end;   
   
   
% multichanneldata2 is one output
   
% measures power and maximum values in each channel
output_powervector = (sqrt(mean(power(multichanneldata2, 2)')))';
output_maxvector = (max(multichanneldata2'))';



% the end!
%------------------------------