function [out1,out2] = perform_algo(test_parameter)

ind_pca = 0;
ind_sh = 0;
ind_ica = 0;
ind_nnmf = 0;



for i=1:length(test_parameter)
    
    % NAME
    algo = regexp(test_parameter{i}, '[', 'split');
    algo_name{i} = algo{1};
    
    % next step algo
    if (length(test_parameter) > i)
    algo_next = regexp(test_parameter{i+1}, '[', 'split');
    algo_name{i+1} = algo_next{1};
    else
    algo_name{i+1} = 'end';    
    end
    
    % PARAMETER
    if (length(algo) >1)
        algo_parameter = algo{2};
        algo_parameter = strrep(algo_parameter,']','');
        algo_parameter = regexp(algo_parameter, ',', 'split');
        
    else
        algo_parameter = '';
    end
    
    disp(sprintf('\n%i. PROCESS:',i))
    
    % PERFORM PROCESS
    if (strcmp(algo_name{i},'db_load'))
        [out1{i},dimensions] = algo_db_load(algo_parameter);
    end
    
    if (strcmp(algo_name{i},'input_matrix'))
        [out1{i},mean_matrix,dimensions] = algo_input_matrix(out1{i-1},algo_parameter,dimensions);
    end
    
    if (strcmp(algo_name{i},'pca'))
        ind_pca = ind_pca+1;
        [out1{i},pc{ind_pca},out3{i}] = algo_pca(algo_parameter,out1{i-1},algo_name{i-1});
        out2{i} = pc{ind_pca};
    end
    
    if (strcmp(algo_name{i},'pca_inv'))
        [out1{i}] = algo_pca_inv(algo_parameter,out1{i-1},pc{ind_pca},algo_name{i-1},algo_name{i+1},dimensions);
        ind_pca = ind_pca-1;
    end
    
    if (strcmp(algo_name{i},'ica'))
        ind_ica = ind_ica+1;
        [out1{i},basis_ica{ind_ica}] = algo_ica(algo_parameter,out1{i-1},algo_name{i-1},algo_name{i+1},dimensions);
    end
    
    if (strcmp(algo_name{i},'ica_inv'))
        [out1{i}] = algo_ica_inv(algo_parameter,out1{i-1},basis_ica{ind_ica},algo_name{i-1},algo_name{i+1},dimensions);
        ind_ica = ind_ica-1;
    end
    
    if (strcmp(algo_name{i},'nnmf'))
        ind_nnmf = ind_nnmf+1;
        [out1{i},basis_nnmf{ind_nnmf}] = algo_nnmf(algo_parameter,out1{i-1},algo_name{i-1},algo_name{i+1},dimensions);
    end
    
    if (strcmp(algo_name{i},'nnmf_inv'))
        [out1{i}] = algo_nnmf_inv(algo_parameter,out1{i-1},basis_nnmf{ind_nnmf},algo_name{i-1},algo_name{i+1},dimensions);
        ind_nnmf = ind_nnmf-1;
    end
    
    
    if (strcmp(algo_name{i},'sh'))
        ind_sh = ind_sh+1;
        [out1{i},sha{ind_sh}] = algo_sh(algo_parameter,out1{i-1},algo_name{i-1},algo_name{i+1},dimensions);
    end
    
    if (strcmp(algo_name{i},'sh_inv'))
        [out1{i}] = algo_sh_inv(algo_parameter,out1{i-1},sha{ind_sh},algo_name{i-1},algo_name{i+1},dimensions);
        ind_sh = ind_sh-1;
    end
    
    % Perform Comparision Calulcation
    if (strcmp(algo_name{i},'compare'))
        algo_compare(dimensions,algo_inv_reshape(out1{2},size(mean_matrix),dimensions)+mean_matrix,out1{i-1});
    end
    
    %disp(sprintf('Next: %s',algo_name{i+1}))
    
end

out1 = out1{i};
out2 = out2{i};

end

