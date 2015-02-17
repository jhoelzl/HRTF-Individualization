function [ hrir_reconstr_left,hrir_reconstr_right] = perform_ifft( hrtf_mag_left, hrtf_mag_right,hrtf_phase_left,hrtf_phase_right,hrir_db_length)

% Standard values
if (nargin < 5)
   hrir_db_length = 512; 
end


% Perform IFFT of reconstructed HRTF Pair

% Remove 20 log
hrtf_mag_left = 10.^(hrtf_mag_left/20);
hrtf_mag_right = 10.^(hrtf_mag_right/20);

% Add Mirrored HRTF Magnitude
hrtf_mag_left = mirror(hrtf_mag_left);
hrtf_mag_right = mirror(hrtf_mag_right);

% IFFT
ifft_points = length(hrtf_mag_left);
hrir_reconstr_left1 = real(ifft(hrtf_mag_left.*exp(j*hrtf_phase_left),ifft_points));
hrir_reconstr_right1 = real(ifft(hrtf_mag_right.*exp(j*hrtf_phase_right),ifft_points));

if (hrir_db_length < size(hrir_reconstr_left1,1))
    
    % Only first (hrir_db_length) samples
    hrir_reconstr_left = hrir_reconstr_left1(1:hrir_db_length);
    hrir_reconstr_right = hrir_reconstr_right1(1:hrir_db_length);
else
    
    % Zeropadding 
    hrir_reconstr_left = zeros(1,hrir_db_length);
    hrir_reconstr_right = zeros(1,hrir_db_length);
    hrir_reconstr_left(1:length(hrir_reconstr_left1)) = hrir_reconstr_left1;
    hrir_reconstr_right(1:length(hrir_reconstr_right1)) = hrir_reconstr_right1;
    
end

end

