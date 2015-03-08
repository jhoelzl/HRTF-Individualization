function [ hrirs,angles_ind ] = angles_horizontal( hrirs,angles )

[angles,I] = sortrows(angles,[1 2]);
hrirs = hrirs(:,I,:,:);

% Only Angles in horizontal plane
angles_ind = find(angles(:,2) == 0);
angles_values = angles(angles_ind,1);


hrirs = hrirs(:,angles_ind,:,:);

end