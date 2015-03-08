function perform_pca_subject(hObject, eventdata, handles)

global current_subject
global current_db
global DB
global UNIVERSAL_DTF
global project
global project_recon
global v
global mn
global pc
global DATA_DTF
global MEAN_SUB
global DATA_PHASE
global ANGLES
global azimuth_real
global elevation_real

% PCA Decomposition of one Subject

text = sprintf('Current Subject: %d / %s',current_subject, current_db);
set(handles.pca_choose_text,'String', text);

DATA_DTF = zeros(512,2*size(ANGLES,1));
MEAN_SUB = zeros(512,2*size(ANGLES,1));
DATA_PHASE = zeros(1024,2*size(ANGLES,1)); 
    
if (strcmp(current_db,'universal') == 1)
load('../../db/GLOBAL/db.mat','UNIVERSAL_PHASE','UNIVERSAL_MEAN');
end

position = get_matrixvalue(azimuth_real,elevation_real,ANGLES);

% FFT
fft_points = 1024;
DATA_DTF = 20*log10(2*abs(fft(DB(current_subject,:,:,:),fft_points,4)));
DATA_PHASE = angle(fft(DB(current_subject,:,:,:),fft_points,4));
DATA_DTF = DATA_DTF(:,:,:,1:fft_points/2);

% Substract Subjects Mean
MEAN_SUB = mean(DATA_DTF,2); % Mean Across Angles        
DATA_DTF = DATA_DTF - repmat(MEAN_SUB,[1 size(DATA_DTF,2) 1 1]);

if (strcmp(current_db,'universal') == 1) 
load('../../db/GLOBAL/db.mat','UNIVERSAL_PHASE','UNIVERSAL_DTF','UNIVERSAL_MEAN');  
DATA_DTF = UNIVERSAL_DTF(current_subject,:,:,:);
DATA_PHASE = UNIVERSAL_PHASE(current_subject,:,:,:);
MEAN_SUB = UNIVERSAL_MEAN(current_subject,:,:,:);
end

size(squeeze(DATA_DTF))
% Reshape for structures PCA1,PCA2,PCA3
DATA_DTF = permute(squeeze(DATA_DTF),[3,2,1]);
size(DATA_DTF)

figure
plot(squeeze(DATA_DTF(:,1,2)))

DATA_DTF = reshape(DATA_DTF,size(DATA_DTF,1),[]);   
   
hold on
plot(DATA_DTF(:,3),'r');
size(DATA_DTF)

% Calculate PCA
[pc,project,v,mn] = pca_calc(DATA_DTF,1);

project_recon = project; 

% Plot PCA
plot_pca_db(hObject, eventdata, handles)

end