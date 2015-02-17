function [ hrirs ] = bandp_kaiser( hrirs, F,fs)

A = [0 1 0];                % band type: 0='stop', 1='pass'
dev = [0.0001 10^(0.1/20)-1 0.0001]; % ripple/attenuation spec
[M,Wn,beta,typ] = kaiserord(F,A,dev,fs);  % window parameters
b = fir1(M,Wn,typ,kaiser(M+1,beta),'noscale'); % filter design

%freqz(b)
%figure(22);freqz(squeeze(hrirs(1,1,1,:)));

for s=1:size(hrirs,1)
   for p=1:size(hrirs,2)
      for e = 1:size(hrirs,3)
       hrirs(s,p,e,:) = filter(b,1,squeeze(hrirs(s,p,e,:)));
      end
   end
    
end

%figure(23);freqz(squeeze(hrirs(1,1,1,:)));

end

