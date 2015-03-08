function azimuth_playbutton(hObject, eventdata, handles)
global azimuth_real
global ANGLES

    indizes = find(ANGLES(:,1) == azimuth_real);
    elevation_values = zeros(1,length(indizes));
    
    for i=1:length(indizes)
        elevation_values(i) = ANGLES(indizes(i),2);
    end
    
    % Label "Play Elevation" button
    text_play_elevation = sprintf('Play %i Elevations',length(elevation_values));
    set(handles.play_all_elevations,'String', text_play_elevation);