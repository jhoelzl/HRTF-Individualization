function [onset]=get_CIPIC_HRIR_onset(subject_id,pinna,elev,azim,freq_kHz)

%--------------------------------------------------------------------------------------------------- 
% This function returns the onset time of the Head Related Impulse Response (HRIR) of a particular
% pinna for a given elevation and azimuth in the CIPIC HRIR database.
%--------------------------------------------------------------------------------------------------- 
% EXAMPLE USAGE:
%
% [onset]=get_CIPIC_HRIR_onset(10,'right',0,0,22.05)
%--------------------------------------------------------------------------------------------------- 
% INPUT : subject_id  : subject id number
%         pinna       : 'left' or 'right'  
%         elev        : elevation in degrees   [ 72 elevations (-90:5:265) ]
%         azim        : azimuth in degrees     [ 19 azimuths (0:5:90) ]
%         freq_kHz    : Upper frequency cutoff [ Upper limit is 22.05 kHz]
%--------------------------------------------------------------------------------------------------- 
% OUTPUT : onset      : onset time in number of samples [use HRIR(onset:end)]
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

if strcmp(pinna,'left')==1
    onset=round(OnL(azimuth_index,elevation_index)*freq_kHz*2/44.1);
end

if strcmp(pinna,'right')==1
    onset=round(OnR(azimuth_index,elevation_index)*freq_kHz*2/44.1);
end
