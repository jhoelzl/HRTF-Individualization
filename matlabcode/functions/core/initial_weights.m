function m = initial_weights(m)

% Compute Mean and Std for PC or SH Weights

switch m.weight_model.parameter.type
    case 'global'
    
    % Mean over Subjects
    m.weight_model.sh_weights_mn= mean(m.weight_model.sh_weights,1);
    m.weight_model.sh_weights_std = std(m.weight_model.sh_weights,1);
    
    case 'local'
    sz_temp = m.model.parameter.sz; sz_temp(3) = 1;sz_temp(4) = size(m.model.weights,2);
    weights = ireshape_model(m.model.weights,m.model.parameter.structure,sz_temp,m.model.parameter.ear_mode);
    m.model.weights_mn = mean(weights,1);
    m.model.weights_std = std(weights,1); 
end
end