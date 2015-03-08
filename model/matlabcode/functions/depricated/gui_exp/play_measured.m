function play_measured(current_db,current_positions,DB,fs,solution_subject,play_pos,soundmode,position,stim,eq_id)

% if soundmode = "all positions", play only selected source position
if (soundmode ==3)
play_pos = position;
end

if (strcmp(current_db,'universal') == 0)
    
    
        if (length(current_positions)+1 == play_pos) % play all positions
          
            for i=1:length(current_positions)
            out_left = squeeze(DB(solution_subject,current_positions(i),1,:));
            out_right = squeeze(DB(solution_subject,current_positions(i),2,:)); 
            play_sound([out_left out_right],fs,stim,eq_id);
            pause(0.03)
            
            end
            
        else % play only selected position
            
            out_left = squeeze(DB(solution_subject,current_positions(play_pos),1,:));
            out_right = squeeze(DB(solution_subject,current_positions(play_pos),2,:)); 
            play_sound([out_left out_right],fs,stim,eq_id);
            
        end

else
        
        if (length(current_positions)+1 == play_pos) % play all positions
          
           for i=1:length(current_positions)
               
            [~,~,fs2] = get_matrixvalue_universal(0,0,solution_subject);
            out_left = squeeze(DB(solution_subject,current_positions(i),1,:));
            out_right = squeeze(DB(solution_subject,current_positions(i),2,:)); 
            play_sound([out_left out_right],fs2,stim,eq_id);
            pause(0.03)
        
            end
        
        else % play selected position
            [~,~,fs2] = get_matrixvalue_universal(0,0,solution_subject);            
            out_left = squeeze(DB(solution_subject,current_positions(play_pos),1,:));
            out_right = squeeze(DB(solution_subject,current_positions(play_pos),2,:)); 
            play_sound([out_left out_right],fs2,stim,eq_id);
        end     
end 

end

