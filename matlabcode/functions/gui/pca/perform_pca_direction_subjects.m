function perform_pca_direction_subjects(hObject, eventdata, handles)

% PCA Decomposition of one specific Angle of all Subjects in current db
global current_azimuth
global current_elevation
global elevation_real
global azimuth_real
global current_db
global DB
global UNIVERSAL_DTF
global ANGLES
global weight_l
global weight_l_recon
global weight_r
global weight_r_recon
global pc_l
global pc_r
global v_l
global v_r
global mn_l
global mn_r
global DATA_PHASE
global MEAN_SUB
global subjects
global DATA_PCA_left
global DATA_PCA_right


% Get All Azimuth Listbox values
current_azimuth = get(handles.pca_azimuth,'Value');
all_azimuth = str2num(get(handles.pca_azimuth,'String'));
azimuth_real = all_azimuth(current_azimuth);

% Get All Elevation Listbox values
current_elevation = get(handles.pca_elevation,'Value');
all_elevation = str2num(get(handles.pca_elevation,'String'));
elevation_real = all_elevation(current_elevation);

text = sprintf('Elevation %0.5g / Azimuth %0.5g / %i Subjects',elevation_real,azimuth_real,length(subjects));
set(handles.pca_choose_text,'String', text);

position = get_matrixvalue(azimuth_real,elevation_real,ANGLES);

% FFT
fft_points = 128;
DATA_PCA = 20*log10(2*abs(fft(DB,fft_points,4)));
DATA_PHASE = angle(fft(DB(:,position,:,:),fft_points,4));
DATA_PCA = DATA_PCA(:,:,:,1:fft_points/2);

% Substract Subjects Mean
MEAN_SUB = mean(DATA_PCA,2); % Mean Across Angles        
DATA_PCA = DATA_PCA - repmat(MEAN_SUB,[1 size(DATA_PCA,2) 1 1]);
DATA_PCA = DATA_PCA(:,position,:,:);

if (strcmp(current_db,'universal') == 1) 
load('../../db/GLOBAL/db.mat','UNIVERSAL_PHASE','UNIVERSAL_DTF','UNIVERSAL_MEAN');  
DATA_PCA = UNIVERSAL_DTF(:,position,:,:);
DATA_PHASE = UNIVERSAL_PHASE(:,position,:,:);
MEAN_SUB = UNIVERSAL_MEAN(:,position,:,:);
end

% Reshape for structures PCA1,PCA2,PCA3
DATA_PCA = permute(squeeze(DATA_PCA),[1,3,2]);
DATA_PCA_left = reshape(squeeze(DATA_PCA(:,:,1)),length(subjects),[]);
DATA_PCA_right = reshape(squeeze(DATA_PCA(:,:,2)),length(subjects),[]);

% Calculate PCA for each ear
[pc_l,weight_l,v_l,mn_l] = pca_calc(DATA_PCA_left,0);
[pc_r,weight_r,v_r,mn_r] = pca_calc(DATA_PCA_right,0);

weight_l_recon = weight_l;
weight_r_recon = weight_r;

end