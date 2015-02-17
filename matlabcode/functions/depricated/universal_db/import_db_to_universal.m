function [sub_offset_new] =  import_db_to_universal(db,sub_offset,angles_ind,db_dir)

% Save specific source positions from a given HRTF database in GLOBAL db.mat file
[hrirs,~,~,~,~,~,~,~,~,~,fs] = db_import(db);

% use empty database and store import data in db.mat
load(sprintf('%s/db.mat',db_dir));

h = waitbar(0,'Overall Progress ...');

for sub=1:size(hrirs,1);
   
    %[mean_left,mean_right] = get_mean_subject(hrirs,i);

    for pos =1:length(angles_ind)
    
        % hrirs
        hrir_left = squeeze(hrirs(sub,angles_ind(pos),1,:));
        hrir_right = squeeze(hrirs(sub,angles_ind(pos),2,:));
        
        if (fs ~=44100) 
            % Change Sampling Rate to 44,1kHz
            hrir_left = resample(hrir_left,44100,fs);
            hrir_right = resample(hrir_right,44100,fs);
        end
        
        UNIVERSAL(sub_offset+sub,pos,1,1:length(hrir_left)) = hrir_left;
        UNIVERSAL(sub_offset+sub,pos,2,1:length(hrir_right)) = hrir_right;
        
    end

    
    waitbar(sub / size(hrirs,1))

end

sub_offset_new = sub_offset + size(hrirs,1);

% Save Values
save(sprintf('%s/db.mat',db_dir),'UNIVERSAL','UNIVERSAL_ANGLES');
close(h)
end

