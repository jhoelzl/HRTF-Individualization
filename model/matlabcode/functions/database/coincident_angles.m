function [coincide_angles,db_ind,hrir_length] = coincident_angles(dbs)

% Get angles that coincide in all HRTF databases

% INPUT
% at least db1 and db2, or more strings

% OUTPUT
% coincide_angles (azimuth and elevation matrix) of source positions
% db_ind: cell array of index positions in original HRTF database

for db=1:length(dbs)
[~,~,~,angles{db},~,hrir_length{db}] = db_import(dbs{db},2);
end

for db=1:length(dbs)
db_ind{db} = [];
end

s = 0;
for pos=1:size(angles{1},1)
    
    c=0;
    value_angle{1} = pos;
    for db=2:length(dbs)
    
        ang_base = angles{1};
        ang_test = angles{db};
        
        value_angle{db} = find(ang_test(:,2) == ang_base(pos,2) & ang_test(:,1) == ang_base(pos,1));
        
        if (isempty(value_angle{db}) == true)
        c=1;    
        end
        
    end
    
    % Pos found in all dbs
    if (c == 0)
        s = s+1;
        
        coincide_angles(s,1) = ang_base(pos,1);  
        coincide_angles(s,2) = ang_base(pos,2);  
        
        % store index value        
        for db=1:length(dbs)     
        db_ind1 = db_ind{db};
        db_ind1(length(db_ind1)+1) = value_angle{db};
        db_ind{db} = db_ind1;
        end
        
    end 
end

% sort according elevation positions
[coincide_angles,I] = sortrows(coincide_angles,[2 1]);

for db=1:length(dbs)
    ind_angl = db_ind{db};
    db_ind{db} = ind_angl(I);
end
end