function play_sound(hrir_reconstr_left,hrir_reconstr_right,current_positions,fs,stim,rir,eq_id,silence,play_simul)

% Play reconstructed Sound Samples

for i=1:length(current_positions)     
    
    % Convolute stimulus with HRIR
    out_left = filter(hrir_reconstr_left(i,:),1,stim);
    out_right = filter(hrir_reconstr_right(i,:),1,stim);

    % RIR
    [out_left,out_right] = conv_rir(out_left,out_right,rir);

    % Headphone Equalization
    [out_left,out_right] = conv_hptf(out_left,out_right,eq_id);

    % Add Silence after Sound Impulse
    silence_add = round(fs*silence);

    out_l{i} = [out_left' zeros(1,silence_add)];
    out_r{i} = [out_right' zeros(1,silence_add)];

end

if (play_simul == 0) % Play seperately
    
    out_all_left = [];
    out_all_right = [];
    
    for i=1:length(current_positions)
        out_all_left = [out_all_left out_l{i}];
        out_all_right = [out_all_right out_r{i}]; 
    end
    

else % Play simultaneously
    
    out_all_left = zeros(1,size(out_l{1},2));
    out_all_right = zeros(1,size(out_r{1},2));

    for i=1:length(current_positions)
        out_all_left = out_all_left + out_l{i};
        out_all_right = out_all_right + out_r{i};
    end
    
end

out_all(:,1) = out_all_left;
out_all(:,2) = out_all_right;

% Normalize Output Sound
max_val = 1.05*max(max(abs(out_all)));
out_all = out_all/max_val;    

play_system(out_all,fs)

end

