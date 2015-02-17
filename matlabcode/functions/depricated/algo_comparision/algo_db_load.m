function [hrirs,dimensions] = algo_db_load(db)

[hrirs,~,~,angles,~,~,~,~,~,~,fs] = db_import(db{1});
dimensions.subjects = size(hrirs,1);
dimensions.angles = angles;
dimensions.samples = size(hrirs,4);
dimensions.fs = fs;

disp(sprintf('Finished: HRTF DB [%i x %i x %i x%i]',size(hrirs,1),size(hrirs,2),size(hrirs,3),size(hrirs,4)))

end