function varargout = gui_setup(varargin)
% SETUP MATLAB code for setup.fig
%      SETUP, by itself, creates a new SETUP or raises the existing
%      singleton*.
%
%      H = SETUP returns the handle to a new SETUP or the handle to
%      the existing singleton*.
%
%      SETUP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETUP.M with the given input arguments.
%
%      SETUP('Property','Value',...) creates a new SETUP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before setup_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to setup_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help setup

% Last Modified by GUIDE v2.5 24-Apr-2013 19:40:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_setup_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_setup_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before setup is made visible.
function gui_setup_OpeningFcn(hObject, eventdata, handles, varargin)
global ari_id
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to setup (see VARARGIN)

% Choose default command line output for setup
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes setup wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% Import DB
[~, db_names] = config('exp');
set(handles.select_db,'String',db_names); 
choose_db_Callback(hObject, eventdata, handles)
set(handles.input_structure,'Value', 2)
set(handles.input_format,'Value', 3)


% --- Outputs from this function are returned to the command line.
function varargout = gui_setup_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function select_db_Callback(hObject, eventdata, handles)
 choose_db_Callback(hObject, eventdata, handles)


function choose_db_Callback(hObject, eventdata, handles)
global hrirs
global angles
global fs
global current_db
global ari_id
global subject_ids
global freq_mode
global pca_structur
global ear_mode
global ears

dbs = get(handles.select_db,'String');
selection = get(handles.select_db,'Value');
current_db = char(config_get(dbs{selection}));

[hrirs,subject_ids,~,angles,~,hrir_db_length,~,~,~,~,fs,exp_sub] = db_import(current_db);

if (isempty(ari_id) == 0) && (isempty(strfind(current_db,'ari')) == 0) && (ari_id ~= 0)
set(handles.include_own,'visible','on'); 
set(handles.include_own,'Value',0);
else
set(handles.include_own,'visible','off');   
end

set(handles.database_size,'String', exp_sub);
set(handles.database_size,'Value', length(exp_sub));





% --- Executes on button press in calc_input_matrix.
function calc_input_matrix_Callback(hObject, eventdata, handles)

clearvars -global pca_input pca_mean

global pca_input
global pca_mean
global hrirs
global fs
global excluded_hrtf
global current_db
global ari_id

% Matrix Structure
pca_structur = get(handles.input_structure,'Value');


% Input Format
if (get(handles.input_format,'Value') == 1)
   pca_mode = 2;
   pca_mean_mode = '';
end

if (get(handles.input_format,'Value') == 2)
   pca_mode = 1;
   pca_mean_mode = 1;
end

if (get(handles.input_format,'Value') == 3)
   pca_mode = 1;
   pca_mean_mode = 2;
end
    
% Freq Mode
freq_mode = get(handles.ear_mode,'Value');    
    
% Subjects
all_sizes = str2num(get(handles.database_size,'String'));
subjects = all_sizes(get(handles.database_size,'Value'));
if (size(hrirs,1) > subjects)
    subjects = size(hrirs,1);
end

% Ears
if (get(handles.database_size,'Value') == 1)
    ears = ':';
else
    ears= get(handles.database_size,'Value')-1;
end

% Ear Mode
ear_mode = get(handles.ear_mode,'Value');

% Minimum Phase System
minimum_phase = get(handles.minimum_phase,'Value');

% Smoothing 
smooth_strings = (get(handles.smoothing,'String'));
smooth_strings(1,:) = {'0'};
smooth_val = str2double(smooth_strings(get(handles.smoothing,'Value')));

% Remove own HRTF from Database

if (isempty(ari_id) == 0) && (isempty(strfind(current_db,'ari')) == 0) && (get(handles.include_own,'Value') == 0)
    sub_id_excl = ari_id;
    excluded_hrtf = 1;  
    subjects = subjects-1;
    hrirs(sub_id_excl,:,:,:) = [];
    disp('ARI ID was excluded')
else
    excluded_hrtf = 0;
    sub_id_excl = 0;
end


% Create INPUT MATRIX
[pca_input,pca_mean] = pca_in(hrirs(1:subjects,1:size(hrirs,2),ears,:),pca_mode,pca_structur,pca_mean_mode,freq_mode,ear_mode,minimum_phase,smooth_val,fs);

size(pca_input)

close(gcbf) 
%delete(gcbf) 


% --- Executes on selection change in input_format.
function input_format_Callback(hObject, eventdata, handles)

if (get(handles.input_format,'Value') ==1)
set(handles.freq_mode_text,'Visible','Off')
set(handles.freq_mode,'Visible','Off')
set(handles.smoothing_text,'Visible','Off')
set(handles.smoothing,'Visible','Off')
set(handles.minimum_phase,'Visible','On') 
else
set(handles.minimum_phase,'Visible','Off') 
set(handles.freq_mode_text,'Visible','On')
set(handles.freq_mode,'Visible','On')
set(handles.smoothing_text,'Visible','On')
set(handles.smoothing,'Visible','On')
    
end
