function play_generalized(play_pos,count_positions,avg_hrir_left,avg_hrir_right,fs)

if (count_positions+1 == play_pos)
    
    % Play all
    for pos=1:size(avg_hrir_left,2)
    play_sound([avg_hrir_left(:,pos)'; avg_hrir_right(:,pos)'],fs);
    pause(0.03)
    end
    
else
    
    % Play selected postion
    play_sound([avg_hrir_left(:,play_pos)'; avg_hrir_right(:,play_pos)'],fs);    

end


end

