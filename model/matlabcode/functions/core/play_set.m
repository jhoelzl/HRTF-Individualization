function play_set(model)

% Play reconstructed Sound Samples of reconstructed HRIR Set

for pos=1:size(model.set.hrirs,2)
    
    % Convolute stimulus with HRIR
    out_left = filter(squeeze(model.set.hrirs(1,pos,1,:)),1,model.sound.stim);
    out_right = filter(squeeze(model.set.hrirs(1,pos,2,:)),1,model.sound.stim);

    % RIR
    [out_left,out_right] = conv_rir(out_left,out_right,model.sound.rir);

    % Headphone Equalization
    [out_left,out_right] = conv_hptf(out_left,out_right,model.sound.eq_id);

    % Add Silence after Sound Impulse
    silence_add = round(model.database.fs*model.sound.silence);

    out_l{pos} = [out_left' zeros(1,silence_add)];
    out_r{pos} = [out_right' zeros(1,silence_add)];

end

if (model.sound.play_mode == 0) % Play seperately
    
    % String together all positions to get an audio stream
    out_all_left = [];
    out_all_right = [];
    
    for i=1:size(model.set.hrirs,2)
        out_all_left = [out_all_left out_l{i}];
        out_all_right = [out_all_right out_r{i}]; 
    end
    

else % Play simultaneously
    
    out_all_left = zeros(1,size(out_l{1},2));
    out_all_right = zeros(1,size(out_r{1},2));

    for i=1:size(model.set.hrirs,2)
        out_all_left = out_all_left + out_l{i};
        out_all_right = out_all_right + out_r{i};
    end
    
end

out_all(:,1) = out_all_left;
out_all(:,2) = out_all_right;

% Normalize Output Sound
max_val = 1.05*max(max(abs(out_all)));
out_all = out_all/max_val;    

play_system(out_all,model.database.fs)

end

