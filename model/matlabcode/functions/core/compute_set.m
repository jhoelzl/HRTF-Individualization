function m = compute_set(m,model_data)

% Compute Resulting HRIR Set from reconstructed PCA Matrix

switch m.model.parameter.input_mode
    case 1 % HRIRs
        sz = size(m.dataset.hrirs);
        sz(1) = length(m.set.subjects);
        sz(2) = length(m.set.angle_ids);       
        m.set.hrirs = ireshape_model(squeeze(model_data),m.model.parameter.structure,sz,m.model.parameter.ear_mode);
        m.set.hrtfs = abs(fft(m.set.hrirs,[],4));
        m.set.mphrirs = minp_db(m.set.hrirs);
    case 2 % Min-phase HRIRs
        sz = size(m.dataset.hrirs);
        sz(1) = length(m.set.subjects);
        sz(2) = length(m.set.angle_ids);      
        m.set.mphrirs = ireshape_model(squeeze(model_data),m.model.parameter.structure,sz,m.model.parameter.ear_mode);
        m.set.hrtfs = abs(fft(m.set.mphrirs,[],4));
        if (cell2mat(m.dataset.parameter.ears) == [1,2])
            m.set.hrirs = itd_alignment(m);
        end
    case 3 % lin DTF
        sz = size(m.dataset.hrtfs);
        sz(1) = length(m.set.subjects);
        sz(2) = length(m.set.angle_ids);
        sz(4) = sz(4)/2 + 1;        
        m.set.hrtfs = ireshape_model(squeeze(model_data),m.model.parameter.structure,sz,m.model.parameter.ear_mode);
        [m.set.hrtfs,m.set.mphrirs] = minimum_phase_hrirs(m);
        if (cell2mat(m.dataset.parameter.ears) == [1,2])
            m.set.hrirs = itd_alignment(m);
        end
    case 4 % log DTF
        sz = size(m.dataset.hrtfs);
        sz(1) = length(m.set.subjects);
        sz(2) = length(m.set.angle_ids);
        sz(4) = sz(4)/2 + 1;
        
        m.set.hrtfs = ireshape_model(10.^(squeeze(model_data)/20),m.model.parameter.structure,sz,m.model.parameter.ear_mode);
        [m.set.hrtfs,m.set.mphrirs] = minimum_phase_hrirs(m);
        if (cell2mat(m.dataset.parameter.ears) == [1,2])
            m.set.hrirs = itd_alignment(m);
        end
end
end