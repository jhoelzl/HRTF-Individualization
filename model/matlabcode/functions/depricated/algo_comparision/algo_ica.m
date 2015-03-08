function [weights,basis] = algo_ica(parameter,input_matrix,algo_before,algo_after,dimensions)

numofic = str2num(parameter{1});
lasteig = str2num(parameter{2});
verbose = parameter{3};

disp(sprintf('ICA with %i ICs of %s [%i x %i]',numofic,algo_before,size(input_matrix,1),size(input_matrix,2)))
% 'lastEig', lasteig
[basis,weights,sep] = fastica(input_matrix(:,1:lasteig), 'numOfIC', numofic,'verbose',verbose);

disp(sprintf('Finished: Basis [%i x %i] and Weights [%i x %i]',size(basis,1),size(basis,2),size(weights,1),size(weights,2)))

end