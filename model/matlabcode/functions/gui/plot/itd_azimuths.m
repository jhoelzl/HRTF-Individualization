function itd_2d = itd_azimuths()

% Get 2D ITD Data (= all azimuths) from given elevation of one subject

global DB
global ANGLES
global current_subject
global current_db
global elevation_real
global fs

itd_2d = [];

if (strcmp(current_db,'universal') == 1)
    
     [~,hrir_length,fs] = get_matrixvalue_universal(0,0,current_subject,ANGLES);    
    
    indizes = find(ANGLES(:,2) == elevation_real);
    azimuth_values = zeros(length(indizes));
    
    for i=1:length(indizes)
        azimuth_values(i) = ANGLES(indizes(i),1);
    end
    
    itd_2d = zeros(1,length(indizes)); 
        
    for i = 1:length(indizes)
        row_value = get_matrixvalue_universal(elevation_real,azimuth_values(i),current_subject,ANGLES);
        left = squeeze(DB(current_subject,row_value,1,1:hrir_length));
        right = squeeze(DB(current_subject,row_value,2,1:hrir_length));
        
        itd_2d(i) = calculate_itd(left,right,fs);
    end
    
else
    
    indizes = find(ANGLES(:,2) == elevation_real);
    itd_2d = zeros(1,length(indizes));
    
    for i=1:length(indizes)  
        itd_2d(i) = calculate_itd(squeeze(DB(current_subject,indizes(i),1,:)),squeeze(DB(current_subject,indizes(i),2,:)),fs);
        
    end 
    
end

end

