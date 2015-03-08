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
global total_pcs
global MEAN_SUB
global DATA_PHASE
global ANGLES

% PCA Decomposition of one Subject

text = sprintf('Current Subject: %d / %s',current_subject, current_db);
set(handles.pca_choose_text,'String', text);

DATA_DTF = zeros(512,2*size(ANGLES,1));
MEAN_SUB = zeros(512,2*size(ANGLES,1));
DATA_PHASE = zeros(1024,2*size(ANGLES,1)); 
    
if (strcmp(current_db,'universal') == 1)
load('../../db/GLOBAL/db.mat','UNIVERSAL_PHASE','UNIVERSAL_MEAN');
else
[mean_left , mean_right,] = get_mean_subject(DB,current_subject);
end

h = waitbar(0,'Calculate Subjects DTF ...');

    for i=1:size(ANGLES,1)
        
        if (strcmp(current_db,'universal') == 1)
        
        % Left  
        DATA_DTF(:,2*i-1) = squeeze(UNIVERSAL_DTF(current_subject,i,1,:));
        DATA_PHASE(:,2*i-1) = squeeze(UNIVERSAL_PHASE(current_subject,i,1,:));
        MEAN_SUB(:,2*i-1) = squeeze(UNIVERSAL_MEAN(current_subject,i,1,:));

        % Right 
        DATA_DTF(:,2*i) = squeeze(UNIVERSAL_DTF(current_subject,i,1,:));
        DATA_PHASE(:,2*i) = squeeze(UNIVERSAL_PHASE(current_subject,i,1,:));
        MEAN_SUB(:,2*i) = squeeze(UNIVERSAL_MEAN(current_subject,i,1,:));

        
        else
        
        % Left Ear
        [hrtf_mag, hrtf_phase] = perform_fft(squeeze(DB(current_subject,i,1,:)));        
        DATA_DTF(:,2*i-1) = hrtf_mag - mean_left; 
        DATA_PHASE(:,2*i-1) = hrtf_phase;
        MEAN_SUB(:,2*i-1) = mean_left';
        
        % Right Ear
        [hrtf_mag, hrtf_phase] = perform_fft(squeeze(DB(current_subject,i,2,:)));
        DATA_DTF(:,2*i) = hrtf_mag - mean_right; 
        DATA_PHASE(:,2*i) = hrtf_phase;
        MEAN_SUB(:,2*i) = mean_right';
        
        end
        
        waitbar(i / size(ANGLES,1))

    end
    
close(h)    
total_pcs = size(DATA_DTF,2);

% Calculate PCA
[pc,project,v,mn] = pca_calc(DATA_DTF,1);

project_recon = project; 

% Plot PCA
plot_pca_db(hObject, eventdata, handles)

end
