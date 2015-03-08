function m = dataset_process(m)

% Define Dataset, Preprocessing

% Define Amount of Source Positions, Minimum 1 Position
if (m.dataset.parameter.calc_pos > 0)
    % Local PCA, only 1 position
    m.dataset.angle_ids = m.dataset.parameter.calc_pos;
    m.dataset.angles = m.database.angles(m.dataset.angle_ids,:);
else
    % Global PCA
    if (m.dataset.parameter.density < 100)
        % Choose Random Angle IDs
        m.dataset.angles = randperm(size(m.database.angles,1));
        m.dataset.angle_ids = m.dataset.angles(round(1:(size(m.database.angles,1)*m.dataset.density/100)));
        m.dataset.angles = m.database.angles(m.dataset.angles(round(1:(size(m.database.angles,1)*m.dataset.density/100))),:);
        if (isempty(m.dataset.angle_ids))
            m.dataset.angle_ids = round(random('unif', 1, size(m.database.hrirs,2)));
            m.dataset.angles = m.database.angles(m.dataset.angle_ids,:);
        end
    else
        % Choose all Source Positions
        m.dataset.angles = m.database.angles;
        m.dataset.angle_ids = 1:size(m.database.angles,1);
    end    
end

% Define Amount of Subjects, Minimum 2 subjects
if (m.dataset.parameter.subjects < 100)
    m.dataset.parameter.subs=round(size(m.database.hrirs,1)*m.dataset.parameter.subjects/100);
    if (m.dataset.parameter.subs < 2) 
        m.dataset.parameter.subs = 2;
    end
else
    m.dataset.parameter.subs = size(m.database.hrirs,1);
end


% Filter Data and Preprocessing
m.dataset.hrirs = m.database.hrirs(1:m.dataset.parameter.subs,m.dataset.angle_ids,cell2mat(m.dataset.parameter.ears),:);


% Band Pass
if (m.dataset.parameter.bp_mode == 1)
    bpfilter=compute_filter_bp(m.database.fs);
    %bpfilter=compute_filter_lp(m.database.fs);
    m.dataset.hrirs = filter(bpfilter,m.dataset.hrirs);
    
    % Normalize HRIRs
    m.dataset.hrirs = m.dataset.hrirs/max(max(max(max(m.dataset.hrirs))));
end

m.dataset.mphrirs = minp_db(m.dataset.hrirs);
ffts = fft(m.dataset.hrirs,m.dataset.parameter.fft_size,4);
m.dataset.hrtfs = abs(ffts);
m.dataset.phase = angle(ffts);

% Calculate ITDs 
if length(cell2mat(m.dataset.parameter.ears))>1
    for sub = 1:size(m.dataset.hrirs,1)
        for pos = 1:size(m.dataset.hrirs,2)
            [~,~,~,m.dataset.itd_samples(sub,pos)] = calculate_itd(squeeze(m.dataset.hrirs(sub,pos,1,:)),squeeze(m.dataset.hrirs(sub,pos,2,:)),m.database.fs);
        end
    end
    % Calc Average ITDs
    m.dataset.itd_samples_avg = round(mean(m.dataset.itd_samples,1));
end

% Frequency Smoothing
m = smooth_hrtfs(m);

% Define Spherical Harmonics Coefficient for the Angles in the Model
if strcmp(m.weight_model.parameter.type,'global')
    m.dataset.sha = [];
    for a = 1:length(m.dataset.angle_ids)
        % sha is N x angles matrix containing the spherical expansion
        % up to the 10 th order for the angles included in the dataset
        % dataset.sha(a,:) = SHCreateYVec(10,dataset.database.angles(dataset.angle_ids(a),1),90-dataset.database.angles(dataset.angle_ids(a),2),'deg'); % Convert Elevation to Zenith (Inclination or Colatitude)
        m.dataset.sha(a,:) = sh_matrix_real(m.weight_model.parameter.order_initial,m.dataset.angles(a,1)/180*pi,(90-m.dataset.angles(a,2))/180*pi); % Convert Elevation to Zenith (Inclination or Collatidude)    
    end
end

end