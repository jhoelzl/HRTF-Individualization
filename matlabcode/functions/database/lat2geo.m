function [angles] = lat2geo(angles)
% Adjust Azimuth and Elevation Angles position Matrix angles
% Elevation should have values from -90 to +90 degrees
% Azimuth should have values from 0-359 degrees (counterclockwise!)
   
    % Correct Azimuth values
%     clc
%     disp('ORIG SET')
%     unique(angles(:,1))
%     size(unique(angles(:,1)))
%     
%     unique(angles(:,2))
%     size(unique(angles(:,2)))
    
    for pos=1:size(angles,1)
        
        if(angles(pos,2) <= 90)
            
            if (angles(pos,1) > 0)    
            angles(pos,1) = 360- angles(pos,1);   %az
            end

            if (angles(pos,1) < 0)
            angles(pos,1) = abs(angles(pos,1));  %az 
            end
        end
        
        
        if(angles(pos,2) > 90) 
            angles(pos,2) = 180 - angles(pos,2); % el
            
            if (angles(pos,1) > 0)   
            angles(pos,1) =     180 + abs(angles(pos,1));
            end
            
            
            if (angles(pos,1) < 0)
            angles(pos,1) =     180 - abs(angles(pos,1));
            end
            
            if (angles(pos,1) == 0)
            angles(pos,1) =  180;    
            end
            
        end

    end
%     
%     disp('NEW SET')
%     unique(angles(:,1))
%     size(unique(angles(:,1)))
%     
%     unique(angles(:,2))
%     size(unique(angles(:,2)))
end

