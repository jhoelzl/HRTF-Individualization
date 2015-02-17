function [hrtfs,hrir_min] = minimum_phase_hrirs(m)

% Calculate Minimum-Phase HRIRs from modelled HRTFs

hrir_min = zeros(size(m.set.hrtfs,1),size(m.set.hrtfs,2),size(m.set.hrtfs,3),size(m.dataset.hrtfs,4));  
hrtfs = zeros(size(m.set.hrtfs,1),size(m.set.hrtfs,2),size(m.set.hrtfs,3),size(m.dataset.hrtfs,4));
h = zeros(1,size(m.set.hrtfs,4));
for i1 = 1:size(hrir_min,1)
    for i2 = 1:size(hrir_min,2)
        for i3 = 1:size(hrir_min,3)
            h(1:size(m.set.hrtfs,4)) = m.set.hrtfs(i1,i2,i3,:);            
            h(size(m.dataset.hrtfs,4)/2+(2:size(m.dataset.hrtfs,4)/2)) = conj(m.set.hrtfs(i1,i2,i3,size(m.dataset.hrtfs,4)/2:-1:2));
            hrtfs(i1,i2,i3,:) = h;
            [~,htemp] = rceps(real(ifft(h)));            
            hrir_min(i1,i2,i3,:) = htemp;
        end
    end
end
end