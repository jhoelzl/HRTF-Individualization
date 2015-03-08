function hrirs = itd_alignment(m)

% Align Minimum-Phase HRIRs with ITD to get HRIRs

if (size(m.set.mphrirs,1) == 1)
    % Use averaged ITD across all subjects for the adaption mode
    itd = m.dataset.itd_samples_avg;
else
    % Use individual ITDs
    itd = m.dataset.itd_samples;
end

hrirs = zeros(size(m.set.mphrirs));
for i1 = 1:size(m.set.mphrirs,1)
    for i2 = 1:size(m.set.mphrirs,2)                    
        if (itd(i1,m.set.angle_ids(i2)) < 0)
            % Left ear later
            %disp('sound from right')
            %abs(model.dataset.itd_samples(i1,model.set.angle_ids(i2)))
            hrirs(i1,i2,1,:) = circshift(squeeze(m.set.mphrirs(i1,i2,1,:)),abs(itd(i1,m.set.angle_ids(i2))));
            hrirs(i1,i2,1,1:abs(itd(i1,m.set.angle_ids(i2)))) = 0;
            hrirs(i1,i2,2,:) = squeeze(m.set.mphrirs(i1,i2,2,:));
        else
            % Right ear later             
            %disp('sound from left')            
            %abs(model.dataset.itd_samples(i1,model.set.angle_ids(i2)))
            hrirs(i1,i2,2,:) = circshift(squeeze(m.set.mphrirs(i1,i2,2,:)),abs(itd(i1,m.set.angle_ids(i2))));
            hrirs(i1,i2,2,1:abs(itd(i1,m.set.angle_ids(i2)))) = 0;
            hrirs(i1,i2,1,:) = squeeze(m.set.mphrirs(i1,i2,1,:));
        end
    end
end