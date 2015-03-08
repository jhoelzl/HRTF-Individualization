function [m] = core_calc(db,calc_mode,force_calc,m)

% Model Calculation; use this function for a quick computation

% Input
% db = hrtf db_name
% optional: calc_mode:  1= calc entire model
%                       2= only pc variance, without evaulation and error calculation
%                       3= Only preprocess until Model computation
% optional: force_calc: 0 = import precalculated file if available;
%                       1 = force new calculation of the model
% optional: m:  overwrite some or all parameters below

if (nargin < 2)
   calc_mode = 1; 
end

if (nargin < 3)
   force_calc = 0; 
end

if (nargin < 4)
    m = [];
end

% Config
if ~isfield(m,'database')
    m.database.name = db; 
end

if ~isfield(m,'dataset')
    m.dataset.parameter.bp_mode = 0; % bp=0 no bp, or 1: using bp
    m.dataset.parameter.density = 100; % percent number of source angles;
    m.dataset.parameter.calc_pos = 0; % only local PCA; indicate Angle ID
    m.dataset.parameter.subjects = 100; % percent number of subjects
    m.dataset.parameter.ears = {[1 2]}; % ears {1  2 [1 2]}
    m.dataset.parameter.smooth_ratio = 1; % smooth ratio of Fourier coefficients
    m.dataset.parameter.fft_size = []; %% FFT Size, leave blank [] for standard
end

if ~isfield(m,'model')
    m.model.parameter.input_mode = 4;% lin and log magnitude
    m.model.parameter.structure = 2; % Subj or Freq or Pos as columns
    m.model.parameter.ear_mode = 2; % 1= ears as observations in rows, 2= ears at independent variables in columns
    m.model.parameter.type = 'pca'; % pca, ica or nmf
    m.model.parameter.pcs = 10; % PC Numbers %1 5 10 20
end

if ~isfield(m,'weight_model')
    m.weight_model.parameter.type = 'global'; % local or global
    m.weight_model.parameter.order = 10; % SH Order
    m.weight_model.parameter.order_initial = max(m.weight_model.parameter.order); % SH Order
    m.weight_model.parameter.regularize = 0; % Matrix Regularization
end


% Check, if Model is precalculated, then use this instead of calculate it
% again
[check_file,data_file] = check_data(m);
if (check_file == 1)  && (force_calc == 0)
    disp('Load precalculated Model')
    load(data_file);
else
    
    % Database      
    m = database_process(m);

    % Dataset
    m = dataset_process(m);

    % Set Angles
    m.set.angle_ids = 1:size(m.dataset.angles,1);

    if (calc_mode < 3)

        % Compute Model
        m = compute_model(m);

        % Compute Weight Model
        if strcmp(m.weight_model.parameter.type,'global') 
            m = compute_weight_model(m);
        end

        % Initialize Weights
        % m = initial_weights(m);

        % Reconstruct Weights
        % m = reconstruct_weights(m)

        if (calc_mode == 1) 
            % Reconstruct Model
            m.set.subjects = 1:size(m.dataset.hrirs,1); % reconstruct only subject ID 1
            m = evaluate_model(m);
            m.error = compute_error(m);
        end

    end
    
    % Save Precalculated ICA Data
    save(data_file,'m','-v7.3');
end

end