function [ subjects ] = getSubjects(hObject, eventdata, handles)

% Get Database size value (=Subjects)
all_sizes = str2num(get(handles.database_size,'String'));
subjects = all_sizes(get(handles.database_size,'Value'));

end