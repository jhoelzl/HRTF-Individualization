function sin_sweep

fs=44100;
t=(1:20000)/fs; 
for f=1:20000
data(f)=sin(2*pi*f*t(f));
end

%  plot(data(1:2000))

fs = 44100;

% Normalize Output Sound
max_val = 1.05*max(max(abs(data)));
out = data/max_val;  

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

