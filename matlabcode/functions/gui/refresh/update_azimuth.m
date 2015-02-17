function update_azimuth(hObject, eventdata, handles)

% Get Azimuth Values for given Elevation Value

global current_elevation
global ANGLES
global current_azimuth

% Get All Elevation Listbox values
current_elevation = get(handles.elevation,'Value'); 
all_elevation = str2num(get(handles.elevation,'String'));
elevation_real = all_elevation(current_elevation);

% Get All Azimuth Listbox values
current_azimuth = get(handles.azimuth,'Value'); 
all_azimuth = str2num(get(handles.azimuth,'String'));
azimuth_real = all_azimuth(current_azimuth);

    set(handles.azimuth,'Value', 1);
    indizes = find(ANGLES(:,2) == elevation_real);
    new_azimuth_values = zeros(length(indizes),1);
    
    for i=1:length(indizes)
        new_azimuth_values(i) = ANGLES(indizes(i),1);
    end
    
    new_azimuth_values = sort(new_azimuth_values);    
    set(handles.azimuth,'String', new_azimuth_values);
    
    % Label "Play Azimuth" button
    text_play_azimuth = sprintf('Play %i Azimuths',length(new_azimuth_values));
    set(handles.play_all_azimuth,'String', text_play_azimuth);

    azimuth_playbutton(hObject, eventdata, handles)
    
    
    % If possible, update azimuth to same value before changing elevation
    same_azimuth = find(new_azimuth_values==azimuth_real);
    
    if (~isempty(same_azimuth))
    set(handles.azimuth,'Value', same_azimuth);
    end
            


end
