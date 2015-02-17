function [ hrir_reconstr_left, hrir_reconstr_right,hrir_rec_left,hrir_rec_right] = ifft_minph(hrtf_mag_left,hrtf_mag_right,itd_samples,hrir_db_length,input_mode)
% IFFT with minimum phase assumption, then time alignment with itd

% Input
% hrtf_mag_left
% hrtf_mag_right
% itd_samples   ITD shift between left and right in samples
% hrir_db_length
% input_mode: 3=lin magnitude, 4 = log magnitude

% Ouput
% hrir_reconstr_left = HRIR reconstruction left ear, with time alignement
% hrir_reconstr_right = HRIR reconstruction right ear, with time alignement

% hrir_reco_left = HRIR reconstruction left ear, no time alignement
% hrir_reco_right = HRIR reconstruction right ear, no time alignement

% Check dimensions
if (size(hrtf_mag_left,1) > size(hrtf_mag_left,2))
    hrtf_mag_left = hrtf_mag_left';
end

if (size(hrtf_mag_right,1) > size(hrtf_mag_right,2))
    hrtf_mag_right = hrtf_mag_right';
end


if (input_mode == 4)
% Remove 20*log10
hrtf_mag_left = 10.^(hrtf_mag_left/20);
hrtf_mag_right = 10.^(hrtf_mag_right/20);
end

% Add Mirrored HRTF Magnitude
hrtf_mag_left = mirror(hrtf_mag_left');
hrtf_mag_right = mirror(hrtf_mag_right');

% Prove all pins are positive
hrtf_mag_left(find(hrtf_mag_left<1e-5))=1e-5;
hrtf_mag_right(find(hrtf_mag_right<1e-5))=1e-5;

% Phase from Hilbert
phase_l = imag(-hilbert(log(hrtf_mag_left)));
phase_r = imag(-hilbert(log(hrtf_mag_right)));

% IFFT
% ifft_points should be the same as fft_points
ifft_points = length(hrtf_mag_left);

hrir_rec_left = real(ifft(hrtf_mag_left.*exp(1i*phase_l),ifft_points));
hrir_rec_right = real(ifft(hrtf_mag_right.*exp(1i*phase_r),ifft_points));

% Time alignment / ITD
[hrir_reconstr_left1,hrir_reconstr_right1] = itd_alignment_old(hrir_rec_left,hrir_rec_right,itd_samples);

% Zero padding or truncate
if (hrir_db_length < size(hrir_reconstr_left1,1))
    %disp('truncate');
    % Only first (hrir_db_length) samples
    hrir_reconstr_left = hrir_reconstr_left1(1:hrir_db_length);
    hrir_reconstr_right = hrir_reconstr_right1(1:hrir_db_length);
else
    %disp('zeropadding');
    % Zeropadding 
    hrir_reconstr_left = zeros(hrir_db_length,1);
    hrir_reconstr_right = zeros(hrir_db_length,1);
    hrir_reconstr_left(1:length(hrir_reconstr_left1)) = hrir_reconstr_left1;
    hrir_reconstr_right(1:length(hrir_reconstr_right1)) = hrir_reconstr_right1;
end
