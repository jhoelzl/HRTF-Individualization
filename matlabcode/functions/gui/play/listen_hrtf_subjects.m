function listen_hrtf_subjects(handles)

% Listen one specific HRTF form all subjects in loop

global current_db
global DB
global ANGLES
global subjects
global fs
global elevation_real
global azimuth_real

set(handles.status_text,'BackGroundColor', 'r'); 
set(handles.status_text,'ForeGroundColor', 'w'); 


if (strcmp(current_db,'universal') == 1)
    
     % Play HRTFs in Loop
    for i=1:length(subjects)
    
    [value,hrir_length,fs] = get_matrixvalue_universal(elevation_real,azimuth_real,i);      
    out_left = squeeze(DB(i,value,1,1:hrir_length));
    out_right = squeeze(DB(i,value,2,1:hrir_length));  

    % GUI Text Status
    message = sprintf('Play %i / %i Subjects          ',i,length(subjects));
    set(handles.status_text,'String', message);
    
    play_sound([out_left'; out_right'],fs);
    pause(0.1)
    end
    
else
    
    row = get_matrixvalue(azimuth_real,elevation_real,ANGLES);  
    
    for i=1:length(subjects)

        out_left = squeeze(double(DB(i,row,1,:)));
        out_right = squeeze(double(DB(i,row,2,:))); 
        
        % GUI Text Status
        message = sprintf('Play %i / %i Subjects          ',i,length(subjects));
        set(handles.status_text,'String', message);
        
        play_sound([out_left'; out_right'],fs);
        pause(0.2)
    
    end
    
end


set(handles.status_text,'ForeGroundColor', [0 0.5 0]);
set(handles.status_text,'BackGroundColor', [230 228 228]/255);
set(handles.status_text,'String', 'Ready          ');
    
end
