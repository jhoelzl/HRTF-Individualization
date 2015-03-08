function [ value_angle ] = get_trajectory(ANGLES,source,type,mode)

% Input
% ANGLES matrix
% source        trajetory position
% type          1=azimuth, 2=elevation
% mode          0= only select trajetories automatically from matrix angles
%               1 = whole median plane

if (type ==1)
    type2 =2;
else
    type2 =1;
end

if (mode == 0)   
    
    indizes = find(ANGLES(:,type) == source);

    % sort angles
    for s=1:length(indizes)
        values(s) = ANGLES(indizes(s),type2);
    end

    sorted_values = sort(values);

    for i=1:length(sorted_values)
        value_angle(i) = find(ANGLES(:,type2) == sorted_values(i) & ANGLES(:,type) == source);
    end


else
    % whole median plane
    
    value_angle = angles_median(ANGLES)';


end

end