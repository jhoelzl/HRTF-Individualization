function [ source_values ] = source_list(current_db,ANGLES)

source_values = '';

    for i=1:size(ANGLES,1)
        
        switch(current_db)
        case {'iem','universal','ircam'}
        source_values = sprintf('%s%i / %i|',source_values,ANGLES(i,1),ANGLES(i,2));
        
        case 'cipic' 
        source_values = sprintf('%s%i / %2.3f|',source_values,ANGLES(i,1),ANGLES(i,2));
        
        case 'ari'
        source_values = sprintf('%s%2.1f / %i|',source_values,ANGLES(i,1),ANGLES(i,2));
        end
        
    end

end