function db_choose(hObject, eventdata, handles)
% Import DBs and apply Data to GUI
clearvars -global DB ANGLES subjects UNIVERSAL_DTF pcs weights v mn

global subjects
global DB
global current_db
global fs
global ANGLES
global hrir_db_length
global UNIVERSAL_DTF
global subjects_mean_left
global subjects_mean_right

%set(handles.status_text,'String', '');
set(handles.azimuth,'Value', 1);
set(handles.elevation,'Value', 1);
set(handles.subject,'Value', 1);
        
database = database_import(current_db,1,1);

DB = database.hrirs;
hrir_db_length = size(DB,4);
fs = database.fs;
subjects = database.subjects;
db_anthro = database.data_anthro;
ANGLES = database.angles;
db_department = database.department;

%[DB,subjects,~,ANGLES,UNIVERSAL_DTF,hrir_db_length,~,~,db_department,db_anthro,fs] = db_import(current_db,1,hObject, eventdata, handles,1);

set(handles.db_text,'String',db_department);
set(handles.subject,'String',[subjects]);
set(handles.elevation,'String', unique(ANGLES(:,2)));
set(handles.azimuth,'String', unique(ANGLES(:,1)));

text_play_subjects = sprintf('Play %i Subjects',length(subjects));
set(handles.play_all_subjects,'String', text_play_subjects);

% Up-Down - search maximum/ minimum elevation
ud_max = max(unique(ANGLES(:,2)));
ud_min = min(unique(ANGLES(:,2)));

if (ud_max >= 30) & (ud_min <= 30)
set(handles.play_updown,'ForegroundColor',[0 0 0]);
else
set(handles.play_updown,'ForegroundColor',[0.7 0.7 0.7]);      
end

% Front-Back - search for Azimuth 0/180 or Elevation 180
fb_az = find(unique(ANGLES(:,1)) == 180);
fb_el = find(unique(ANGLES(:,2)) == 180);

if (isempty(fb_az) == 0 ) | (isempty(fb_el) == 0 )
set(handles.play_frontback,'ForegroundColor',[0 0 0]);
else
set(handles.play_frontback,'ForegroundColor',[0.7 0.7 0.7]);       
end


% Anthropometry
if (db_anthro == 0)
set(handles.anthropometric,'String', 'No Anthropometric Data available');           
end

% Set Focus to El=0, Az=0
el_ind = find(unique(ANGLES(:,2)) == 0);
az_ind = find(unique(ANGLES(:,1)) == 0);

set(handles.elevation,'Value',el_ind);
set(handles.azimuth,'Value',az_ind);

% Get Subjects Mean
if (strcmp(current_db,'universal') == 0)  
[subjects_mean_left, subjects_mean_right] = get_mean_subject(DB,1);
end

% Refresh GUI
plot_hrtf(hObject, eventdata, handles)
azimuth_playbutton(hObject, eventdata, handles)
update_azimuth(hObject, eventdata, handles)

end

