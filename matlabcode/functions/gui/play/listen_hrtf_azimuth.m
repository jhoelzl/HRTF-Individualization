function listen_hrtf_azimuth(hObject, eventdata, handles)
%   Listen all HRTFs in Loop
global current_db
global DB
global ANGLES
global current_subject
global fs
global elevation_real

set(handles.status_text,'BackGroundColor', 'r'); 
set(handles.status_text,'ForeGroundColor', 'w'); 

if (strcmp(current_db,'universal') == 1)
    
    [~, hrir_length,fs] = get_matrixvalue_universal(0,0,current_subject);    
    
    indizes = find(ANGLES(:,2) == elevation_real);
    
    azimuth_values = zeros(length(indizes),1);
    for i=1:length(indizes)
        azimuth_values(i) = ANGLES(indizes(i),1);
    end
    
    % Play HRTFs in Loop
    for i = 1:length(indizes)
        out_left = squeeze(DB(current_subject,indizes(i),1,1:hrir_length));
        out_right = squeeze(DB(current_subject,indizes(i),2,1:hrir_length));  
    
        % GUI Text Status
        message = sprintf('Play %i / %i Azimuths          ',i,length(indizes));
        set(handles.status_text,'String', message);

        play_sound([out_left'; out_right'],fs);
        pause(0.2)
    end
    
else
    
    indizes = find(ANGLES(:,2) == elevation_real);    

    for i=1:length(indizes)
        
        out_left = squeeze(DB(current_subject,indizes(i),1,:));
        out_right = squeeze(DB(current_subject,indizes(i),2,:));
        
        % GUI Text Status
        message = sprintf('Play %i / %i Azimuths         ',i,length(indizes));
        set(handles.status_text,'String', message);
    
        play_sound([out_left'; out_right'],fs);
        pause(0.2)   
        
    end
    
end

set(handles.status_text,'ForeGroundColor', [0 0.5 0]);
set(handles.status_text,'BackGroundColor', [230 228 228]/255);
set(handles.status_text,'String', 'Ready          ');

end
