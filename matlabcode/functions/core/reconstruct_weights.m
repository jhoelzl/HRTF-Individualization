function m = reconstruct_weights(m)

% Reconstruct PCA Input Data with adapted SH and PC Weights
% This function is used by GUI
% Format of model.weight_model.sh_weights_adapt, e.g. [1 9 1 5]
% for  sh order = 2 (=(2+1^2), and 5 PCs
%
% Format of model.model.weights_adapt, e.g. [1 10 1 5]
% for 5 PCs and 10 Positions

switch m.weight_model.parameter.type

    case 'global'
        sz_temp = m.model.parameter.sz; sz_temp(3) = 1;sz_temp(4) = size(m.model.weights,2);
        pcws = ireshape_model(m.model.weights,m.model.parameter.structure,sz_temp,m.model.parameter.ear_mode);

        for e = 1:size(pcws,3)
            pcws_r(1,:,e,:) = m.dataset.sha(:,1:size(m.weight_model.sh_weights,2))*squeeze(m.weight_model.sh_weights_adapt(1,:,e,:));
        end
        
        % Reshape back to 2D Matrix
        m.weight_model.weights = reshape_model(pcws_r,m.model.parameter.structure,m.model.parameter.ear_mode);                               
        pcws = m.weight_model.weights(m.set.angle_ids,:);
        
        % Reconstruction of PCA Decomposition
        model_data = pcws(:,1:m.model.parameter.pcs) * m.model.basis(:,1:m.model.parameter.pcs)' + repmat(m.model.mean,[size(pcws,1) ,1]);        
        

    case 'local'
        % Reshape back to 2D Matrix
        pcws = reshape_model(m.model.weights_adapt,m.model.parameter.structure,m.model.parameter.ear_mode);
        
        % Reconstruction of PCA Decomposition
        model_data = pcws(:,1:m.model.parameter.pcs) * m.model.basis(:,1:m.model.parameter.pcs)' + repmat(m.model.mean,[size(m.model.weights_adapt,2) ,1]); 
end

m = compute_set(m,model_data);

end