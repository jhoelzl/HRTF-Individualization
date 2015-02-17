function global_cor_data(mode)

% mode: 1 or 2 (calculate weighs or pcs)

load('../../db/GLOBAL/db.mat','UNIVERSAL_DTF'); 

if (mode ==1)
WEIGHTS = zeros(6,6,115,1024);
WEIGHTS_LEFT = zeros(6,6,115,512);
WEIGHTS_RIGHT = zeros(6,6,115,512);
else
PCS = zeros(6,6,10,1024);
PCS_LEFT = zeros(6,6,10,512);
PCS_RIGHT = zeros(6,6,10,512);
end

azimuth_vals = [6 10 10 6 6 6];

for current_elevation = 1:6
    
    text = sprintf('Perform PCA on Elevation ... %d/6',current_elevation);
    ul = waitbar(0,text);
    
    if (azimuth_vals(current_elevation) == 10)
     az_for=   [1 3 5 6 7 9];
    else
     az_for = [1:6];
    end
    
    for current_azimuth = 1:6
        
        DATA_DTF = zeros(1024,115);
        DATA_DTF_left = zeros(512,115);
        DATA_DTF_right = zeros(512,115);
        
        % GET DTF DATA for this Angle of all subjects
        for i=1:115    
       
        % only left
        DATA_DTF_left(:,i) = squeeze(UNIVERSAL_DTF(current_elevation,az_for(current_azimuth),i,1,:));
        
        % only right
        DATA_DTF_right(:,i) = squeeze(UNIVERSAL_DTF(current_elevation,az_for(current_azimuth),i,2,:));   
        
        % both ears    
        DATA_DTF(1:512,i) = DATA_DTF_left(:,i);
        DATA_DTF(513:1024,i) = DATA_DTF_right(:,i) ;
        end
        
        % Perform PCA
        if(mode ==1) 
        weight = pca3(DATA_DTF');
        weight_left = pca3(DATA_DTF_left');
        weight_right = pca3(DATA_DTF_right');
        
        WEIGHTS(current_azimuth,current_elevation,:,:) = weight;
        WEIGHTS_LEFT(current_azimuth,current_elevation,:,:) = weight_left;
        WEIGHTS_RIGHT(current_azimuth,current_elevation,:,:) = weight_right;
        
        else
        [~,pc] = pca3(DATA_DTF');
        [~,pc_left] = pca3(DATA_DTF_left');
        [~,pc_right] = pca3(DATA_DTF_right');    
            
        PCS(current_azimuth,current_elevation,:,:) = pc(1:10,:); 
        PCS_LEFT(current_azimuth,current_elevation,:,:) = pc_left(1:10,:); 
        PCS_RIGHT(current_azimuth,current_elevation,:,:) = pc_right(1:10,:); 
        end

        waitbar(current_elevation / 50,ul)
    end    
    close(ul)
end

% Save Data in mat-Files
if(mode ==1)
save('../matlabdata/global_cor/weights.mat','WEIGHTS','WEIGHTS_LEFT', 'WEIGHTS_RIGHT'); 
else
save('../matlabdata/global_cor/pcs.mat','PCS','PCS_LEFT', 'PCS_RIGHT');
end
disp('Finished')