function [weights,basis] = algo_nnmf( parameter,input_matrix,algo_before,algo_after,dimensions)

factors = str2num(parameter{1});
disp(sprintf('NNMF with %i factors of %s [%i x %i]',factors,algo_before,size(input_matrix,1),size(input_matrix,2)))

% NNMF
[weights,basis] = nnmf(input_matrix,factors);

disp(sprintf('Finished: W [%i x %i] and H [%i x %i]',size(weights,1),size(weights,2),size(basis,1),size(basis,2)))

end