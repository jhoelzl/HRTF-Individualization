function [ positions ] = positions_extend(ANGLES,azimuth,elevation,az_extend, el_extend )

% Ouput: indizes of positions in MATRIX ANGLES

% Extend Azimuth
% check if azimuth values are from 0-360 or +-180: depends on hrtf database
if (min(ANGLES(:,1)) < 0)
    
    az_ind = find(ANGLES(:,2) == elevation & ANGLES(:,1) >= azimuth-az_extend & ANGLES(:,1) <= azimuth+az_extend);

else
    
    %mod(azimuth+az_extend,360)
    %mod(azimuth-az_extend,360)
    
    % both positive
    if (mod(azimuth+az_extend,360) > mod(azimuth-az_extend,360) > 0)
        
       % disp('both pos')
         az_ind = find(ANGLES(:,2) == elevation & ANGLES(:,1) >= azimuth-az_extend & ANGLES(:,1) <= mod(azimuth+az_extend,360));
 
    end
    
    % neg and pos 
     if (mod(azimuth+az_extend,360) < mod(azimuth-az_extend,360) > 0)
        
        %disp('neg and pos')
        az_ind = find(ANGLES(:,2) == elevation & ANGLES(:,1) >= mod(azimuth-az_extend+360,360) | ANGLES(:,2) == elevation & ANGLES(:,1) <= mod(azimuth+az_extend+360,360) );
     end      
        
     % 0 
     if (mod(azimuth+az_extend,360) == mod(azimuth-az_extend,360) > 0) && (az_extend == 0)
         az_ind = find(ANGLES(:,2) == elevation & ANGLES(:,1) == azimuth);
     end
     
     % 180
     if (mod(azimuth+az_extend,360) == mod(azimuth-az_extend,360) > 0) && (az_extend == 180)
         az_ind = find(ANGLES(:,2) == elevation);
     end
     
     
end

% Extend Elevation
el_ind2 = 0;
for i=1:length(az_ind)
el_ind = find(ANGLES(:,1) == ANGLES(az_ind(i),1) & ANGLES(:,2) >= elevation-el_extend & ANGLES(:,2) <= elevation+el_extend);
el_ind2 = [el_ind2;el_ind];
end

% Combine al positions
positions = unique([az_ind;el_ind2(2:end)]);

end

