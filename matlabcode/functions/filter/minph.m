function minph()

clear; close all;

NCases = 25;
NFFT = 512; % FFT Size
Z = linspace(-0.01,-0.99,NCases)'; % Zeros going from z = -0.5 to -0.99
P = 1/2; % Pole at 1/2;

Ang.H = zeros(NFFT,NCases); % Will hold phase responses of H
Ang.Hm = zeros(NFFT,NCases); % Will hold phase responses of Hm
A = poly(P); % Denominator polynomial
for i = 1:NCases

   B = poly(Z(i)); % Numerator polynomial for this case
   [H,w] = freqz(B,A); % Frequency response of filter
   [h,n] = impz(B,A,512); % Impulse response of filter
   [NotUsed hm] = rceps(h);
   [Hm,w] = freqz(hm,1);

   Ang.H(:,i) = angle(H);
   Ang.Hm(:,i) = angle(Hm);

end
Err = abs(Ang.H-Ang.Hm); % Error in angle responses

hFig = figure('doublebuffer','on','visible','off');
hAxis.ZP = subplot(2,1,1);
hz = zplane(Z(1),P);

hAxis.Ang = subplot(2,2,3);
hLines.Ang = plot([w w]/pi,[Ang.H(:,1) Ang.Hm(:,1)]);
set(hAxis.Ang,'ylim',[min([Ang.H(:); Ang.Hm(:)]) max([Ang.H(:);
Ang.Hm(:)])]);
title('Phase Responses'); ylabel('rad');

hAxis.Err = subplot(2,2,4);
hLines.Err = plot(w/pi,Err(:,1));
set(hAxis.Err,'ylim',[0 max(Err(:))]);
title('Error'); xlabel('\omega/\pi');

drawnow;
set(hFig,'Visible','on');
NRepeat = 3;
for i= 1:NRepeat
   for k = 1:NCases
      % pause;
      if ~ishandle(hFig), break; end % In case window is closed while running
      set(hLines.Ang, {'YData'}, {Ang.H(:,k); Ang.Hm(:,k)});
      set(hLines.Err, 'YData', Err(:,k) );
      set(hz,'XData',Z(k));
      drawnow;
   end
end


% Input:
%   X = set of HRIRs
%
% Output: 
%   Y = set of minimum phase HRTFs

% We consider only the minimum phase
% [n,m] = size(X);
% Xmin  = zeros(n,m);
% for k =1:n
% [xorg Xmin(k,:)] = rceps(X(k,:));
% end
% 
% % we want log-frequency domain
% Xf = fft(Xmin,m,2);
% 
% Y = Xf;
