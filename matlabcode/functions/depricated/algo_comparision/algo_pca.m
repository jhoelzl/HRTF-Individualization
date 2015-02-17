function [pcws,pcs,latent] = algo_pca(parameter,input_matrix,algo_before)

disp(sprintf('PCA of %s [%i x %i]',algo_before,size(input_matrix,1),size(input_matrix,2)))

% PCA
if (~isempty(parameter))
    if (~isempty(parameter{1}))
    [pcs,pcws,latent] = princomp(input_matrix,parameter{1});
    else
    [pcs,pcws,latent] = princomp(input_matrix);    
    end
else
    [pcs,pcws,latent] = princomp(input_matrix);
end

disp(sprintf('Finished: PCs [%i x %i] and PCWs [%i x %i]',size(pcs,1),size(pcs,2),size(pcws,1),size(pcws,2)))
end