function input_matrix_recon = algo_pca_inv(parameter,pcws,pcs,mean_matrix,algo_before,dimensions)

disp(sprintf('PCA Reconstruction of %s',algo_before))

if (~isempty(parameter))
    if (~isempty(parameter{1}))
    pc_number = str2num(parameter{1}); 
    else
    pc_number = size(pcs,2);    
    end
else
   pc_number = size(pcs,2);
end


% PCA Reconstruction
for k = 1:length(pc_number)
    
    if (pc_number(k) > size(pcws,2))
    pc_number(k) = size(pcws,2);
    end
    
    %  W*PC' + mean, reshape to match original data
    input_matrix_recon(k,:,:,:,:) = algo_inv_reshape(pcws(:,1:pc_number(k)) * pcs(:,1:pc_number(k))',size(mean_matrix),dimensions) + mean_matrix;
end


% input_matrix_recon = algo_inv_reshape(input_matrix_recon,size(mean_matrix),dimensions{4},dimensions{6});
% Add Mean
% input_matrix_recon = input_matrix_recon + mean_matrix;

disp(sprintf('Finished: Matrix [%i x %i x %i x %i x%i]',size(input_matrix_recon,1),size(input_matrix_recon,2),size(input_matrix_recon,3),size(input_matrix_recon,4),size(input_matrix_recon,5)))

end