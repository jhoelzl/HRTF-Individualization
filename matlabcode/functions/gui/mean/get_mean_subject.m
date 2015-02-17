function [mean_left, mean_right] = get_mean_subject(DB,subject,speed)

% Calculate Mean vector for this subject / each ear
% INPUT
% speed     consider only every second source position, speed improvement

if (nargin < 3)
    speed = 0;
end

fft_points = 1024;

if (speed == 1)
data_dtf = 20*log10(2*abs(fft(DB(subject,1:2:end,:,:),fft_points,4)));
else
data_dtf = 20*log10(2*abs(fft(DB(subject,:,:,:),fft_points,4)));    
end
data_dtf = data_dtf(:,:,:,1:fft_points/2);

m_s = mean(data_dtf,2); % Mean Across Angles

mean_left = squeeze(m_s(1,1,1,:));
mean_right = squeeze(m_s(1,1,2,:));