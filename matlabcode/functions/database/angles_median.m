function [angles_ind,angles_values] = angles_median(angles)

% Usage:
% hrirs = hrirs(:,angles_median(angles),:,:);


%s[angles,I] = sortrows(angles,[1 2]);
%hrirs = hrirs(:,I,:,:);


% include whole median plane from -50 to +200
% adjust values in the rear section:
% az: 180, el:xxx goes to az:0 and adjusted elevation value

angles_ind1 = find(angles(:,1) == 0);
angles_ind2 = find(angles(:,1) == 180);

angles_ind = [angles_ind1;angles_ind2];

angles_values1 = angles(angles_ind1,2);
angles_values2 = angles(angles_ind2,2);

for g=1:length(angles_values2)
        
    if (angles_values2(g) < 0)
        angles_values2(g) = 180 + abs(angles_values2(g));
    end
    
    if (angles_values2(g) == 0)
        angles_values2(g) = 180;
    end
    
    if (angles_values2(g) > 0) && (angles_values2(g) < 90);
        angles_values2(g) = 90+ abs(angles_values2(g) - 90);
    end

end

% angles_values should go from -50 to +200
% Sort angles_ind according to angles_values
angles_values3 = [angles_values1;angles_values2];
[angles_values,idx] = sort(angles_values3);
angles_ind = angles_ind(idx);

end

