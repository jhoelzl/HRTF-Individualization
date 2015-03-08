function [weights_selected] = pca3_weights_positions(pos_ind,hObject, eventdata, handles)

% Get PCWs of all subjects for choosen static position

global weights
global subjects

% Static position, only one position // Trajectories
if (get(handles.soundmode,'Value') == 1) || (get(handles.soundmode,'Value') == 2) 
    weights_selected = weights;  
end

    
% All positions
if (get(handles.soundmode,'Value') == 3)
    
    % Reshape first to merge PCWs for subjects and positions
    weights_per_subject = reshape(weights,[subjects,size(weights,1)/subjects,1,size(weights,2)]);
    weights_selected = squeeze(weights_per_subject(:,pos_ind,:)); 
end
    

end