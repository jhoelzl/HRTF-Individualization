function [sh_recon] = algo_sh_inv(parameter,weights,sha,algo_before,algo_after,dimensions)

disp(sprintf('SH Reconstruction of %s',algo_before))

for sub = 1:size(weights,1)
    sh_recon(sub,:,:) = sha*squeeze(weights(sub,:,:));
    % sh_recon(sub,:,:) = inv(sha*sha')*sha*squeeze(weights(sub,:,:))
end

% Reshape
sh_recon = squeeze(reshape(sh_recon,[size(sh_recon,1)*size(sh_recon,2),size(sh_recon,3)]));

disp(sprintf('Finished: Matrix [%i x %i]',size(sh_recon,1),size(sh_recon,2)))
end