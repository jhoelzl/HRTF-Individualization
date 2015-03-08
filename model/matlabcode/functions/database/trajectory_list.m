function [source_values,ind_daten] = trajectory_list(current_db,ANGLES)

az_unique = unique(ANGLES(:,1));
el_unique = unique(ANGLES(:,2));

% set miminum source positions for a trajectory
minimim_positions = 2;
c=0;
source_values = '';

% Trajectories in Elevation Plane
for i = 1:length(az_unique)
    
    indizes = find(ANGLES(:,1) == az_unique(i));
    
    if (length(indizes) > minimim_positions)
        
        
        % sort elevation angles
        el_values_ind = [];
        el_values = [];
        
        for s=1:length(indizes)
            el_values(s) = ANGLES(indizes(s),2);
        end
        
        [~, el_values_ind] = sort(el_values);
        
        c=c+1;
        ind_daten{c} = indizes(el_values_ind);
        
        
        % different number formats for better reading
        switch(current_db)
            
            case 'ari'
            source_values = sprintf('%sAZ: %2.1f / EL: ',source_values,az_unique(i));
             
            otherwise
            source_values = sprintf('%sAZ: %i / EL: ',source_values,az_unique(i));

                
        
        end

        for u=1:length(indizes)

            switch(current_db)
               
                case 'cipic' 
                source_values = sprintf('%s%2.1f,',source_values,ANGLES(indizes(el_values_ind(u)),2));
          
                otherwise
                source_values = sprintf('%s%i,',source_values,ANGLES(indizes(el_values_ind(u)),2));

                
            end
        end
        source_values=source_values(1:(end-1));
        source_values = sprintf('%s|',source_values);
    end
    
    
end


% Trajectories in Azimuth Plane
for i = 1:length(el_unique)
    
    indizes = find(ANGLES(:,2) == el_unique(i));
    if (length(indizes) > minimim_positions)       
       
         % sort azimnuth angles
        az_values_ind = [];
        az_values = [];
        
        for s=1:length(indizes)
            az_values(s) = ANGLES(indizes(s),1);
        end
        
        [~, az_values_ind] = sort(az_values);
        
        c=c+1;
        ind_daten{c} = indizes(az_values_ind);
        
        
    % different number formats for better reading
    switch(current_db)
        
        
       case 'cipic'
         source_values = sprintf('%sEL: %2.1f / AZ: ',source_values,el_unique(i));
      
            
        case 'ari'
        source_values = sprintf('%sEL: %2.1f / AZ: ',source_values,el_unique(i));

        otherwise
         source_values = sprintf('%sEL: %i / AZ: ',source_values,el_unique(i));
       
    end
    
    
    
    for u=1:length(indizes)
        
        switch(current_db)
           
            case 'ari' 
            source_values = sprintf('%s%2.1f,',source_values,ANGLES(indizes(az_values_ind(u)),1));
        
            otherwise
            source_values = sprintf('%s%i,',source_values,ANGLES(indizes(az_values_ind(u)),1));

        end
    end
    source_values=source_values(1:(end-1));
    source_values = sprintf('%s|',source_values);
    end
end


% Add whole median plane (from front to back)
angles_ind_median = angles_median(ANGLES);


c=c+1;
ind_daten{c} = angles_ind_median;
        
        
 switch(current_db)
      
     case 'ari'
            source_values = sprintf('%sAZ: %2.1f / EL: ',source_values,0);
            
     otherwise
            source_values = sprintf('%sAZ: %i / EL: ',source_values,0);

 end
        

for pos=1:length(angles_ind_median)
    switch(current_db)
       
        case 'cipic'
        source_values = sprintf('%s%2.1f,',source_values,ANGLES(angles_ind_median(pos),2));
        
        otherwise
        source_values = sprintf('%s%i,',source_values,ANGLES(angles_ind_median(pos),2));

    end          
end


% Add single positions

[ANGLES,I] = sortrows(ANGLES,[1 2]);

   for pos=1:size(ANGLES,1)
        
        c=c+1;
        ind_daten{c} = I(pos);
        
       
        
        switch(current_db)        
        case 'cipic' 
        source_values = sprintf('%s|Az: %i / El: %2.3f',source_values,ANGLES(pos,1),ANGLES(pos,2));
        
        case 'ari'
        source_values = sprintf('%s|Az: %2.1f / El: %i',source_values,ANGLES(pos,1),ANGLES(pos,2));
        
        otherwise
        source_values = sprintf('%s|Az: %i / El: %i',source_values,ANGLES(pos,1),ANGLES(pos,2));
        end
        
   end

   
% delete last symbol |
%source_values=source_values(1:(end-1));
end

