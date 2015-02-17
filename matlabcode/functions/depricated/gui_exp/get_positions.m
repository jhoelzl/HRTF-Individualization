function [ current_positions ] = get_positions( hObject, eventdata, handles )

global ANGLES
global current_db

switch (get(handles.soundmode,'Value'))
    case 1
    % static sound source 
    current_positions = get(handles.position,'Value');
    
    case 2
    % trajectories
    [~,trajectory_info] = trajectory_list(current_db,ANGLES);
    current_positions = get_trajectory(ANGLES,trajectory_info(get(handles.position,'Value'),1),trajectory_info(get(handles.position,'Value'),2));

    case 3
    % all positions in db, then select one position for tuning
    current_positions = 1:size(ANGLES,1);   
end



end