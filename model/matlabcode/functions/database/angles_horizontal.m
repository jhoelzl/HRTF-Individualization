function [angles_ind_out,angles_sort] = angles_horizontal(m)

% Usage: %hrirs = hrirs(:,angles_horizontal(angles),:,:);

% Only Angles in horizontal plane
angles_ind1 = find(m.dataset.angles(:,2) == 0);
angles_ind2 = find(m.dataset.angles(:,2) == 180);

% Angle values from 0 to 360
angles1 = m.dataset.angles(angles_ind1,1);
angles2 = m.dataset.angles(angles_ind2,1);

% Modify CIPIC
if (strcmp(m.database.name,'cipic') == 1)
    
    idx1 = find(angles1<0);
    idx2 = find(angles1>0);
    
    idx11 = find(angles2<0);
    idx22 = find(angles2>0);
    idx33 = find(angles2==0);
    
    % front
    angles1(idx1) = -angles1(idx1);
    angles1(idx2) = -angles1(idx2) + 360;
   
    % back
    angles2(idx11) = angles2(idx11) +180;
    angles2(idx22) = angles2(idx22) +180;
    angles2(idx33) = 180;
end

angles_ind = [angles_ind1;angles_ind2];
angles = [angles1;angles2];
[angles_sort,idx] = sort(angles);

angles_ind_out = angles_ind(idx);
end