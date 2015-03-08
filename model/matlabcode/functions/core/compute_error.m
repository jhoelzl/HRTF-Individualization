function error = compute_error(m) 

% Compute Reconstruction Error in Frequency and Time Domain

% m.dataset. = original data
% model. = reconstructed data

% Spectral Distortion (SD)
% Signal Distortion Ratio (SDR): 10*log10 must be added after mean on analysis

switch m.model.parameter.input_mode
    case 1   
        error.sd = sqrt(mean(abs(20*log10(m.set.hrtfs./m.dataset.hrtfs(:,m.set.angle_ids,:,:))).^2,4));
        error.sd_bin = squeeze(sqrt(abs(20*log10(m.set.hrtfs./m.dataset.hrtfs(:,m.set.angle_ids,:,:))).^2));
        error.sdr = squeeze(sum(m.dataset.mphrirs(:,m.set.angle_ids,:,:).^2,4)./sum((m.dataset.mphrirs(:,m.set.angle_ids,:,:) - m.set.mphrirs).^2,4));
    case 2
        error.sd = sqrt(mean(abs(20*log10(m.set.hrtfs./m.dataset.hrtfs(:,m.set.angle_ids,:,:))).^2,4));
        error.sd_bin = squeeze(sqrt(abs(20*log10(m.set.hrtfs./m.dataset.hrtfs(:,m.set.angle_ids,:,:))).^2));
        error.sdr = squeeze(sum(m.dataset.mphrirs(:,m.set.angle_ids,:,:).^2,4)./sum((m.dataset.mphrirs(:,m.set.angle_ids,:,:) - m.set.mphrirs).^2,4));
    case {3,4}        
        error.sd = squeeze(sqrt(mean(abs(20*log10(m.set.hrtfs./m.dataset.hrtfs(:,m.set.angle_ids,:,:))).^2,4)));
        error.sd_bin = squeeze(sqrt(abs(20*log10(m.set.hrtfs./m.dataset.hrtfs(:,m.set.angle_ids,:,:))).^2)); 
        error.sdr = squeeze(sum(m.dataset.mphrirs(:,m.set.angle_ids,:,:).^2,4)./sum((m.dataset.mphrirs(:,m.set.angle_ids,:,:) - m.set.mphrirs).^2,4));
end

end