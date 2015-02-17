function [ sound_out ] = listen_hrtf_frontback(hObject, eventdata, handles)
% Listen to HRTFs in Azimuth 0 and 180 with Elevation 0

global current_db
global DB
global current_subject
global fs
global ANGLES

set(handles.status_text,'BackGroundColor', 'r'); 
set(handles.status_text,'ForeGroundColor', 'w'); 

    if (strcmp(current_db,'universal') == 1)

    [~,hrir_length,fs] = get_matrixvalue_universal(0,0,current_subject);
    azimuth_values = [0 180];

    % Play HRTFs in Loop
    for i = 1:length(azimuth_values)
        value = get_matrixvalue_universal(0,azimuth_values(i),ANGLES);    
        out_left = squeeze(DB(current_subject,value,1,1:hrir_length));
        out_right = squeeze(DB(current_subject,value,2,1:hrir_length));  

        play_sound([out_left'; out_right'],fs);
        pause(0.2)
    end
else
    
     switch(current_db)
            case 'cipic'
            play_vektor = [213 1013];
            
            case 'ari'
            play_vektor = [7 782]; 
                
            case 'iem'
            play_vektor = [1 13];    
                
            case 'kemar'
            play_vektor = [261 297]; 
            
            case 'ircam'
            play_vektor = [73 85];    
            
      end
    
    for i=1:length(play_vektor)
    out_left = squeeze(DB(current_subject,play_vektor(i),1,:));
    out_right = squeeze(DB(current_subject,play_vektor(i),2,:));
    
    % GUI Text Status
        if (i ==1)
        message = 'Play front          ';
        else
        message = 'Play back          ';
        end
        
        set(handles.status_text,'String', message);
    play_sound([out_left'; out_right'],fs);
    pause(0.25)
    end
    
end

set(handles.status_text,'ForeGroundColor', [0 0.5 0]);
set(handles.status_text,'BackGroundColor', [230 228 228]/255);
set(handles.status_text,'String', 'Ready          ');

end
