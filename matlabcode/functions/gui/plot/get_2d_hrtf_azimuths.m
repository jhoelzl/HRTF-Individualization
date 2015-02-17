function [ data_l, data_r ] = get_2d_hrtf_azimuths(mode)

% Get 2D HRTF Data (= all azimuth) from given elevation of one subject
% mode 1 = HRTF
% mode 2 = DTF

global DB
global UNIVERSAL_DTF
global ANGLES
global current_subject
global current_db
global elevation_real
global subjects_mean_left
global subjects_mean_right

mean_left = 0;
mean_right = 0;


if (strcmp(current_db,'universal') == 1)  
     
     [~,hrir_length] = get_matrixvalue_universal(0,0,current_subject,ANGLES);
    
    indizes = find(ANGLES(:,2) == elevation_real);
    azimuth_values = zeros(length(indizes));
    
    for i=1:length(indizes)
        azimuth_values(i) = ANGLES(indizes(i),1);
    end
    
    data_l = zeros(512,length(indizes));
    data_r = zeros(512,length(indizes)); 
        
    for i = 1:length(indizes)
        row_value = get_matrixvalue_universal(elevation_real,azimuth_values(i),current_subject,ANGLES);
 
        if (mode == 1)
        % HRTF
        data_l(:,i) = perform_fft(squeeze(DB(current_subject,row_value,1,1:hrir_length)));
        data_r(:,i) = perform_fft(squeeze(DB(current_subject,row_value,2,1:hrir_length)));
        else
        % DTF
        data_l(:,i) = squeeze(UNIVERSAL_DTF(current_subject,row_value,1,:));
        data_r(:,i) = squeeze(UNIVERSAL_DTF(current_subject,row_value,2,:));
        end    
        
    end
    
else
     
     indizes = find(ANGLES(:,2) == elevation_real);
    
    data_l = zeros(512,length(indizes));
    data_r = zeros(512,length(indizes)); 
    
    for i=1:length(indizes)
        data_l(:,i) = perform_fft(squeeze(DB(current_subject,indizes(i),1,:))) - mean_left;
        data_r(:,i) = perform_fft(squeeze(DB(current_subject,indizes(i),2,:))) - mean_right;
    end
    
    if (mode == 2)        
        data_l = data_l - repmat(subjects_mean_left,1,size(data_l,2));
        data_r = data_r - repmat(subjects_mean_right,1,size(data_r,2));
    end
     
end

end

