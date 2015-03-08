function [ data_l, data_r ] = get_2d_hrir_azimuths()

% Get 2D HRIR Data (= all azimuths) from given elevation of one subject

global DB
global ANGLES
global current_subject
global current_db
global elevation_real
global hrir_db_length

    if (strcmp(current_db,'universal') == 1)    
    [~,hrir_db_length] = get_matrixvalue_universal(0,0,current_subject,ANGLES);
    end
    
    indizes = find(ANGLES(:,2) == elevation_real);
    
    data_l = zeros(hrir_db_length,length(indizes));
    data_r = zeros(hrir_db_length,length(indizes));     

    for i=1:length(indizes)
        data_l(:,i) = squeeze(DB(current_subject,indizes(i),1,1:hrir_db_length));
        data_r(:,i) = squeeze(DB(current_subject,indizes(i),2,1:hrir_db_length));
    end


end

