function play_pca3(hrir_reconstr_left,hrir_reconstr_right,fs,stim,eq_id)

    % play selected position    
    play_sound([hrir_reconstr_left hrir_reconstr_right],fs,stim,eq_id);

end