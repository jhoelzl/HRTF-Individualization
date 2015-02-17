function out = ireshape_model(in,structure,sz,ear_mode)

% Reshape  Input Matrix to structures INP1 to INP5

switch(structure)

    case 1 % INP1
        if ear_mode == 1
            out = permute(reshape(in,[sz(1) sz(3) sz(4) sz(2)]),[1 4 2 3]);        
        end
        if ear_mode == 2
            out = permute(reshape(in,[sz(1) sz(4) sz(2) sz(3)]),[1 3 4 2]);        
        end
    case 2 % INP2    
        if ear_mode == 1                       
            % out = permute(reshape(in',[sz(1) sz(2) sz(3) sz(4)]),[1 2 4 3]);
            out = reshape(in,[sz(1) sz(2) sz(3) sz(4)]);
        end
        if ear_mode == 2
            out = permute(reshape(in,[sz(1) sz(2) sz(4) sz(3)]),[1 2 4 3]);        
        end        
    case 3 % INP3
        if ear_mode == 1            
            % out = permute(reshape(in,[sz(4) sz(3) sz(1) sz(2)]),[3 4 2 1]);
            out = permute(reshape(in,[sz(4) sz(3) sz(1) sz(2)]),[3 4 2 1]);
        end
        if ear_mode == 2
            out = permute(reshape(in,[sz(4) sz(2) sz(1) sz(3)]),[3 2 4 1]);        
        end        
    case 4 % INP4
        if ear_mode == 1            
            out = permute(reshape(in,[sz(4) sz(2) sz(3) sz(1)]),[4 2 3 1]);
        end
        if ear_mode == 2
            out = permute(reshape(in,[sz(4) sz(2) sz(1) sz(3)]),[3 2 4 1]);        
        end
        
    case 5 % INP5
        if ear_mode == 1            
            out = permute(reshape(in,[sz(4) sz(1) sz(3) sz(2)]),[2 4 3 1]);
        end 
        if ear_mode == 2
            out = permute(reshape(in,[sz(4) sz(1) sz(3) sz(2)]),[2 4 3 1]);        
        end   
end   

end