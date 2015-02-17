function [DATA,subjects,anthropometric,DATA_ANGLES,DATA_DTF,hrir_db_length,db_id,db_name,db_department,db_anthro,db_fs,exp_sub] = db_import(db,importmode,hObject, eventdata, handles,guimode,hrtf_dtf)

% Import several HRTF Databases in workspace

% INPUT
% db            name of the database
% importmode    optional: 1= all hrir data and angles, 2 = only angles
% guimode       1 or 2: use handle object (only possible for gui)
% hrtf_dtf      optional: 1= hrtf or 2=dtf when it is available in the database

% OUTPUT
% DATA          HRIR Data of whole db
% subjects      vector of subject_ids
% DATA_ANGLES   Matrix with Angle Entries
% DATA_DTF      only in UNIVERSAL db: directional transfer functions
% hrir_db_length  number of samples in hrirs
% db_id         database id(string)
% db_name       database name
% db_department database department
% db_anthro     1 when db contains anthropometric dimension, otherwise 0
% db_fs         database hrir sampling rate
% exp_sub       used for gui_experiment: select various different of subjects


if (nargin == 1)
    importmode = 1; 
end

if (nargin <= 2)
    hObject = 1;
    eventdata = 1;
    handles = 1;
    guimode = 0;
end

if (nargin <= 7) 
    hrtf_dtf = 1;
end

% Read config file
[db_id,db_name,db_department,~,db_anthro,db_fs,db_path,exp_sub] =config_get(db);

% Standard Values
DATA_ANGLES = [];
DATA_DTF = [];
anthropometric = [];

wait_text = sprintf('Import DATA from %s',upper(strrep(db,'_','\_')));
h = waitbar(0,wait_text);


if (guimode == 1)    
    set(handles.status_text,'ForeGroundColor', 'w');
    set(handles.status_text,'BackGroundColor', 'r');
    set(handles.status_text,'String', 'DB Import          ');
    pause(0.00001);
end
    

switch lower(db)
    
    
    %% IEM
    case 'iem'   
    % Angles
    el = zeros(1,24); az = 0:15:345;
    DATA_ANGLES = [az', el'];
    hrir_db_length=512;
    
    if (importmode == 1)
    % Detect all files
    files = dir(sprintf('%s*.mat',db_path)); 
    file_names = {files.name};    
    
    
    %DATA = zeros(length(file_names),size(DATA_ANGLES,1),2,hrir_db_length);
    DATA (length(file_names),size(DATA_ANGLES,1),2,hrir_db_length) = 0; % faster
    subjects = zeros(length(file_names),1);
    
    % Import mat Files
    for i = 1:1:length(file_names)
        
    var = sprintf('%02.0f',i);
    name = [db_path,var,'.mat'];
    
    var = str2double(var);
    % Save Subject number in Workspace
    subjects(i) = var;
        
    % Save HRTF Data in Matrix
    load(name);    
  
    DATA(i,:,1,:) = HRTF_left';
    DATA(i,:,2,:) = HRTF_right';

    waitbar(i / length(file_names))
    end   
    end
    

    %% CIPIC
    case 'cipic'
    % Angles
    el = -45 + 5.625*(0:49);
    az = [-80 -65 -55 -45:5:45 55 65 80];
    
    steps = 45; 
    hrir_db_length = 200;
    DATA(steps,length(az),length(el),2,hrir_db_length) = 0; %faster
    subjects = zeros(steps,1);
    counter = 0;
    
    c=0;
    for i=1:length(el)
        c=c+length(az);
        DATA_ANGLES(c-24:c,2) = el(i);
    end
    DATA_ANGLES(:,1)= repmat(az,1,length(el));
    
   % Adjust Azimuth and Elevation Angles position Matrix angles
   %[DATA_ANGLES] = lat2geo(DATA_ANGLES);
   
   %size(DATA_ANGLES)
    if (importmode == 1)
        for i=1:1:165
        
        var = sprintf('%03.0f',i);
        name = [db_path,'/subject_',var,'/hrir_final.mat'];

            if (exist(name,'file') == 2)
            counter = counter +1;
            
            % Save Subject number in Workspace
            var = str2double(var);
            subjects(counter) = var;
            
            load(name,'hrir_l','hrir_r');
            % Save Data in Matrix
            DATA(counter,:,:,1,:) = hrir_l;
            DATA(counter,:,:,2,:) = hrir_r;

            waitbar(counter / steps)

           end
        end
    
    DATA = reshape(DATA,steps,1250,2,hrir_db_length);   
    end
    
     %% IRCAM
    case 'ircam'
    hrir_db_length = 512;    
    steps = 50;
    %DATA = zeros(steps,187,2,hrir_db_length);
    %DATA(steps,187,2,hrir_db_length) = 0; %faster
    
    subjects = zeros(steps,1);
    counter = 0;
        
        for i=1:1:59
        
            if (i ~= 34) % exclude subject ID 1034
                
            var = sprintf('%02.0f',i);
            name = [db_path,'IRC_10',var,'/COMPENSATED/MAT/HRIR/IRC_10',var,'_C_HRIR.mat'];


            if (exist(name,'file') == 2)
            counter = counter +1;

            % Save Subject number in Workspace
            var = str2double(var);
            subjects(counter) = var;

            load(name);
            % Save Data in Matrix

            if (importmode == 1)
            DATA(counter,:,1,:) = l_eq_hrir_S.content_m;
            DATA(counter,:,2,:) = r_eq_hrir_S.content_m;
            end

            DATA_ANGLES = [l_eq_hrir_S.azim_v,l_eq_hrir_S.elev_v];

            waitbar(counter / steps)

            end
            end
        end
        
        
   %% UNIVERSAL
   case {'universal'}
        
        hrir_db_length = 512;
        
        load(sprintf('%sdb.mat',db_path),'UNIVERSAL','UNIVERSAL_ANGLES')
        waitbar(1 / 2)
        
        load(sprintf('%sdb.mat',db_path),'UNIVERSAL_DTF')
        waitbar(2 / 2)
        
        subjects = [1:size(UNIVERSAL,1)];
        
        DATA = UNIVERSAL;
        DATA_DTF = UNIVERSAL_DTF;
        DATA_ANGLES = UNIVERSAL_ANGLES;
  
            
     %% KEMAR
    case 'kemar' 
    hrir_db_length = 512;
    steps = 710;
    %DATA = zeros(1,steps,2,hrir_db_length); 
    DATA(1,steps,2,hrir_db_length) = 0; % faster
    DATA_ANGLES = zeros(steps,2);
    counter = 1;
    
    % Save Subject number in Workspace (only 1 Subject here)
    subjects = [1];
    
    % Provided Elevation Angles
    elev = [-40:10:90];
    
    for k=1:1:length(elev)
     
    el = sprintf('%02.0f',elev(k)); 
       
    % Adjust for Elevation = 0
    if strcmp (el, '00') == 1
    el = '0';    
    end
    
    elev_directory = [db_path,'full/elev',el];
    %disp(elev_directory)
   
        for i=0:1:355
         
        if (i == 0)
            %insertcounter = 0;
        end
         
     az = sprintf('%03.0f',i);    
     name_l = [elev_directory,'/L',el,'e',az,'a.wav'];
     name_r = [elev_directory,'/R',el,'e',az,'a.wav'];
       
     if (exist(name_l,'file') == 2)
         
         if (importmode == 1)
         hrir_l = wavread(name_l);
         hrir_r = wavread(name_r);
        
         DATA(1,counter,1,:) = hrir_l;
         DATA(1,counter,2,:) = hrir_r;
         end
         
         DATA_ANGLES(counter,1) = mod(360-str2num(az),360); 
         DATA_ANGLES(counter,2) = str2num(el); 
         
         
         counter = counter +1;
         waitbar(counter / steps)
     end
     
    
    end
     
    end
    
     
    %% ARI
    case 'ari'  
    hrir_db_length = 256;
    ari_dir = dir(sprintf('%sARI_hrtf 256/',db_path));
    
    if (importmode == 1)
    % Filter Output
    ari_dir = regexprep(({ari_dir.name}),'NH', '');
    dir_names = str2double(ari_dir);
    dir_nan = isnan(dir_names);
    dir_names = sort((dir_names(dir_nan ~= 1)));
    
    %Exclude Subject No 10, 22 ( only 1448/9 (instead of 1550) positions
    % for person)
    dir_names = dir_names(dir_names~=10);
    dir_names = dir_names(dir_names~=22);
    
    subjects = zeros(length(dir_names),1);
    DATA = zeros(length(dir_names),1550,2,256);
   
    
    % Detect all sub directories
    for i=1:length(dir_names)
        
        var = sprintf('%i',dir_names(i));
        
        if (hrtf_dtf == 1)
            % HRTF
            name = [db_path,'ARI_hrtf 256/NH',var,'/hrtf_M_hrtf 256.mat'];
        else
            % DTF
            name = [db_path,'ARI_dtf 256/NH',var,'/hrtf_M_dtf 256.mat'];
        end
        
        subjects(i) = dir_names(i);
        
        load(name);    
        %[a,b,c] = size(hM); % sometimes
        DATA(i,:,:,:) = permute(hM,[2,3,1]);
        
        waitbar(i / length(dir_names))
        
    end
    
    end
    % Import one posLIN Matrix for source positions
    load(sprintf('%sARI_hrtf 256/NH2/hrtf_M_hrtf 256.mat',db_path));    
    DATA_ANGLES = meta.pos(:,1:2);
    
    
        
    %% DB NOT FOUND
    otherwise
    if (exist(db_path,'dir') == 7)    
        
        load(sprintf('%sdb.mat',db_path),'UNIVERSAL','UNIVERSAL_ANGLES')
        waitbar(1 / 1)
        
        subjects = [1:size(UNIVERSAL,1)];
        hrir_db_length = [1:size(UNIVERSAL,4)];
        
        DATA = UNIVERSAL;
        DATA_ANGLES = UNIVERSAL_ANGLES;
        
    else
        
        disp 'HRTF Database not found'
        
    end
        
        
end

if (guimode == 1)   
    % GUI Text Status
    message = sprintf('%d subjects imported         ',length(subjects));
    set(handles.status_text,'String', message);
    set(handles.status_text,'ForeGroundColor', [0 0.5 0]);
    set(handles.status_text,'BackGroundColor', [230 228 228]/255);
end
    
close(h)
pause(0.001)

if (importmode == 2)
    DATA = [];
    subjects = [];
    anthropometric = [];
end

%DATA_ANGLES=correct_angles(DATA_ANGLES,db);

% Normalize HRIRs
DATA = DATA/max(max(max(max(DATA))));

end