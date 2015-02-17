function [ stim ] = import_sound(listvalue,fs)

% Import Sound Stimuli

switch(listvalue)
    
    case 1
    stim = stimulus(20,180,fs); 
    stim = stim';
        
    case 2
    stim = wavread('sounds/stimulus/ding.wav'); 
    
    case 3
    stim = wavread('sounds/stimulus/sitar.wav'); 
    
    case 4
    stim = wavread('sounds/stimulus/rimshot.wav'); 
    
    case 5
    stim = wavread('sounds/stimulus/rimsnare.wav'); 
    
    case 6
    stim = wavread('sounds/stimulus/sonar.wav'); 
    
    case 7
    stim = stimulus2(20,450,fs);
    
    case 8
    stim = wavread('sounds/stimulus/test1.wav'); 
        
end

end