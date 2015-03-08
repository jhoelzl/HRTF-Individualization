function [equal_pos,db1_ind,db2_ind] = equal_pos()


[angles1, ari1, ircam1] = coincident_angles('ari','ircam');
[angles2, ari2, cipic2] = coincident_angles('ari','cipic');
%[angles3, kemar3, cipic] = coincident_angles('kemar','cipic');
    
% Search for collective source positions
s = 0;
for pos=1:size(angles1,1)
    
     value_angle1 = find(angles2(:,2) == angles1(pos,2) & angles2(:,1) == angles1(pos,1));
     %value_angle2 = find(angles3(:,2) == angles1(pos,2) & angles3(:,1) == angles1(pos,1));
   
    
     if (isempty(value_angle1) == false)% && (isempty(value_angle2) == false)
        s = s+1;
        
        equal_pos(s,1) = angles1(pos,1);  
        equal_pos(s,2) = angles1(pos,2);  
        
        db1_ind(s) = pos;
        db2_ind(s) = value_angle1;
        %cipic_ind(s) = value_angle2;
        
     end 
    
    
end



end

