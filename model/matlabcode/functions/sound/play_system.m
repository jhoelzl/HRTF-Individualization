function play_system(out,fs)

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