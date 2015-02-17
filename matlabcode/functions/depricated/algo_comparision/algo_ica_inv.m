function [input_matrix_recon] = algo_ica_inv(parameter,weights,basis,algo_before,algo_after,dimensions)

disp(sprintf('ICA Reconstruction of %s',algo_before))

input_matrix_recon = weights * basis;

disp(sprintf('Finished: Matrix [%i x %i]',size(input_matrix_recon,1),size(input_matrix_recon,2)))
end