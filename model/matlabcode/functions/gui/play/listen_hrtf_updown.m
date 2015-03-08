function listen_hrtf_updown(hObject, eventdata, handles)
%   Listen to HRTFs in Elevation 90 and -90 (or db source position maximum and minimum) with Azimuth 0

global current_db
global DB
global current_subject
global fs
global ANGLES

set(handles.status_text,'BackGroundColor', 'r'); 
set(handles.status_text,'ForeGroundColor', 'w'); 

switch current_db 
    
    case 'ari'
        
    elevation_values = [80 -30];  
    
    for i=1:length(elevation_values)
        
        out_left = squeeze(double(DB(current_subject,get_matrixvalue(0,elevation_values(i),ANGLES),1,:)));
        out_right = squeeze(double(DB(current_subject,get_matrixvalue(0,elevation_values(i),ANGLES),2,:))); 
        
        play_sound([out_left'; out_right'],fs);
        pause(0.2)
    end
    
    case {'cipic','ircam'}    
        
        switch(current_db)
            
            case 'cipic'
            play_vektor = [13 613];  % Play Elevation Values for -45 and 90 / Azimuth = 0;
            case 'ircam'
            play_vektor = [1 187];    
        end
   
    for i=1:length(play_vektor)
    out_left = squeeze(DB(current_subject,play_vektor(i),1,:));
    out_right = squeeze(DB(current_subject,play_vektor(i),2,:));
    
        % GUI Text Status
        if (i ==1)
        message = 'Play up          ';
        else
        message = 'Play down          ';
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
