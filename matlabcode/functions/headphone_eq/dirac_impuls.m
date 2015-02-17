function dirac_impuls

out = 1;
fs = 44100;

% Normalize Output Sound
max_val = 1.05*max(max(abs(out)));
out = out/max_val;  

switch computer
   
% Windows    
case 'PCWIN'
    wavplay(out,fs);
   
% Other platforms
case {'LNX86','GLNX86','MACI','MACI64'}                            
    sound(out,fs);

otherwise
    disp('Error Sound Output - Please specify your Operating System!')    
end


end

