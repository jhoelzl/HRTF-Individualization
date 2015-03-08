function m = database_process(m)

% Database Import and Preprocessing

% 0 = use standard hrirs; 1 = use drirs when available in database
if ~isfield(m.database,'use_drirs')
    m.database.use_drirs = 0;
end

% Load DB
m.database = database_import(m.database.name,1,m.database.use_drirs);
    
% Adjust azimuthal angles to 0-359 and elevation angles to -90 to +90
m = adjust_angles(m);

% % Calc DTF from HRTFs
% % Go to log-domain (Cepstrum) to prevent negative frequencies on
% % averaging

% model.database.dtfs = 20*log10(model.database.hrtfs);
% model.database.dtfs = (model.database.hrtfs);

% Subtract Diffus Part, average over subjects
% model.database.dtfs = model.database.dtfs - repmat(mean(model.database.dtfs),[size(model.database.dtfs,1) ,1]);

% Substract ear canal, dependent of each subject, average over angles
% model.database.dtfs = model.database.dtfs - repmat(mean(model.database.dtfs,2),[1,size(model.database.dtfs,2)]);

% Go back to linear magnitude spectrum
% model.database.dtfs = 10.^(model.database.dtfs/20);

end