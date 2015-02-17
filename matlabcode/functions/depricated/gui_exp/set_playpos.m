function set_playpos(hObject, eventdata, handles)
global current_positions

% Set "Play Position"
source_pos = '';
for i=1:length(current_positions)
    source_pos = sprintf('%s%i|',source_pos,i);
end

% Add "all" at the end of the list
source_pos = sprintf('%sall',source_pos);

% Set Values
set(handles.play_positions,'String',source_pos);
set(handles.play_positions,'Value',length(current_positions)+1);


end