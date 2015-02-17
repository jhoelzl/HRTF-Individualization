function m = evaluate_model(m)

% Model Reconstruction

if (m.model.parameter.pcs > size(m.model.basis,2))
    m.model.parameter.pcs = size(m.model.basis,2);
end

switch m.weight_model.parameter.type
    case 'global'
        model_data = m.weight_model.weights(:,1:m.model.parameter.pcs) * m.model.basis(:,1:m.model.parameter.pcs)' + repmat(m.model.mean,[size(m.model.matrix,1) ,1]);        
    case 'local'
        model_data = m.model.weights(:,1:m.model.parameter.pcs) * m.model.basis(:,1:m.model.parameter.pcs)' + repmat(m.model.mean,[size(m.model.matrix,1) ,1]);
end

m = compute_set(m,model_data);

end