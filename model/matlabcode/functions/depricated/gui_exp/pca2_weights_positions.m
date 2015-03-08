function [weights_selected] = pca2_weights_positions(pos_ind,hObject, eventdata, handles)

% Get weights of all subjects for choosen position

global weights
global subjects


% Static position, only one position // Trajectories
if (get(handles.soundmode,'Value') == 1) || (get(handles.soundmode,'Value') == 2) 
    weights_selected = weights;  
end


% All positions
if (get(handles.soundmode,'Value') == 3)
    
    % Reshape first to merge PCWs for subjects and positions
    weights_per_subject = squeeze(reshape(weights,[subjects,size(weights,1)/subjects,1,size(weights,2)]));
    
    size(weights_per_subject)
    weights_selected = squeeze(weights_per_subject(:,pos_ind,:)); 
end


end

