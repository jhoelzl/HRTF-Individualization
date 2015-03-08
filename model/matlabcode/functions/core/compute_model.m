function m = compute_model(m)

% Compute the Model based on a given Database and Model Parameter Set

switch m.model.parameter.input_mode
    case 1
        m.model.matrix = reshape_model(m.dataset.hrirs,m.model.parameter.structure,m.model.parameter.ear_mode);
        m.model.mean = mean(m.model.matrix);
        m.model.parameter.sz = size(m.dataset.hrirs);        
    case 2
        m.model.matrix = reshape_model(m.dataset.mphrirs,m.model.parameter.structure,m.model.parameter.ear_mode);
        m.model.mean = mean(m.model.matrix);
        m.model.parameter.sz = size(m.dataset.hrirs);        
    case 3
        % Here we may need to leave DC and Nyquist Component Out
        m.model.matrix = reshape_model(m.dataset.hrtfs(:,:,:,1:(size(m.dataset.hrtfs,4)/2+1)),m.model.parameter.structure,m.model.parameter.ear_mode);
        m.model.mean = mean(m.model.matrix);
        sz = size(m.dataset.hrtfs); sz(4) = sz(4)/2 + 1;
        m.model.parameter.sz = sz;        
    case 4
        m.model.matrix = reshape_model(20*log10(m.dataset.hrtfs(:,:,:,1:(size(m.dataset.hrtfs,4)/2+1))),m.model.parameter.structure,m.model.parameter.ear_mode);
        m.model.mean = mean(m.model.matrix);
        sz = size(m.dataset.hrtfs); sz(4) = sz(4)/2 + 1;
        m.model.parameter.sz = sz;        
end

if (strcmp(m.model.parameter.type,'pca') == 1)
    % Principal Component Analysis
    % Calculate PCA Base Functions
    % Mean is subtracted inside princomp function
    [m.model.basis,m.model.weights,m.model.latent] = princomp(m.model.matrix,'econ');

    % m.model.basis[:,pcs] [514 514]
    % m.model.weights[:,pcs][9163 514]    
    % Calculate PCA Weights
    % model.weights = m.model.matrix * model.basis; 

    % PCA Variance
    m.model.variance = cumsum(m.model.latent)/sum(m.model.latent)*100;
end

if (strcmp(m.model.parameter.type,'ica') == 1)
    % Independent Component Analysis
    [m.model.basis,m.model.weights,w] = fastica(m.model.matrix, 'numOfIC', m.model.parameter.pcs,'lastEig', m.model.parameter.pcs,'verbose','on','interactivePCA','off');  
    m.model.basis = m.model.basis';
    m.model.latent = zeros(200,1);
    m.model.variance = zeros(200,1);
end

if (strcmp(m.model.parameter.type,'nmf') == 1)
    % Non-negative Matrix Factorization
    [m.model.weights,m.model.basis] = nnmf(m.model.matrix,m.model.parameter.pcs);
    m.model.basis = m.model.basis';
    m.model.latent = zeros(200,1);
    m.model.variance = zeros(200,1);
end

if isfield(m.model.parameter,'pcs')
    if (m.model.parameter.pcs > size(m.model.basis,2))
        m.model.parameter.pcs = size(m.model.basis,2);
    end
end
end