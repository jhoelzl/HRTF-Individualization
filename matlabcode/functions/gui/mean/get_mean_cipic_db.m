function [ mean_left, mean_right] = get_mean_cipic_db(CIPIC,mode)

% Calculate Mean vector for this subject / each ear
    
if(nargin==1)
    mode = 0;
end

if (mode == 1)
h = waitbar(0,'Calc Global Mean ...');
waitbar(0 / 2)
end

% Calculate HRTF
c = 0; 

DATA_HRTF_l = zeros(512,1125);
DATA_HRTF_r = zeros(512,1125);

mean_left = zeros(1,512);
mean_right = zeros(1,512);

for subject =1:45
for k=1:5:25 % all Azimuth
    for i=1:10:50 % all Elevations
        
    %Left Ear    
    c = c +1;
    DATA_HRTF_l(:,c) = perform_fft(squeeze(CIPIC(subject,k,i,1,:)));   
    
    % Right Ear
    c = c +1;
    DATA_HRTF_r(:,c) = perform_fft(squeeze(CIPIC(subject,k,i,2,:)));
    end
end
end

if (mode == 1)
waitbar(1 / 2)
end

% Get Mean
for k=1:1:512
    mean_left(k) = mean(DATA_HRTF_l(k,:));
    mean_right(k) = mean(DATA_HRTF_r(k,:));
end

if (mode == 1)
waitbar(2 / 2)
close(h)
end
end
