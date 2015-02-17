function [HRIR,HRTF_mag,HRTF_phase,time,frequency]=...
    get_CIPIC_HRIR(subject_id,...
             pinna,...
             elev,...
             azim,...
             freq_kHz,...
             FFT_LENGTH,...
             log_enable,...
             diff_enable,...
             plot_enable)
         
%--------------------------------------------------------------------------------------------------- 
% This function returns the Head Related Impulse Response (HRIR) and the
% Head Related Transfer Function (HRTF) of a particular pinna for a given
% elevation and azimuth in the CIPIC HRIR database.
%--------------------------------------------------------------------------------------------------- 
% EXAMPLE USAGE:
%
% [HRIR,HRTF_mag,HRTF_phase,time,frequency]=get_HRTF(10,'right',0,0,22.05,1024,1,0,1);
%--------------------------------------------------------------------------------------------------- 
% INPUT : subject_id  : subject id number
%         pinna       : 'left' or 'right'  
%         elev        : elevation in degrees   [ 72 elevations (-90:5:265) ]
%         azim        : azimuth in degrees     [ 19 azimuths (0:5:90) ]
%         freq_kHz    : Upper frequency cutoff [ Upper limit is 22.05 kHz]
%         FFT_LENGTH  : length of the FFT in samples 
%         log_enable  : if 1 the HRTF magnitude is in dB
%         diff_enable : if 1 diff operation is enabled (removes any DC if present)
%         plot_enable : if 1 the HRIR and the HRTF are plotted
%--------------------------------------------------------------------------------------------------- 
% OUTPUT : HRIR       : Pinna Related Impulse Response
%          HRTF_mag   : Pinna Related Transfer Function Magnitude
%          HRTF_phase : Pinna Related Transfer Function Phase
%          time       : time axis in milliseconds
%          frequency  : frequency axis in kHz
%--------------------------------------------------------------------------------------------------- 
% Author     :     Vikas.C.Raykar 
% Date       :     25 May 2004
% Contact    :     vikas@umiacs.umd.edu
%--------------------------------------------------------------------------------------------------- 
% NOTE: Make sure you set the path to the CIPIC database in CIPIC_database_path. The CIPIC database 
%       can be downloaded from
%       http://interface.cipic.ucdavis.edu/CIL_html/CIL_HRTF_database.htm
%--------------------------------------------------------------------------------------------------- 

ids=[3,8,9,10,11,12,15,17,18,19,20,21,27,28,33,40,44,48,50,51,58,59,60,61,65,119,124,126,127,131,133,134,135,137,147,148,152,153,154,155,156,158,162,163,165] ;
azimuth=[-80 -65 -55 -45:5:45 55 65 80];
elevation=-45+5.625*(0:49);
fs=44100; %Sampling rate

%Check whether the id is valid or not
if isempty(find(ids==subject_id)) == 1
    disp('NOT A VALID ID');
    disp('FOLLOWING ARE THE VALID IDS');
    disp(ids);
    return;
end

%Check whether it is a valid azimuth or not
azimuth_index=find(azimuth==azim);

if isempty(azimuth_index) == 1
    disp('NOT A VALID AZIMUTH');
    disp('FOLLOWING ARE THE VALID AZIMUTHS');
    disp(azimuth);
    return;
end

%Check whether it is a valid elevation or not
elevation_index=find(elevation==elev);

if isempty(elevation_index) == 1
    disp('NOT A VALID ELEVATION');
    disp('FOLLOWING ARE THE VALID ELEVATIONS');
    disp(elevation);
    return;
end

%Load the HRIR for given subject

database_path=CIPIC_database_path; 
pinna_path=sprintf('standard_hrir_database/subject_%03d/hrir_final.mat',subject_id);
filename=strcat(database_path,pinna_path);
load(filename);

%load the HRIR for the given elevation and azimuth
if strcmp(pinna,'left')==1
    HRIR=squeeze(hrir_l(azimuth_index,elevation_index,:));
    %temp=round(OnL(azimuth_index,elevation_index));
    %HRIR=[HRIR(temp+67:end)];
end

if strcmp(pinna,'right')==1
    HRIR=squeeze(hrir_r(azimuth_index,elevation_index,:));
end

% Downsample 

HRIR=resample(HRIR,round(2*freq_kHz*1000),fs);

if diff_enable==1
   HRIR=[diff(HRIR); 0];
end

%Compute the HRTF magnitude
HRTF_mag=abs(fft(HRIR,FFT_LENGTH));

if log_enable==1
    HRTF_mag =20*log10(HRTF_mag);
end

%phase
HRTF_phase=unwrap(angle(fft(HRIR,FFT_LENGTH)'));

%Return only  from 0 to pi
HRTF_mag=HRTF_mag(1:(FFT_LENGTH/2)+1);
HRTF_phase=HRTF_phase(1:(FFT_LENGTH/2)+1)';

frequency=[0:(freq_kHz*2)/FFT_LENGTH:freq_kHz];
time=[0:1/(2*freq_kHz):(max(size(HRIR))-1)/(2*freq_kHz)];

if plot_enable==1
    
    figure;
    subplot(3,1,1);
    plot(time,HRIR);
    hold on;
    title(sprintf('HRIR and HRTF for Subject %d %s pinna elevation %f azimuth %f',subject_id,pinna,elev,azim));
    xlabel('time in ms');
    ylabel('HRIR');
    grid on;
     
    subplot(3,1,2);
    plot(frequency,HRTF_mag);
    xlabel('frequency in kHz');
    if log_enable==1
        ylabel('HRTF (dB)');
    else
        ylabel('HRTF Magnitude');
    end
    grid on;
    
    subplot(3,1,3);
    plot(frequency,HRTF_phase);
    xlabel('frequency in kHz');
    ylabel('Phase (radians)');
    grid on;
end








