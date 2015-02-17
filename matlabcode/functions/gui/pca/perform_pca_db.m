function perform_pca_db(hObject, eventdata, handles)

% Calculate DTFs from db for pca decomposition

global current_db
global DB
global UNIVERSAL_DTF
global project
global project_recon
global pc
global v
global mn
global DATA_DTF;
global total_pcs
global MEAN_SUB
global DATA_PHASE
global ANGLES
global subjects

% prevent data overload
if (size(ANGLES,1) > 600) & (length(subjects) > 44)
    pca_subjects = 10;
    disp('PCA input data automatically limited to 10 subjects, because too much data')
else
    pca_subjects = length(subjects);
end

DATA_DTF = zeros(512,size(ANGLES,1)*2*pca_subjects);
MEAN_SUB = zeros(512,size(ANGLES,1)*2*pca_subjects);
DATA_PHASE = zeros(1024,size(ANGLES,1)*2*pca_subjects);

text = sprintf('Current DB: %s, %d subjects',upper(current_db),pca_subjects);
set(handles.pca_choose_text,'String', text);
    
if (strcmp(current_db,'universal') == 1)
load('../../db/GLOBAL/db.mat','UNIVERSAL_PHASE','UNIVERSAL_MEAN');      
end

h = waitbar(0,'Calculate DTF of all subjects ...');
counter = 0;

    
    for s=1:pca_subjects
        
        if (strcmp(current_db,'universal') == 0)
        [mean_left , mean_right,] = get_mean_subject(DB,s);
        end
        
        for i=1:size(ANGLES,1)
        
            if (strcmp(current_db,'universal') == 1)
            
            % Left
            counter = counter +1; 
            DATA_DTF(:,counter) = squeeze(UNIVERSAL_DTF(s,i,1,:));
            DATA_PHASE(:,counter) = squeeze(UNIVERSAL_PHASE(s,i,1,:));
            MEAN_SUB(:,counter) = squeeze(UNIVERSAL_MEAN(s,i,1,:));

            % Right 
            counter = counter +1; 
            DATA_DTF(:,counter) = squeeze(UNIVERSAL_DTF(s,i,2,:));
            DATA_PHASE(:,counter) = squeeze(UNIVERSAL_PHASE(s,i,2,:));
            MEAN_SUB(:,counter) = squeeze(UNIVERSAL_MEAN(s,i,2,:));

            
            else
            
            
            % Left Ear
            counter = counter +1;
            [hrtf_mag, hrtf_phase] = perform_fft(squeeze(DB(s,i,1,:)));        
            DATA_DTF(:,counter) = hrtf_mag - mean_left; 
            DATA_PHASE(:,counter) = hrtf_phase;
            MEAN_SUB(:,counter) = mean_left;

            % Right Ear
            counter = counter +1;
            [hrtf_mag, hrtf_phase] = perform_fft(squeeze(DB(s,i,2,:)));
            DATA_DTF(:,counter) = hrtf_mag - mean_right; 
            DATA_PHASE(:,counter) = hrtf_phase;
            MEAN_SUB(:,counter) = mean_right;
            end

        end
        
        waitbar(s / pca_subjects)
    
      
    end
    
    
 close(h)   
    

total_pcs = size(DATA_DTF,2);

% Calculate PCA
[pc,project,v,mn] = pca_calc(DATA_DTF,1);
project_recon = project; 

% Plot PCA
plot_pca_db(hObject, eventdata, handles)

end