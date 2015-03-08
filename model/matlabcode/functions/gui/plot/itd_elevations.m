function itd_2d = itd_elevations(hObject, eventdata, handles)

% Get 2D ITD Data (= all elevations) from given azimuth of one subject
% theoretical must be always the same

global DB
global ANGLES
global current_subject
global current_db
global azimuth_real
global fs

itd_2d = [];

if (strcmp(current_db,'universal') == 1)
    
    [~,hrir_length,fs] = get_matrixvalue_universal(0,0,current_subject,ANGLES);
         
    indizes = find(ANGLES(:,1) == azimuth_real);
    elevation_values = zeros(length(indizes));
    
    for i=1:length(indizes)
        elevation_values(i) = ANGLES(indizes(i),2);
    end
    
    itd_2d = zeros(1,length(indizes));
        
    for i = 1:length(indizes)
        row_value = get_matrixvalue_universal(elevation_values(i),azimuth_real,current_subject,ANGLES);
        left = squeeze(DB(current_subject,row_value,1,1:hrir_length));
        right = squeeze(DB(current_subject,row_value,2,1:hrir_length));
        
        itd_2d(i) = calculate_itd(left,right,fs);
    end
    
else
    
    indizes = find(ANGLES(:,1) == azimuth_real);
    elevation_values = zeros(1,length(indizes));
    
    for i=1:length(indizes)
        elevation_values(i) = ANGLES(indizes(i),2);
    end
    
    elevation_values = sort(elevation_values);  
    itd_2d = zeros(1,length(elevation_values));
    
    for i=1:length(elevation_values)   
        itd_2d(i) = calculate_itd(squeeze(double(DB(current_subject,get_matrixvalue(azimuth_real,elevation_values(i),ANGLES),1,:))),squeeze(double(DB(current_subject,get_matrixvalue(azimuth_real,elevation_values(i),ANGLES),2,:))),fs);
    end  
    
end

end

