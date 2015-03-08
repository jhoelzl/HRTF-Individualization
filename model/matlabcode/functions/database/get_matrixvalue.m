function [ value ] = get_matrixvalue(azimuth_real,elevation_real,ANGLES)

if (isempty(ANGLES))
    disp('Matrix ANGLES is empty!')
end

% get row value in HRIR Matrix for a source position 

value_angle = find(ANGLES(:,2) == elevation_real & ANGLES(:,1) == azimuth_real);

if (value_angle ~= 0)
value = value_angle;
else
disp('ERROR - No data found for this angle')    
end


end