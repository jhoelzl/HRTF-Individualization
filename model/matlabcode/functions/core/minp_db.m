function [hrirs_min] = minp_db(hrirs)

% Convert HRIR Database to Minimum-phase HRIRs

for sub=1:size(hrirs,1)
    for pos=1:size(hrirs,2)
        for ear=1:size(hrirs,3)
        [~,hrirs_min(sub,pos,ear,:)] = rceps(hrirs(sub,pos,ear,:));
        end
    end
end
end