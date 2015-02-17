function [matrix_inv,ev_total,ev_max] = reg_matrix(matrix)

% Apply Regularization on the matrix and calculate inverse

    max_cond = 5;

    cond_number = cond(matrix);
    [U,s,V] = csvd(matrix);

    % Use all eigenvalues that fullfill condition number less than $max_cond
    ev_total = length(s);
    ev_max = ev_total;
    if (cond_number > max_cond)
        conds = s(1)./s;
        ev_max= max(find(conds < max_cond));        
        disp(sprintf('Reg applied: %i of %i EV',ev_max,length(s)))
    end
    
    matrix_inv = V(:,1:ev_max)* inv(diag(s(1:ev_max))) * U(:,1:ev_max)';
    
    
    
    %matrix = U(:,1:ev_max) * diag(s(1:ev_max)) * V(:,1:ev_max)';
    %[x_k,rho,eta] = tsvd(U,s,V,ones(size(matrix,1),1),[1:ev_max]);

    
    %alpha = 100;
    %(matrix+ (max(s)*eye(size(matrix)) ) / 100);
end