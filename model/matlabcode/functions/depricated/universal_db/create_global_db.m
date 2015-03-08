function create_global_db(dbs)

% This function creates a new HRFT database that combines the string HRTF
% database names in inout cell array "dbs"

% INPUT
% dbs: cell array of HRTF database names


db_name = '';
for db=1:length(dbs)
    db_name = sprintf('%s_%s',db_name,upper(dbs{db}));
end

db_name=db_name(2:(end));
db_dir = sprintf('../../db/%s',db_name);

if (exist(db_dir,'dir') ~= 7)
% Create DB directory
mkdir(db_dir);
end

% Build db.mat as new database file
[UNIVERSAL_ANGLES,db_ind,db_length] = coincident_angles(dbs);


UNIVERSAL = zeros(1,size(UNIVERSAL_ANGLES,1),2,max(cell2mat(db_length)));
save(sprintf('%s/db.mat',db_dir),'UNIVERSAL','UNIVERSAL_ANGLES');

% Import from original HRTF dbs
sub_offset = 0;
for db=1:length(dbs)
    [sub_offset] = import_db_to_universal(dbs{db},sub_offset,db_ind{db},db_dir);
end

disp(sprintf('DB Name: %s',db_name))
disp(sprintf('Subjects: %i',sub_offset))
disp(sprintf('Angles: %i',size(UNIVERSAL_ANGLES,1)))
end