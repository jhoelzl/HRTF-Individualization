function m = adjust_angles(m)

% Obtain angle values from 0 to 360

angles_new = m.database.angles;

% Modify CIPIC: azimuthal values from -80 to 80 should go to 0-360 degrees
if (strcmp(m.database.name,'cipic') == 1)
    
    for pos=1:size(m.database.angles,1)
        
        % Front Side
        if (m.database.angles(pos,2)<= 90)
            
            % Az
            if (m.database.angles(pos,1)< 0)
            angles_new(pos,1) = -m.database.angles(pos,1);
            end
            
            % Az
            if (m.database.angles(pos,1)> 0)
            angles_new(pos,1) = -m.database.angles(pos,1) + 360;
            end
            
        end
        
        % Back Side
        if (m.database.angles(pos,2)> 90)
            
            % Az
            angles_new(pos,1) = m.database.angles(pos,1) +180;
            
            % El
            angles_new(pos,2) = -m.database.angles(pos,2) +180;
            
        end
    end
end

m.database.angles = angles_new;
end