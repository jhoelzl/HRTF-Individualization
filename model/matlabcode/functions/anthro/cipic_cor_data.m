function cipic_cor_data(mode)

% mode: 1 or 2 (calculate weighs or pcs)

CIPIC = db_import2('cipic',1,1,1,2);

if (mode ==1)
WEIGHTS = zeros(25,50,45,1024);
WEIGHTS_LEFT = zeros(25,50,45,512);
WEIGHTS_RIGHT = zeros(25,50,45,512);
else
PCS = zeros(25,50,10,1024);
PCS_LEFT = zeros(25,50,10,512);
PCS_RIGHT = zeros(25,50,10,512);
end

MEAN_L = zeros(512,45);
MEAN_R = zeros(512,45);

h = waitbar(0,'Calculate Subjects DTF ...');
for i=1:45 
   [ mean_left, mean_right ] = get_mean_cipic_subject(CIPIC,i,2); 
   MEAN_L(:,i) = mean_left';
   MEAN_R(:,i) = mean_right';
   waitbar(i / 45)
end
close(h)

for current_azimuth = 1:25
    
    text = sprintf('Perform PCA on Azimuth ... %d/25',current_azimuth);
    ul = waitbar(0,text);
    
    for current_elevation = 1:50
        
        DATA_DTF = zeros(1024,45);
        DATA_DTF_left = zeros(512,45);
        DATA_DTF_right = zeros(512,45);
        
        % GET DTF DATA for this Angle of all subjects
        for i=1:45    
       
        % only left
        DATA_DTF_left(:,i) = perform_fft(squeeze(CIPIC(i,current_azimuth,current_elevation,1,:))) - MEAN_L(:,i);
        
        % only right
        DATA_DTF_right(:,i) = perform_fft(squeeze(CIPIC(i,current_azimuth,current_elevation,2,:))) - MEAN_R(:,i);   
        
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
save('../matlabdata/cipic_cor/weights.mat','WEIGHTS','WEIGHTS_LEFT', 'WEIGHTS_RIGHT'); 
else
save('../matlabdata/cipic_cor/pcs.mat','PCS','PCS_LEFT', 'PCS_RIGHT');
end
disp('Finished')