function varargout = gui(varargin)
% Implementation (c) Josef Hölzl
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function gui_OpeningFcn(hObject, eventdata, handles, varargin)
global current_db

%% --- Executes just before gui is made visible.
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% subject default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(handles.subject,'string',0);
set(handles.status_text,'String', 'Select HRTF DB');

set(handles.peak_slider,'Value',10);

% Add Function Path and correct false path
current_path = pwd;
[~, pathname] = fileparts(current_path);
if strcmp (pathname, 'functions') == 1
     cd ..
     current_path = pwd;
end
    
functions_path  = [current_path,'/functions'];
path(current_path,path);
path(functions_path,path);

[~, db_names] = config();
set(handles.db_choose,'String',db_names); 

current_db = 'iem';
db_choose_Callback(hObject, eventdata, handles)

function varargout = gui_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

function subject_Callback(hObject, eventdata, handles)
global subjects_mean_left
global subjects_mean_right
global current_db
global DB
global current_subject

% Get Subjects Mean
if (strcmp(current_db,'universal') == 0)  
[subjects_mean_left, subjects_mean_right] = get_mean_subject(DB,current_subject);
end

% Play and Plot Single HRTF
play_hrtf(hObject, eventdata, handles)
plot_hrtf(hObject, eventdata, handles)

function azimuth_Callback(hObject, eventdata, handles)

% Play and Plot Single HRTF
play_hrtf(hObject, eventdata, handles)
plot_hrtf(hObject, eventdata, handles)
azimuth_playbutton(hObject, eventdata, handles)

function pca_db_Callback(hObject, eventdata, handles)
global current_pca;
global current_db;
global current_azimuth;
global current_elevation;

% Get PCA Choice
current_pca = get(handles.pca_choose,'Value');

if (current_pca == 4)
            
    switch(current_db)
            
            case {'iem','cipic','ircam','ari','universal'}
            gui_pca_subjects;
            
            otherwise
            errordlg('No such pca modus for this db. Please select another db')    
    end
    
else
    gui_pca_frequency;
end

function elevation_Callback(hObject, eventdata, handles)
update_azimuth(hObject, eventdata, handles)
play_hrtf(hObject, eventdata, handles);
plot_hrtf(hObject, eventdata, handles);

function play_hrtf_Callback(hObject, eventdata, handles)
listen_single_hrtf(hObject, eventdata, handles);    

function play_all_azimuth_Callback(hObject, eventdata, handles)
listen_hrtf_azimuth(hObject, eventdata, handles); 

function play_all_elevations_Callback(hObject, eventdata, handles)
listen_hrtf_elevation(hObject, eventdata, handles); 

function show_peaks_Callback(hObject, eventdata, handles)
plot_hrtf(hObject, eventdata, handles)

function peak_slider_Callback(hObject, eventdata, handles)
plot_hrtf(hObject, eventdata, handles)

function play_frontback_Callback(hObject, eventdata, handles)
listen_hrtf_frontback(hObject, eventdata, handles); 

function play_updown_Callback(hObject, eventdata, handles)
listen_hrtf_updown(hObject, eventdata, handles); 

function plot_display_Callback(hObject, eventdata, handles)
plot_hrtf(hObject, eventdata, handles)

function plot_axes_Callback(hObject, eventdata, handles)
plot_hrtf(hObject, eventdata, handles)

function plot_type_Callback(hObject, eventdata, handles)
plot_hrtf(hObject, eventdata, handles)

function fft_smooth_Callback(hObject, eventdata, handles)
plot_hrtf(hObject, eventdata, handles)

function show_d_Callback(hObject, eventdata, handles)
plot_hrtf(hObject, eventdata, handles)

function zoom_plot_Callback(hObject, eventdata, handles)

if(get(handles.zoom_plot,'Value') == 1)
set(handles.hrir_l,'Outerposition',[0.132, 0.62, 0.54, 0.4]);
set(handles.hrir_r,'Outerposition',[0.519, 0.62, 0.54, 0.4]);
set(handles.hrtf_r,'Outerposition',[0.519, 0.3, 0.54, 0.4]);
set(handles.hrtf_l,'Outerposition',[0.132, 0.299, 0.54, 0.403]);


set(handles.hrir_r,'visible','on');
set(handles.hrir_l,'visible','on');
set(handles.hrtf_r,'visible','on');
set(handles.hrtf_l,'visible','on');

end


if(get(handles.zoom_plot,'Value') == 2)

set(allchild(handles.hrir_r),'visible','off'); 
set(allchild(handles.hrtf_l),'visible','off'); 
set(allchild(handles.hrtf_r),'visible','off'); 
    
set(handles.hrir_r,'visible','off');
set(handles.hrtf_l,'visible','off');
set(handles.hrtf_r,'visible','off');  
set(handles.hrir_l,'visible','on');  
set(handles.hrir_l,'Outerposition',[0.00886072847566241, 0.16545767545156476, 1.1396682594414194, 0.9465037813828494]);

end

if(get(handles.zoom_plot,'Value') == 3)
set(handles.hrir_r,'Outerposition',[0.00886072847566241, 0.16545767545156476, 1.1396682594414194, 0.9465037813828494]);

set(allchild(handles.hrir_l),'visible','off'); 
set(allchild(handles.hrtf_r),'visible','off'); 
set(allchild(handles.hrtf_l),'visible','off'); 

set(handles.hrir_l,'visible','off');
set(handles.hrtf_r,'visible','off');
set(handles.hrtf_l,'visible','off');
end

if(get(handles.zoom_plot,'Value') == 4)
set(handles.hrtf_l,'Outerposition',[0.00886072847566241, 0.16545767545156476, 1.1396682594414194, 0.9465037813828494]);

set(allchild(handles.hrir_l),'visible','off'); 
set(allchild(handles.hrir_r),'visible','off'); 
set(allchild(handles.hrtf_r),'visible','off'); 

set(handles.hrir_l,'visible','off');
set(handles.hrtf_r,'visible','off');
set(handles.hrir_r,'visible','off');
end

if(get(handles.zoom_plot,'Value') == 5)
set(handles.hrtf_r,'Outerposition',[0.00886072847566241, 0.16545767545156476, 1.1396682594414194, 0.9465037813828494]);

set(allchild(handles.hrir_l),'visible','off'); 
set(allchild(handles.hrir_r),'visible','off'); 
set(allchild(handles.hrtf_l),'visible','off'); 

set(handles.hrir_l,'visible','off');
set(handles.hrtf_l,'visible','off');
set(handles.hrir_r,'visible','off');
end

plot_hrtf(hObject, eventdata, handles)

function plot_correlations_Callback(hObject, eventdata, handles)

if(get(handles.correlations_choose,'Value') == 1)
  plot_corr_itd_head(hObject, eventdata, handles); 
end

function play_all_subjects_Callback(hObject, eventdata,handles)
listen_hrtf_subjects(handles); 

function db_choose_Callback(hObject, eventdata, handles)
global current_db

dbs = get(handles.db_choose,'String');
selection = get(handles.db_choose,'Value');
current_db = char(config_get(dbs{selection}));
db_choose(hObject, eventdata, handles);
