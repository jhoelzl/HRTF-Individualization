function [ sound_out ] = listen_hrtf_elevation(hObject, eventdata, handles)

% Listen to HRTFs (all Elevation data sets) of given Azimuth Value

global current_db
global DB
global ANGLES
global current_subject
global fs
global azimuth_real

set(handles.status_text,'BackGroundColor', 'r'); 
set(handles.status_text,'ForeGroundColor', 'w');  


if (strcmp(current_db,'universal') == 1)
    
     [~,hrir_length] = get_matrixvalue_universal(0,0,current_subject);
         
    indizes = find(ANGLES(:,1) == azimuth_real);
    elevation_values = zeros(length(indizes));
    
    for i=1:length(indizes)
        elevation_values(i) = ANGLES(indizes(i),2);
    end    
     
    
     for i = 1:length(indizes)
        out_left =  squeeze(DB(current_subject,indizes(i),1,1:hrir_length));
        out_right = squeeze(DB(current_subject,indizes(i),2,1:hrir_length));
            
        % GUI Text Status
        message = sprintf('Play %i / %i Elevations          ',i,length(indizes));
        set(handles.status_text,'String', message);
        
        play_sound([out_left'; out_right'],fs);
        pause(0.2)    
    end    
    
else
    
    indizes = find(ANGLES(:,1) == azimuth_real);
    elevation_values = zeros(length(indizes),1);
    
    for i=1:length(indizes)
        elevation_values(i) = ANGLES(indizes(i),2);
    end
    
    elevation_values = sort(elevation_values);  
    
    for i=1:length(elevation_values)
        
        out_left = squeeze(double(DB(current_subject,get_matrixvalue(azimuth_real,elevation_values(i),ANGLES),1,:)));
        out_right = squeeze(double(DB(current_subject,get_matrixvalue(azimuth_real,elevation_values(i),ANGLES),2,:))); 
        
        % GUI Text Status
        message = sprintf('Play %i / %i Elevations          ',i,length(elevation_values));
        set(handles.status_text,'String', message);
    
        play_sound([out_left'; out_right'],fs);
        pause(0.2)
    
    end
    
end

set(handles.status_text,'ForeGroundColor', [0 0.5 0]);
set(handles.status_text,'BackGroundColor', [230 228 228]/255);
set(handles.status_text,'String', 'Ready          ');

end
