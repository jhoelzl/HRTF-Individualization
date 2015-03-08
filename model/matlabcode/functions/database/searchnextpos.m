function [pos_ind,answ] = searchnextpos(angles,az,el,az_unique,el_unique)

for el=1:length(el_unique)
    for az=1:length(az_unique)
    Y(az,el) = 0; 

    answ = 0;
    offset = 0;
        while true 

            [pos_ind,answ] = searchnextpos_loop(angles,az,el,az_unique,el_unique,offset);
            if (answ == 1)
            break
            end
            offset = offset +2.5;
        end  

    end
end   
      
end


function [pos_ind,answ] = searchnextpos_loop(angles,az,el,az_unique,el_unique,offset)

pos_ind = find(angles(:,2) == el_unique(el) & (angles(:,1) >= az_unique(az)-offset)  &  (angles(:,1) <= az_unique(az)+offset) );


if (isempty(pos_ind)) 
   answ = 0;
else
   answ = 1;
end



end