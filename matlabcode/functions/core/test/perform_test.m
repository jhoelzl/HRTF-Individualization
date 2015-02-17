function perform_test(type)

% Perform Parameter Testing

% INPUT
% type: 'local' or 'global' PCW model

% Config
weight_model_parameters.type = type;
text_input_modes = {'Raw HRIR','Minimum-phase HRIR','DTF lin','DTF log'};

if (strcmp(weight_model_parameters.type,'local'))

    % CONFIG for PCA-MODEL ONLY
    dbs = {'ircam','cipic','ari'};
    file_name_add = '_bin'; % add string for filename
    comp_error = 1; % Calc Error averaged acrsoss signal bins in frequency and time domain
    comp_error_bin = 1; % Calc Error for each frequency bin
    comp_error_pcw = 0; % Calc PCW Error
    
    data_set_parameters.use_drirs = 1; % Import DRIRs instead of HRIRs, if available
    data_set_parameters.bp_mode = [0]; % bp=0 no bp, or 1: using bp
    data_set_parameters.densities = [100]; % percent number of source angles;
    data_set_parameters.densities_local = 0; %1= in addition calculate PCA for all directions seperately;
    data_set_parameters.subjects = [100]; % percent number of subjects
    data_set_parameters.ears = {1 [1 2]}; % ears {1  2 [1 2]}
    data_set_parameters.smoothing_ratio = [1]; % smooth ratio of Fourier coefficients
    model_parameters.input_modes = [1:4];% lin and log magnitude
    model_parameters.fft_size = [];
    model_parameters.input_structures = [2]; % Subj or Freq or Pos as columns
    model_parameters.ear_modes = [1 2];
    model_parameters.type = 'pca';
    model_parameters.pc_numbers = [1 5 10 20 50]; % PC Numbers %1 5 10 20, +maximum automatically
    add_max_pc = 1;

elseif (strcmp(weight_model_parameters.type,'global'))
    
    % CONFIG for PCA-SH-MODEL ONLY
    dbs = {'ari','cipic','ircam'};
    file_name_add = '_exam'; % add "_string" for filename
    comp_error = 1; % Calc Error over signal bins in frequncy and time domain
    comp_error_bin = 0; % Calc Error for frequency bin
    comp_error_pcw = 0; % Calc PCW Error
    
    model_parameters.type = 'pca';
    model_parameters.fft_size = [];
    data_set_parameters.use_drirs = 1; % Import DRIRs instead of HRIRs, if available
    data_set_parameters.bp_mode = [0]; % bp=0 no bp, or 1: using bp
    data_set_parameters.ears = {[1 2]}; % ears {1  2 [1 2]}
    data_set_parameters.smoothing_ratio = [1];
    data_set_parameters.densities = [100]; % percent number of source angles
    data_set_parameters.densities_local = 0; %1= in addition calculate PCA for all directions separately;
    data_set_parameters.subjects = [100]; % percent number of subjects
    model_parameters.input_modes = [4]; % signal representation
    model_parameters.input_structures = [2];
    model_parameters.ear_modes = [2];
    model_parameters.pc_numbers = [1 5 10 20 50];
    add_max_pc = 1;
    weight_model_parameters.order = [1 2 3 4 8];
    weight_model_parameters.regularize = [0]; % 1=Matrix Regularization
end

for db=1:length(dbs)
    tic;
    total_counter = 0;
    netto_calc = 0;
    clearvars error m 
    m.database.name = dbs{db};
    m.database.use_drirs = data_set_parameters.use_drirs;            
    
    % Load DB    
    m = database_process(m);
    
    % Additional Computation of Local PCA
    if (data_set_parameters.densities_local == 1)
        local_pos = 1:size(m.database.hrirs,2);
    else
        local_pos = [];
    end
        
    % Initialze Variables
    total_calc = length(data_set_parameters.subjects)*length(data_set_parameters.bp_mode)*length(data_set_parameters.smoothing_ratio)*(length(data_set_parameters.densities)+length(local_pos))*length(data_set_parameters.ears)*length(model_parameters.input_modes)*length(model_parameters.input_structures)*length(model_parameters.ear_modes);
    pcs_variance = zeros(length(data_set_parameters.subjects),length(data_set_parameters.bp_mode),length(data_set_parameters.densities)+length(local_pos),length(data_set_parameters.ears),length(model_parameters.input_modes),length(model_parameters.input_structures),length(model_parameters.ear_modes),length(data_set_parameters.smoothing_ratio),200);
    
    if strcmp(weight_model_parameters.type,'global')
    sh_cond = zeros(length(data_set_parameters.subjects),length(data_set_parameters.bp_mode),length(data_set_parameters.densities)+length(local_pos),length(data_set_parameters.ears),length(model_parameters.input_modes),length(model_parameters.input_structures),length(model_parameters.ear_modes),length(data_set_parameters.smoothing_ratio),length(model_parameters.pc_numbers)+1,length(weight_model_parameters.order));    
    end
    
    if (comp_error == 1)
        if strcmp(weight_model_parameters.type,'local') 
        error.sd = zeros(length(data_set_parameters.subjects),length(data_set_parameters.bp_mode),length(data_set_parameters.densities)+length(local_pos),length(data_set_parameters.ears),length(model_parameters.input_modes),length(model_parameters.input_structures),length(model_parameters.ear_modes),length(data_set_parameters.smoothing_ratio),length(model_parameters.pc_numbers)+1,size(m.database.hrirs,1),size(m.database.hrirs,2),size(m.database.hrirs,3));
        error.sdr = zeros(length(data_set_parameters.subjects),length(data_set_parameters.bp_mode),length(data_set_parameters.densities)+length(local_pos),length(data_set_parameters.ears),length(model_parameters.input_modes),length(model_parameters.input_structures),length(model_parameters.ear_modes),length(data_set_parameters.smoothing_ratio),length(model_parameters.pc_numbers)+1,size(m.database.hrirs,1),size(m.database.hrirs,2),size(m.database.hrirs,3));
        elseif strcmp(weight_model_parameters.type,'global')
        error.sd = zeros(length(data_set_parameters.subjects),length(data_set_parameters.bp_mode),length(data_set_parameters.densities)+length(local_pos),length(data_set_parameters.ears),length(model_parameters.input_modes),length(model_parameters.input_structures),length(model_parameters.ear_modes),length(data_set_parameters.smoothing_ratio),length(model_parameters.pc_numbers)+1,length(weight_model_parameters.order),length(weight_model_parameters.regularize),size(m.database.hrirs,1),size(m.database.hrirs,2),size(m.database.hrirs,3));
        error.sdr = zeros(length(data_set_parameters.subjects),length(data_set_parameters.bp_mode),length(data_set_parameters.densities)+length(local_pos),length(data_set_parameters.ears),length(model_parameters.input_modes),length(model_parameters.input_structures),length(model_parameters.ear_modes),length(data_set_parameters.smoothing_ratio),length(model_parameters.pc_numbers)+1,length(weight_model_parameters.order),length(weight_model_parameters.regularize),size(m.database.hrirs,1),size(m.database.hrirs,2),size(m.database.hrirs,3));    
        end
    end
        
    if (comp_error_bin == 1)    
        if strcmp(weight_model_parameters.type,'local') 
        error.sd_bin = zeros(length(data_set_parameters.subjects),length(data_set_parameters.bp_mode),length(data_set_parameters.densities)+length(local_pos),length(data_set_parameters.ears),length(model_parameters.input_modes),length(model_parameters.input_structures),length(model_parameters.ear_modes),length(data_set_parameters.smoothing_ratio),length(model_parameters.pc_numbers)+1,size(m.database.hrirs,1),size(m.database.hrirs,2),size(m.database.hrirs,3),size(m.database.hrirs,4));
        elseif strcmp(weight_model_parameters.type,'global')
        error.sd_bin = zeros(length(data_set_parameters.subjects),length(data_set_parameters.bp_mode),length(data_set_parameters.densities)+length(local_pos),length(data_set_parameters.ears),length(model_parameters.input_modes),length(model_parameters.input_structures),length(model_parameters.ear_modes),length(data_set_parameters.smoothing_ratio),length(model_parameters.pc_numbers)+1,length(weight_model_parameters.order),length(weight_model_parameters.regularize),size(m.database.hrirs,1),size(m.database.hrirs,2),size(m.database.hrirs,3),size(m.database.hrirs,4));
        end
    end
    
    
    
    % Go through all Data Set parameters
    for bp=1:length(data_set_parameters.bp_mode)
        for sub=1:length(data_set_parameters.subjects)
            for ears = 1:length(data_set_parameters.ears)
                for smooth = 1:length(data_set_parameters.smoothing_ratio)
                    for density = 1:length(data_set_parameters.densities)+length(local_pos)                       
                        
                        % Local PCA
                        if (density > length(data_set_parameters.densities))
                           m.dataset.parameter.calc_pos = density - length(data_set_parameters.densities);
                        else
                           m.dataset.parameter.calc_pos = 0;
                           m.dataset.parameter.density = data_set_parameters.densities(density); 
                        end
                        
                        % Data Process
                        m.dataset.parameter.fft_size = model_parameters.fft_size;
                        m.dataset.parameter.smooth_ratio = data_set_parameters.smoothing_ratio(smooth);
                        m.dataset.parameter.bp_mode = data_set_parameters.bp_mode(bp);
                        m.dataset.parameter.ears = data_set_parameters.ears(ears);
                        m.dataset.parameter.subjects = data_set_parameters.subjects(sub);
                        m.weight_model.parameter.type = weight_model_parameters.type;
                        
                        if strcmp(m.weight_model.parameter.type,'global')
                        m.weight_model.parameter.type = weight_model_parameters.type;                        
                        m.weight_model.parameter.order_initial = max(weight_model_parameters.order);
                        end
                        
                        m = dataset_process(m);
                        m.set.angle_ids = 1:size(m.dataset.angles,1);
                        m.set.subjects = 1:size(m.dataset.hrirs,1);
                        
                        conf.densities_real(density) = size(m.dataset.angles,1);
                        conf.dataset.subjects(sub) = m.dataset.parameter.subs;
                        conf.dataset.angles{density} = m.dataset.angles;
                        conf.dataset.angle_ids{density} = m.dataset.angle_ids;
                        conf.frequency_smoothing(smooth) = m.dataset.parameter.frequency_smooth;

                        % Create Model Stuff
                        for input_mode =1:length(model_parameters.input_modes) 
                            for input_struct=1:length(model_parameters.input_structures)
                                for ear_mode = 1:length(model_parameters.ear_modes)     
                                    
                                    % Show Calculation Status
                                    fprintf('\nDB: %s\n',dbs{db})
                                    fprintf('Bandpass: %i\n',m.dataset.parameter.bp_mode);
                                    fprintf('Subjects: %i%% (%i)\n',data_set_parameters.subjects(sub),conf.dataset.subjects(sub));
                                    fprintf('Ears: %s\n',num2str(cell2mat(data_set_parameters.ears(ears)))); 
                                    fprintf('Smoothing Ratio: %i (%i)\n',data_set_parameters.smoothing_ratio(smooth),conf.frequency_smoothing(smooth));
                                    if (m.dataset.parameter.calc_pos == 0)
                                    fprintf('Source Density: %2.1f%% (%i)\n',data_set_parameters.densities(density),conf.densities_real(density));
                                    else
                                    fprintf('Local PCA: Angle ID %i\n',m.dataset.parameter.calc_pos);    
                                    end
                                    fprintf('Input Mode: %s\n',text_input_modes{model_parameters.input_modes(input_mode)});
                                    fprintf('Input Structure: %i\n',model_parameters.input_structures(input_struct));
                                    fprintf('Ear Mode: %i\n',model_parameters.ear_modes(ear_mode)); 
                                    total_counter = total_counter +1;
                                    fprintf('Total Calc: %i/%i - %2.1f%%\n',total_counter,total_calc,total_counter/total_calc*100);

                                    % Do not calculate again a second smooth value with time domain signals
                                    if(smooth > 1) && (model_parameters.input_modes(input_mode) < 3)
                                        fprintf('Not calculate again (Smooth)\n')
                                        if (comp_error == 1)
                                            error.sd(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,:,:,:,:) = error.sd(sub,bp,density,ears,input_mode,input_struct,ear_mode,1,:,:,:,:);  
                                            error.sdr(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,:,:,:,:) = error.sdr(sub,bp,density,ears,input_mode,input_struct,ear_mode,1,:,:,:,:);
                                        end
                                        
                                        if (comp_error_bin == 1)
                                        error.sd_bin(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,:,:,:,:,:) = error.sd_bin_pos(sub,bp,density,ears,input_mode,input_struct,ear_mode,1,:,:,:,:,:);  
                                        end    
                                        
                                        if (comp_error_pcw == 1)
                                            if strcmp(m.weight_model.parameter.type,'global')
                                            error.weight_model.shape_error(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,:,:,:,:,:,:) = error.weight_model.shape_error(sub,bp,density,ears,input_mode,input_struct,ear_mode,1,:,:,:,:,:,:);
                                            error.weight_model.weight_error(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,:,:,:,:,:,:) = error.weight_model.weight_error(sub,bp,density,ears,input_mode,input_struct,ear_mode,1,:,:,:,:,:,:);
                                            end
                                        end
                                        pcs_variance(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,:) = pcs_variance(sub,bp,density,ears,input_mode,input_struct,ear_mode,1,:); 
                                    else

                                        % Do not calculate again earmode=2, when only one ear is selected, because the structure of the input matrix remains the same                                
                                        if (ear_mode == 2) && (length((cell2mat(m.dataset.parameter.ears))) == 1)
                                            fprintf('Not calculate again (Earmode)\n')
                                            if (comp_error == 1)
                                                error.sd(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,:,:,:,:) = error.sd(sub,bp,density,ears,input_mode,input_struct,1,smooth,:,:,:,:);                                    
                                                error.sdr(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,:,:,:,:) = error.sdr(sub,bp,density,ears,input_mode,input_struct,1,smooth,:,:,:,:);
                                            end
                                                
                                            if (comp_error_bin == 1)
                                            error.sd_bin(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,:,:,:,:,:) = error.sd_bin(sub,bp,density,ears,input_mode,input_struct,1,smooth,:,:,:,:,:);                        
                                            end
    
                                            if (comp_error_pcw == 1)
                                                if strcmp(m.weight_model.parameter.type,'global')
                                                %error.weight_model.shape_error(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,:,:,:,:,:,:) = error.weight_model.shape_error(sub,bp,density,ears,input_mode,input_struct,1,smooth,:,:,:,:,:,:);
                                                error.weight_model.weight_error(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,:,:,:,:,:,:) = error.weight_model.weight_error(sub,bp,density,ears,input_mode,input_struct,1,smooth,:,:,:,:,:,:);
                                                end
                                            end
                                            pcs_variance(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,:) = pcs_variance(sub,bp,density,ears,input_mode,input_struct,1,smooth,:);
                                        else
                                            
                                            % Model Calculation
                                            netto_calc = netto_calc +1;
                                            fprintf('Netto Calc: %i\n',netto_calc);
                                            m.model.parameter.type = model_parameters.type;                                           
                                            m.model.parameter.ear_mode = model_parameters.ear_modes(ear_mode);
                                            m.model.parameter.input_mode = model_parameters.input_modes(input_mode);
                                            m.model.parameter.structure = model_parameters.input_structures(input_struct);                                            
                                           
                                            m = compute_model(m);
                                            model_parameters.pc_numbers2 = model_parameters.pc_numbers;
                                            if (add_max_pc == 1)
                                            model_parameters.pc_numbers2(end+1) = size(m.model.basis,2);
                                            model_parameters.pc_numbers2 = unique(model_parameters.pc_numbers2);
                                            end
                                            
                                            if (length(m.model.variance) < 200)
                                            pcs_variance(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,1:length(m.model.variance)) = m.model.variance;
                                            pcs_variance(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,length(m.model.variance)+1:end) = m.model.variance(end);
                                            else
                                            pcs_variance(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,:) = m.model.variance(1:200);    
                                            end
                                            
                                            % Only go through this, when also error should be calculated not only variance
                                            if (comp_error == 1) || (comp_error_bin == 1) || (comp_error_pcw == 1)
                                                for pcs = 1:length(model_parameters.pc_numbers2)
                                                    m.model.parameter.pcs = model_parameters.pc_numbers2(pcs);
                                                    fprintf('PCs: %i\n',m.model.parameter.pcs);
                                                    if strcmp(m.weight_model.parameter.type,'global')                                       
                                                        for shorder = 1:length(weight_model_parameters.order)                                            
                                                            m.weight_model.parameter.order = weight_model_parameters.order(shorder);    
                                                            
                                                            for reg=1:length(weight_model_parameters.regularize)
                                                                m.weight_model.parameter.regularize = weight_model_parameters.regularize(reg);    
                                                                fprintf('SH Order: %i\n',m.weight_model.parameter.order);
                                                                fprintf('SH Regularize: %i\n',m.weight_model.parameter.regularize);
                                                                m = compute_weight_model(m);
                                                                m = evaluate_model(m);
                                                                m.error = compute_error(m);
                                                                
                                                                sh_cond(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,shorder) = m.weight_model.sh_cond;
                                                                if (cell2mat(m.dataset.parameter.ears) == [1,2])
                                                                    
                                                                    if (comp_error ==1)
                                                                    error.sd(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,shorder,reg,:,:,:) = m.error.sd;
                                                                    error.sdr(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,shorder,reg,:,:,:) = m.error.sdr;
                                                                    end
                                                                    
                                                                    if (comp_error_bin == 1)
                                                                    error.sd_bin(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,shorder,reg,:,:,:,:) = m.error.sd_bin;
                                                                    end
                                                                    
                                                                    if (comp_error_pcw == 1)
                                                                    %error.weight_model.shape_error(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,shorder,reg,:,:,:,:) = m.weight_model.error.shape_error;
                                                                    error.weight_model.weight_error(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,shorder,reg,:,:,1:size(m.weight_model.error.weight_error,4)) = m.weight_model.error.weight_error;
                                                                    end
                                                                else
                                                                    
                                                                    if (comp_error == 1)
                                                                    error.sd(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,shorder,reg,:,:,1) = m.error.sd;
                                                                    error.sd(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,shorder,reg,:,:,2) = m.error.sd;  
                                                                    error.sdr(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,shorder,reg,:,:,1) = m.error.sdr;
                                                                    error.sdr(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,shorder,reg,:,:,2) = m.error.sdr;                                                                    
                                                                    end
                                                                    
                                                                    if (comp_error_bin ==1)
                                                                    error.sd_bin(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,shorder,reg,:,:,1,:) = m.error.sd_bin;
                                                                    error.sd_bin(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,shorder,reg,:,:,2,:) = m.error.sd_bin;                                                                    
                                                                    end
                                                                    
                                                                    if (comp_error_pcw ==1)
                                                                    
                                                                    error.weight_model.weight_error(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,shorder,reg,:,:,1,1:size(m.weight_model.error.weight_error,4)) = m.weight_model.error.weight_error;
                                                                    error.weight_model.weight_error(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,shorder,reg,:,:,2,1:size(m.weight_model.error.weight_error,4)) = m.weight_model.error.weight_error;
                                                                    %error.weight_model.shape_error(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,shorder,reg,:,:,:,:) = m.weight_model.error.shape_error;
                                                                    %error.weight_model.shape_error(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,shorder,reg,:,:,:,:) = m.weight_model.error.shape_error;
                                                                    end
                                                                end
                                                            end
                                                        end                                                                                    
                                                    elseif strcmp(m.weight_model.parameter.type,'local')
                                                        m = evaluate_model(m);
                                                        m.error = compute_error(m);
                                                                                          
                                                        if (length((cell2mat(m.dataset.parameter.ears))) == 2)
                                                            
                                                            if (comp_error ==1)
                                                                error.sd(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,:,1:size(m.error.sd,2),:) = m.error.sd;
                                                                error.sdr(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,:,1:size(m.error.sdr,2),:) = m.error.sdr;                                                        
                                                            end
                                                            
                                                            if (comp_error_bin == 1)
                                                            error.sd_bin(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,:,1:size(m.error.sd_bin,2),:,:) = m.error.sd_bin;
                                                            end
                                                            
                                                        else
                                                            if (comp_error ==1)   
                                                            error.sd(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,:,:,1) = m.error.sd;                                                            
                                                            error.sd(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,:,:,2) = m.error.sd;
                                                            error.sdr(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,:,:,1) = m.error.sdr;                                                                                                                 
                                                            error.sdr(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,:,:,2) = m.error.sdr;
                                                            end
                                                            
                                                            if (comp_error_bin == 1)
                                                            error.sd_bin(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,:,:,1,:) = m.error.sd_bin;
                                                            error.sd_bin(sub,bp,density,ears,input_mode,input_struct,ear_mode,smooth,pcs,:,:,2,:) = m.error.sd_bin;
                                                            end
                                                            
                                                        end
                                                    end
                                                end
                                            end  
                                        end
                                    end
                                end                    
                            end
                        end
                    end
                end
            end
        end
    end

    % Define Filename
    if strcmp(weight_model_parameters.type,'local') 
    file_name = sprintf('../matlabdata/test_pca/pca_%s%s.mat',dbs{db},file_name_add);
    file_name_old = sprintf('../matlabdata/test_pca/pca_%s_%s%s.mat',dbs{db},datestr(now, 'yy-mm-dd'),file_name_add);
    elseif strcmp(weight_model_parameters.type,'global')
    file_name = sprintf('../matlabdata/test_pca_sh/pca_sh_%s%s.mat',dbs{db},file_name_add);
    file_name_old = sprintf('../matlabdata/test_pca_sh/pca_sh_%s_%s%s.mat',dbs{db},datestr(now, 'yy-mm-dd'),file_name_add);
    conf.sh_orders = weight_model_parameters.order;
    
    end
    
    % Save Test Configuration
    conf.pc_numbers = model_parameters.pc_numbers2;
    conf.ear_modes = model_parameters.ear_modes;
    conf.ears = data_set_parameters.ears;
    conf.input_structures = model_parameters.input_structures;
    conf.input_modes = model_parameters.input_modes;
    conf.subjects = data_set_parameters.subjects;
    conf.smoothing = data_set_parameters.smoothing_ratio;    
    conf.bp = data_set_parameters.bp_mode;
    conf.database.densities = data_set_parameters.densities;
    conf.database.angles = m.database.angles;
    conf.database.name = m.database.name;
    conf.database.fs = m.database.fs;
    
    if strcmp(weight_model_parameters.type,'global')
    conf.regularize = weight_model_parameters.regularize;   
    end
    
    % Error Types
    conf.error_type = {};
    
    if (comp_error ==1)
    conf.error_type{end+1} = 'sd';
    conf.error_type{end+1} = 'sdr';
    end
    
    if (comp_error_bin ==1)
    conf.error_type{end+1} = 'sd_bin';    
    end
    
    if (comp_error_pcw ==1)
    conf.error_type{end+1} = 'weight_model.weight_error';
    end
    
    % Before saving, rename existing files
    if (exist(file_name, 'file') == 2)
        if (exist(file_name_old, 'file') == 2)
        delete(file_name_old)
        end
        movefile(file_name,file_name_old);
    end
    
    % Save Data
    if (comp_error == 1) || (comp_error_bin == 1) || (comp_error_pcw == 1)
        if strcmp(weight_model_parameters.type,'global')
        conf.sh_cond = sh_cond;
        end
    save(file_name,'error','pcs_variance','conf','-v7.3');  
    else
    save(file_name,'pcs_variance','conf','-v7.3');      
    end
    
    calc_time = toc;
    %send_mail('hoelzl.josef@gmail.com',sprintf('Finished Numerical Test (%s) in %2.1f hours',dbs{db},calc_time/3600))
end
     

end
