function pca_matrix = reshape_model(data,structure,ear_mode)

% Reshape 4.dimensional Data-Matrix to PCA Input Matrix structures INP1 to INP5

switch (structure)

    case 1 % INP1: [(subjects) x (signal x positions, i.e P1 F1-512 ... Pn F1-512)]
        if ear_mode == 1 % Ears in Rows Blocked
            pca_matrix = permute(data,[4,2,1,3]);
            pca_matrix = reshape(pca_matrix,[],size(data,1)*size(data,3))'; % Rows refilled starting from the last dimension
        else % Ears in Columns
            pca_matrix = permute(data,[1,4,2,3]);
            pca_matrix = reshape(pca_matrix,size(data,1),[]); 
        end

    case 2 % INP2: [(subject x positions) x (signal)]
        if ear_mode == 1 % Ears in Rows Blocked
            pca_matrix = reshape(data,[],size(data,4));
        else % Ears in Columns 
            pca_matrix = permute(data,[1,2,4,3]);     
            pca_matrix = reshape(pca_matrix,[],size(data,4)*size(data,3));
        end
                
    case 3 % INP3: [(signal) x (subjects x positions, i.e. P1 S1-SN ... Pn S1-Sn)]
        if ear_mode == 1 % Ears in Rows Blocked
            pca_matrix = permute(data,[1,2,4,3]);
            pca_matrix = reshape(pca_matrix,[],size(data,4)*size(data,3))';
        else % Ears in Columns 
            pca_matrix = permute(data,[4,2,1,3]);
            pca_matrix = reshape(pca_matrix,size(data,4),[]);  
        end
        
        
    case 4 % INP4: (signal x positions i.e. P1 F1-F512 ... Pn F1-F512) x (subjects)]
        if ear_mode == 1 % Ears in Rows Blocked
            pca_matrix = permute(data,[4,2,3,1]);
            pca_matrix = reshape(pca_matrix,[],size(data,1));
        else % Ears in Columns 
            pca_matrix = permute(data,[4,2,1,3]);
            pca_matrix = reshape(pca_matrix,size(data,2)*size(data,4),[]);  
        end
        
    case 5 % INP5: [(subjects x signal) x (positions)]
        if ear_mode == 1 % Ears in Rows Blocked
            pca_matrix = permute(data,[4,1,3,2]);
            pca_matrix = reshape(pca_matrix,[],size(data,2));
        else % Ears in Columns 
            pca_matrix = permute(data,[4,1,3,2]);
            pca_matrix = reshape(pca_matrix,size(data,1)*size(data,4),[]);  
        end   
end   

end