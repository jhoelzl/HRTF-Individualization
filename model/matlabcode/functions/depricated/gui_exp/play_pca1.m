function play_pca1(hrir_reconstr_left,hrir_reconstr_right,play_pos,current_positions,fs,stim,eq_id)


if(length(current_positions)+1 == play_pos)
   
    % play all 
    for pos=1:length(current_positions)
        play_sound([hrir_reconstr_left(:,pos) hrir_reconstr_right(:,pos)],fs,stim,eq_id);
        pause(0.02)
    end

else
    
    % play selected position
    play_sound([hrir_reconstr_left(:,play_pos) hrir_reconstr_right(:,play_pos)],fs,stim,eq_id);

end


end

