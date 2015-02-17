function varargout = gui_pca_subjects(varargin)
% GUI_PCA_SUBJECTS M-file for gui_pca_subjects.fig
%      GUI_PCA_SUBJECTS, by itself, creates a new GUI_PCA_SUBJECTS or raises the existing
%      singleton*.
%
%      H = GUI_PCA_SUBJECTS returns the handle to a new GUI_PCA_SUBJECTS or the handle to
%      the existing singleton*.
%
%      GUI_PCA_SUBJECTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_PCA_SUBJECTS.M with the given input arguments.
%
%      GUI_PCA_SUBJECTS('Property','Value',...) creates a new GUI_PCA_SUBJECTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_pca_subjects_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_pca_subjects_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_pca_subjects

% Last Modified by GUIDE v2.5 14-Jul-2011 14:44:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_pca_subjects_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_pca_subjects_OutputFcn, ...
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


function gui_refresh(hObject, eventdata, handles)
global DB
global ANGLES
global subjects
global current_db


set(handles.sliderl1,'Value', 1);
set(handles.sliderl2,'Value', 1);
set(handles.sliderl3,'Value', 1);
set(handles.sliderl4,'Value', 1);
set(handles.sliderl5,'Value', 1);

set(handles.sliderr1,'Value', 1);
set(handles.sliderr2,'Value', 1);
set(handles.sliderr3,'Value', 1);
set(handles.sliderr4,'Value', 1);
set(handles.sliderr5,'Value', 1);

set(handles.reconstruct_nr,'String', 1:length(subjects));
set(handles.pca_elevation,'String', unique(ANGLES(:,2)));
set(handles.pca_azimuth,'String', unique(ANGLES(:,1)));

switch(current_db)
    
    case 'iem'
    set(handles.pca_db_choose,'Value',1);  
    set(handles.pca_elevation,'Value',1); 
    set(handles.pca_azimuth,'Value',1); 
    
    set(handles.view_mode,'visible','off');
    set(handles.remove_null,'visible','off');
    set(handles.view_text,'visible','off');
   
    case 'ircam'
        
    set(handles.view_mode,'visible','off');
    set(handles.remove_null,'visible','off');
    set(handles.view_text,'visible','off');

    case 'cipic'
    set(handles.pca_db_choose,'Value',4); 
    set(handles.pca_elevation,'Value',9); 
    set(handles.pca_azimuth,'Value',13); 
    
    
    set(handles.view_mode,'visible','on');
    set(handles.remove_null,'visible','on');
    set(handles.view_text,'visible','on');
    
    case 'universal'
    set(handles.pca_db_choose,'Value',5); 
    set(handles.pca_elevation,'Value',1);
    set(handles.pca_azimuth,'Value',1); 
    
    set(handles.view_mode,'visible','off');
    set(handles.remove_null,'visible','off');
    set(handles.view_text,'visible','off');

    case 'ari'
    set(handles.pca_db_choose,'Value',3); 
    set(handles.pca_elevation,'Value',1);
    set(handles.pca_azimuth,'Value',1); 
         
    set(handles.view_mode,'visible','on');
    set(handles.remove_null,'visible','on');
    set(handles.view_text,'visible','on');    
end


function gui_restart(hObject, eventdata, handles)
global current_azimuth
global current_elevation
global current_db
global azimuth_real
global elevation_real
global UNIVERSAL_DTF
global CIPIC_anthropometric
global ANGLES
global DB
global subjects
global fs
global db_anthro
global hrir_db_length

clearvars -global CIPIC_anthropometric UNIVERSAL_DTF DATA_PCA_left DATA_PCA_right pc_l pc_r mn_l mn_r weight_l weight_r v_l v_r anthro_data
    
[DB,subjects,~,ANGLES,UNIVERSAL_DTF,hrir_db_length,~,~,~,db_anthro,fs] = db_import(current_db);
gui_refresh(hObject, eventdata, handles)

% Set Focus to El=0, Az=0
az_ind = find(unique(ANGLES(:,1)) == 0);
el_ind = find(unique(ANGLES(:,2)) == 0);
set(handles.pca_azimuth,'Value',az_ind);
set(handles.pca_elevation,'Value',el_ind);

perform_pca_direction_subjects(hObject, eventdata, handles);    
view_mode_Callback(hObject, eventdata, handles)

function gui_pca_subjects_OpeningFcn(hObject, eventdata, handles,varargin)
global current_azimuth
global current_elevation
global current_db
global ANGLES
global weight_l_recon
global weight_r_recon
global hrir_db_length
global fs

gui_refresh(hObject, eventdata, handles)

% Set Azimuth / Elevation
set(handles.pca_elevation,'Value',current_elevation);
update_pca_azimuth(hObject, eventdata, handles)
set(handles.pca_azimuth,'Value',current_azimuth); 


perform_pca_direction_subjects(hObject, eventdata, handles);
view_mode_Callback(hObject, eventdata, handles)

% Choose default command line output for gui_pca_subjects
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_pca_subjects wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function varargout = gui_pca_subjects_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function plot_slider_Callback(hObject, eventdata, handles)
plot_pca_db(hObject, eventdata, handles)


function plot_slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function reconstruct_button_Callback(hObject, eventdata, handles)



function reconstruct_pcs_Callback(hObject, eventdata, handles) 


function reconstruct_pcs_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function view_corr_Callback(hObject, eventdata, handles)

function view_mode_Callback(hObject, eventdata, handles)

global current_db;
global current_azimuth;
global current_elevation;
global anthro_data;
global DB
global ANGLES
global azimuth_real
global elevation_real
global subjects
    
    if (strcmp(current_db,'cipic') == 1)  | (strcmp(current_db,'ari') == 1)
        
        anthro_data = zeros(1,length(subjects));
        
        
        switch(get(handles.view_mode,'Value'))
            
        case 1
           %nothing
            %% C DATA  
       case 2
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'head width',current_db);
            end
        
            
        case 3
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'head height',current_db);
            end
        
        case 4
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'head depth',current_db);
            end  
            
        case 5
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'pinna offset down',current_db);
            end  
            
        case 6
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'pinna offset back',current_db);
            end  
            
         case 7
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'neck width',current_db);
            end   
         case 8
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'neck height',current_db);
            end    
            
         case 9
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'neck depth',current_db);
            end       
        
        case 10
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'torso top width',current_db);
            end 
            
        case 11
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'torso top height',current_db);
            end  
            
        case 12
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'torso top depth',current_db);
            end         
            
            
        case 13
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'shoulder width',current_db);
            end 
            
        case 14
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'head offset forward',current_db);
            end     
            
        case 15
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'height',current_db);
            end    
            
        case 16
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'seated height',current_db);
            end   
            
        case 17
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'head circumference',current_db);
            end       
            
        case 18
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'shoulder circumference',current_db);
            end       
       
       %% D DATA (for left AND right ear)
            
       
       case 19
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'cavum concha height left',current_db);
            end 
       
       case 20
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'cavum concha height right',current_db);
            end  
       
       case 21
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'cymba concha height left',current_db);
            end 
       
       case 22
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'cymba concha height right',current_db);
            end 
       
       case 23
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'cavum concha width left',current_db);
            end  
            
       case 24
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'cavum concha width right',current_db);
            end     
            
       case 25
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'fossa height left',current_db);
            end 
            
       case 26
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'fossa height right',current_db);
            end      
       
        case 27
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'pinna height left',current_db);
            end        
            
        case 28
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'pinna height right',current_db);
            end  
            
            
         case 29
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'pinna width left',current_db);
            end        
            
        case 30
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'pinna width right',current_db);
            end  
            
         case 31
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'intertragal incisure width left',current_db);
            end        
            
        case 32
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'intertragal incisure width right',current_db);
            end   
            
         case 33
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'cavum concha depth left',current_db);
            end        
            
        case 34
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'cavum concha depth right',current_db);
            end      
            
            
        case 35
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'pinna rotation angle left',current_db);
            end        
            
        case 36
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'pinna rotation angle right',current_db);
            end    
        
        case 37
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'pinna flare angle left',current_db);
            end        
            
        case 38
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'pinna flare angle right',current_db);
            end        
 
            
       case 39
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'pinna-cavity height left',current_db);
            end   

       case 40
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'pinna-cavity height right',current_db);
            end       
            
       case 41
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'age',current_db);
            end    
  
       case 42
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'gender_number',current_db);
            end  
            
        case 43
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'weight',current_db);
            end          
            
            
        case 44
            % ITD
            for i=1:length(subjects)
            
            plotdata_l = squeeze(DB(i,get_matrixvalue(azimuth_real,elevation_real,ANGLES),1,:));
            plotdata_r = squeeze(DB(i,get_matrixvalue(azimuth_real,elevation_real,ANGLES),2,:));            
            anthro_data(i) = calculate_itd(plotdata_l,plotdata_r);
            end
            
       case 45
           % d11 left
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'cavum concha height left',current_db) + anthro1(i,'cymba concha height left',current_db);
            end
            
       case 46
           % d11 right
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'cavum concha height right',current_db) + anthro1(i,'cymba concha height right',current_db);
            end           
    
       case 47
           % d12 left
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'cavum concha height left',current_db) + anthro1(i,'cymba concha height left',current_db) + anthro1(i,'fossa height left',current_db);
            end   
            
       case 48
           % d12 right
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'cavum concha height right',current_db) + anthro1(i,'cymba concha height right',current_db) + anthro1(i,'fossa height right',current_db);
            end  
            
       case 49
           % d13 left
            for i=1:length(subjects)
            anthro_data(i) = (anthro1(i,'cavum concha height left',current_db) + anthro1(i,'cymba concha height left',current_db)) * anthro1(i,'cavum concha width left',current_db);
            end
            
       case 50
           % d13 right
            for i=1:length(subjects)
            anthro_data(i) = (anthro1(i,'cavum concha height right',current_db) + anthro1(i,'cymba concha height right',current_db)) * anthro1(i,'cavum concha width right',current_db);
            end   
            
       case 51
           % d14 left
            for i=1:length(subjects)
            anthro_data(i) = (anthro1(i,'cavum concha height left',current_db) + anthro1(i,'cymba concha height left',current_db)) * anthro1(i,'cavum concha width left',current_db)* anthro1(i,'cavum concha depth left',current_db);
            end  
            
       case 52
           % d14 right
            for i=1:length(subjects)
            anthro_data(i) = (anthro1(i,'cavum concha height right',current_db) + anthro1(i,'cymba concha height right',current_db)) * anthro1(i,'cavum concha width right',current_db)* anthro1(i,'cavum concha depth right',current_db);
            end       
        
       case 53
           % d15 left
            for i=1:length(subjects)
            anthro_data(i) = (anthro1(i,'cavum concha height left',current_db) + anthro1(i,'cymba concha height left',current_db)) * anthro1(i,'cavum concha width left',current_db)* anthro1(i,'pinna flare angle left',current_db);
            end 
            
       case 54
           % d15 right
            for i=1:length(subjects)
            anthro_data(i) = (anthro1(i,'cavum concha height right',current_db) + anthro1(i,'cymba concha height right',current_db)) * anthro1(i,'cavum concha width right',current_db)* anthro1(i,'pinna flare angle right',current_db);
            end   
            
       
       case 55
            % d16 left
            for i=1:length(subjects)
            anthro_data(i) = (anthro1(i,'cavum concha height left',current_db) + anthro1(i,'cymba concha height left',current_db)) * anthro1(i,'intertragal incisure width left',current_db)* anthro1(i,'cavum concha depth left',current_db);
            end  
            
       case 56
            % d16 right
            for i=1:length(subjects)
            anthro_data(i) = (anthro1(i,'cavum concha height right',current_db) + anthro1(i,'cymba concha height right',current_db)) * anthro1(i,'intertragal incisure width right',current_db)* anthro1(i,'cavum concha depth right',current_db);
            end    
            
      case 57
            % d17 left
            for i=1:length(subjects)
            anthro_data(i) = (anthro1(i,'cavum concha height left',current_db) + anthro1(i,'cymba concha height left',current_db)) * anthro1(i,'intertragal incisure width left',current_db)* anthro1(i,'pinna flare angle left',current_db);
            end 
            
      case 58
            % d17 right
            for i=1:length(subjects)
            anthro_data(i) = (anthro1(i,'cavum concha height right',current_db) + anthro1(i,'cymba concha height right',current_db)) * anthro1(i,'intertragal incisure width right',current_db)* anthro1(i,'pinna flare angle right',current_db);
            end  
            
       case 59
           % d18 left
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'cavum concha height left',current_db) * anthro1(i,'cavum concha width left',current_db);
            end      
            
       case 60
           % d18 right
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'cavum concha height right',current_db) * anthro1(i,'cavum concha width right',current_db);
            end       
       
        case 61
           % d19 left
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'pinna height left',current_db) * anthro1(i,'pinna width left',current_db);
            end 
            
       case 62
           % d19 right
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'pinna height left',current_db) * anthro1(i,'pinna width left',current_db);
            end  
            
       case 63
           % d20 left
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'pinna height left',current_db) * anthro1(i,'pinna width left',current_db) * anthro1(i,'cavum concha depth left',current_db);
            end
            
       case 64
           % d20 right
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'pinna height right',current_db) * anthro1(i,'pinna width right',current_db) * anthro1(i,'cavum concha depth right',current_db);
            end     
            
       case 65
           % d21 left
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'pinna height left',current_db) * anthro1(i,'pinna width left',current_db) * anthro1(i,'pinna flare angle left',current_db);
            end  
            
       case 66
           % d21 right
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'pinna height right',current_db) * anthro1(i,'pinna width right',current_db) * anthro1(i,'pinna flare angle right',current_db);
            end   
            
            
         case 67
           % d22 left
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'fossa height left',current_db) * anthro1(i,'pinna width left',current_db);
            end   
            
        case 68
           % d22 right
            for i=1:length(subjects)
            anthro_data(i) = anthro1(i,'fossa height right',current_db) * anthro1(i,'pinna width right',current_db);
            end       
                
        end
        
        

   
    else     
        %errordlg('No anthropometric data in this db. Please select CIPIC or ARI')
        
end


 % Plot PCA
        plot_pca_subjects_left(hObject, eventdata, handles,0)
        plot_pca_subjects_right(hObject, eventdata, handles,0)
        

function remove_null_Callback(hObject, eventdata, handles)
plot_pca_subjects_left(hObject, eventdata, handles,0)
plot_pca_subjects_right(hObject, eventdata, handles,0)


function update_pca_azimuth(hObject, eventdata, handles)
global current_elevation
global elevation_real
global ANGLES


current_elevation = get(handles.pca_elevation,'Value'); 
all_elevation = str2num(get(handles.pca_elevation,'String'));
elevation_real = all_elevation(current_elevation);


set(handles.pca_azimuth,'Value', 1);
indizes = find(ANGLES(:,2) == elevation_real);
new_azimuth_values = zeros(length(indizes),1);

for i=1:length(indizes)
    new_azimuth_values(i) = ANGLES(indizes(i),1);
end

new_azimuth_values = sort(new_azimuth_values);    
set(handles.pca_azimuth,'String', new_azimuth_values);


function pca_elevation_Callback(hObject, eventdata, handles,mode)
global current_elevation;
global elevation_real;
global ANGLES

update_pca_azimuth(hObject, eventdata, handles)

if (mode == 0)
perform_pca_direction_subjects(hObject, eventdata, handles);  
end
view_mode_Callback(hObject, eventdata, handles)


function pca_azimuth_Callback(hObject, eventdata, handles)

global current_azimuth;
global azimuth_real;



current_azimuth = get(handles.pca_azimuth,'Value');

% Get All Azimuth Listbox values
Selection = get(handles.pca_azimuth,'String'); 
handles.Selection = Selection; 
all_azimuth = Selection;
all_azimuth = str2num(all_azimuth);
azimuth_real = all_azimuth(current_azimuth);

perform_pca_direction_subjects(hObject, eventdata, handles);  
view_mode_Callback(hObject, eventdata, handles)


function pca_db_choose_Callback(hObject, eventdata, handles)
global current_db

db_choose = get(handles.pca_db_choose,'Value');

switch(db_choose)
    case 1
        current_db = 'iem';
    case 2
        current_db = 'ircam';
    case 3
        current_db = 'ari';
    case 4
        current_db = 'cipic';
    case 5
        current_db = 'universal';    
    
end

gui_restart(hObject, eventdata, handles);

function show_sliders_Callback(hObject, eventdata, handles)

if(get(handles.show_sliders,'Value') == 1)
set(handles.sliderl1,'visible','on');
set(handles.sliderl2,'visible','on');
set(handles.sliderl3,'visible','on');
set(handles.sliderl4,'visible','on');
set(handles.sliderl5,'visible','on');

set(handles.sliderr1,'visible','on');
set(handles.sliderr2,'visible','on');
set(handles.sliderr3,'visible','on');
set(handles.sliderr4,'visible','on');
set(handles.sliderr5,'visible','on');
end

if(get(handles.show_sliders,'Value') == 0)
set(handles.sliderl1,'visible','off');
set(handles.sliderl2,'visible','off');
set(handles.sliderl3,'visible','off');
set(handles.sliderl4,'visible','off');
set(handles.sliderl5,'visible','off');

set(handles.sliderr1,'visible','off');
set(handles.sliderr2,'visible','off');
set(handles.sliderr3,'visible','off');
set(handles.sliderr4,'visible','off');
set(handles.sliderr5,'visible','off');
end


% --- Executes on slider movement.
function sliderl1_Callback(hObject, eventdata, handles,mode)
global weight_l
global weight_l_recon

score = weight_l(:,1);
new_value = get(handles.sliderl1,'Value');
weight_l_recon(:,1) = score * new_value;
plot_pca_subjects_left(hObject, eventdata, handles,1)

if (mode ~= 1) & (get(handles.pair_sliders,'Value') == 1)
    set(handles.sliderr1,'Value',new_value);
    sliderr1_Callback(hObject, eventdata, handles,1)
end
    
if (mode ~= 1) & (get(handles.play_slider_change,'Value') == 1)
play_reconstruction_Callback(hObject, eventdata, handles,2)
end

function sliderl2_Callback(hObject, eventdata, handles,mode)
global weight_l
global weight_l_recon

score = weight_l(:,2);
new_value = get(handles.sliderl2,'Value');
weight_l_recon(:,2) = score * new_value;
plot_pca_subjects_left(hObject, eventdata, handles,2)

if (mode ~= 1) & (get(handles.pair_sliders,'Value') == 1)
    set(handles.sliderr2,'Value',new_value);
    sliderr2_Callback(hObject, eventdata, handles,1)
end

if (mode ~= 1) & (get(handles.play_slider_change,'Value') == 1)
play_reconstruction_Callback(hObject, eventdata, handles,2)
end


function sliderl3_Callback(hObject, eventdata, handles,mode)
global weight_l
global weight_l_recon

score = weight_l(:,3);
new_value = get(handles.sliderl3,'Value');
weight_l_recon(:,3) = score * new_value;
plot_pca_subjects_left(hObject, eventdata, handles,3)

if (mode ~= 1) & (get(handles.pair_sliders,'Value') == 1)
    set(handles.sliderr3,'Value',new_value);
    sliderr3_Callback(hObject, eventdata, handles,1)
end

if (mode ~= 1) & (get(handles.play_slider_change,'Value') == 1)
play_reconstruction_Callback(hObject, eventdata, handles,2)
end


function sliderl4_Callback(hObject, eventdata, handles,mode)
global weight_l
global weight_l_recon

score = weight_l(:,4);
new_value = get(handles.sliderl4,'Value');
weight_l_recon(:,4) = score * new_value;
plot_pca_subjects_left(hObject, eventdata, handles,4)

if (mode ~= 1) & (get(handles.pair_sliders,'Value') == 1)
    set(handles.sliderr4,'Value',new_value);
    sliderr4_Callback(hObject, eventdata, handles,1)
end

if (mode ~= 1) &  (get(handles.play_slider_change,'Value') == 1)
play_reconstruction_Callback(hObject, eventdata, handles,2)
end

function sliderl5_Callback(hObject, eventdata, handles,mode)
global weight_l
global weight_l_recon

score = weight_l(:,5);
new_value = get(handles.sliderl5,'Value');
weight_l_recon(:,5) = score * new_value;
plot_pca_subjects_left(hObject, eventdata, handles,5)

if (mode ~= 1) & (get(handles.pair_sliders,'Value') == 1)
    set(handles.sliderr5,'Value',new_value);
    sliderr5_Callback(hObject, eventdata, handles,1)
end

if (mode ~= 1) &  (get(handles.play_slider_change,'Value') == 1)
play_reconstruction_Callback(hObject, eventdata, handles,2)
end


function sliderr1_Callback(hObject, eventdata, handles,mode)
global weight_r
global weight_r_recon

score = weight_r(:,1);
new_value = get(handles.sliderr1,'Value');
weight_r_recon(:,1) = score * new_value;
plot_pca_subjects_right(hObject, eventdata, handles,1)

if (mode ~= 1) & (get(handles.pair_sliders,'Value') == 1)
    set(handles.sliderl1,'Value',new_value);
    sliderl1_Callback(hObject, eventdata, handles,1)
end

if (mode ~= 1) & (get(handles.play_slider_change,'Value') == 1)
play_reconstruction_Callback(hObject, eventdata, handles,2)
end


function sliderr2_Callback(hObject, eventdata, handles,mode)
global weight_r
global weight_r_recon

score = weight_r(:,2);
new_value = get(handles.sliderr2,'Value');
weight_r_recon(:,2) = score * new_value;
plot_pca_subjects_right(hObject, eventdata, handles,2)

if (mode ~= 1) & (get(handles.pair_sliders,'Value') == 1)
    set(handles.sliderl2,'Value',new_value);
    sliderl2_Callback(hObject, eventdata, handles,1)
end

if (mode ~= 1) & (get(handles.play_slider_change,'Value') == 1)
play_reconstruction_Callback(hObject, eventdata, handles,2)
end


function sliderr3_Callback(hObject, eventdata, handles,mode)
global weight_r
global weight_r_recon

score = weight_r(:,3);
new_value = get(handles.sliderr3,'Value');
weight_r_recon(:,3) = score * new_value;
plot_pca_subjects_right(hObject, eventdata, handles,3)

if (mode ~= 1) & (get(handles.pair_sliders,'Value') == 1)
    set(handles.sliderl3,'Value',new_value);
    sliderl3_Callback(hObject, eventdata, handles,1)
end

if (mode ~= 1) & (get(handles.play_slider_change,'Value') == 1)
play_reconstruction_Callback(hObject, eventdata, handles,2)
end

function sliderr4_Callback(hObject, eventdata, handles,mode)
global weight_r
global weight_r_recon

score = weight_r(:,4);
new_value = get(handles.sliderr4,'Value');
weight_r_recon(:,4) = score * new_value;
plot_pca_subjects_right(hObject, eventdata, handles,4)

if (mode ~= 1) & (get(handles.pair_sliders,'Value') == 1)
    set(handles.sliderl4,'Value',new_value);
    sliderl4_Callback(hObject, eventdata, handles,1)
end

if (mode ~= 1) & (get(handles.play_slider_change,'Value') == 1)
play_reconstruction_Callback(hObject, eventdata, handles,2)
end


function sliderr5_Callback(hObject, eventdata, handles,mode)
global weight_r
global weight_r_recon

score = weight_r(:,5);
new_value = get(handles.sliderr5,'Value');
weight_r_recon(:,5) = score * new_value;
plot_pca_subjects_right(hObject, eventdata, handles,5)

if (mode ~= 1) & (get(handles.pair_sliders,'Value') == 1)
    set(handles.sliderl5,'Value',new_value);
    sliderl5_Callback(hObject, eventdata, handles,1)
end

if (mode ~= 1) & (get(handles.play_slider_change,'Value') == 1)
play_reconstruction_Callback(hObject, eventdata, handles,2)
end


function play_reconstruction_Callback(hObject, eventdata, handles,mode)

global MEAN_SUB
global current_db
global current_azimuth
global current_elevation
global azimuth_real
global elevation_real
global DB
global ANGLES
global DATA_PHASE
global DATA_PCA_left
global DATA_PCA_right
global weight_l_recon
global weight_r_recon
global mn_l
global mn_r
global pc_l
global pc_r
global data_reconstruct_left
global data_reconstruct_right
global data_reconstruct
global fs
global hrir_db_length

reconstruct_nr = get(handles.reconstruct_nr,'Value'); % = Subject

% Get Original HRIR Datasets
row_value = get_matrixvalue(azimuth_real,elevation_real,ANGLES);  
hrir_left = squeeze(DB(reconstruct_nr,row_value,1,:));
hrir_right = squeeze(DB(reconstruct_nr,row_value,2,:));
dim = size(weight_l_recon,2);

data_reconstruct_left = reconstruct_pca(dim,weight_l_recon,pc_l,mn_l,0,0);
data_reconstruct_right = reconstruct_pca(dim,weight_r_recon,pc_r,mn_r,0,0);

data_reconstruct = zeros(size(weight_l_recon,1),size(weight_l_recon,2));

for i=1:size(weight_l_recon,1)
   data_reconstruct(2*i-1,:) = data_reconstruct_left(i,:);
   data_reconstruct(2*i,:) = data_reconstruct_right(i,:);
end


% ITD
[ ~,~,~,itd_samples] = calculate_itd(hrir_left,hrir_right);

%% HRIR ORIGINAL
% Magnitude Reconstruction of HRTF

hrtf_mag_left = squeeze(DATA_PCA_left(reconstruct_nr,:)) + squeeze(MEAN_SUB(reconstruct_nr,1,1,:))';
hrtf_mag_right = squeeze(DATA_PCA_right(reconstruct_nr,:)) + squeeze(MEAN_SUB(reconstruct_nr,1,2,:))';

% Get Original HRTF Phase
hrtf_phase_left = squeeze(DATA_PHASE(reconstruct_nr,1,1,:));
hrtf_phase_right = squeeze(DATA_PHASE(reconstruct_nr,1,2,:));

% Perform IFFT
[hrir_orig_left, hrir_orig_right] = perform_ifft(hrtf_mag_left',hrtf_mag_right',hrtf_phase_left,hrtf_phase_right,size(weight_l_recon,2));


%% HRIR RECONSTRUCTION
% Magnitude Reconstruction of HRTF

hrtf_mag_left = data_reconstruct_left(reconstruct_nr,:) + squeeze(MEAN_SUB(reconstruct_nr,1,1,:))';
hrtf_mag_right = data_reconstruct_right(reconstruct_nr,:) + squeeze(MEAN_SUB(reconstruct_nr,1,2,:))';

% Get Original HRTF Phase
hrtf_phase_left = squeeze(DATA_PHASE(reconstruct_nr,1,1,:));
hrtf_phase_right = squeeze(DATA_PHASE(reconstruct_nr,1,2,:));

% Perform IFFT
[hrir_reconstr_left, hrir_reconstr_right] = perform_ifft(hrtf_mag_left',hrtf_mag_right',hrtf_phase_left,hrtf_phase_right,size(weight_l_recon,2));

if (mode == 1)
% Play Original
play_sound([hrir_left'; hrir_right'],fs);
end

if (mode == 2)
% Play Reconstruction
play_sound([hrir_reconstr_left'; hrir_reconstr_right'],fs);
end

if (mode == 3)
% Play Original and Reconstrution
play_sound([hrir_left'; hrir_right'],fs);
pause(0.3)
play_sound([hrir_reconstr_left'; hrir_reconstr_right'],fs);
end

if (mode == 4)
% View Original and Reconstrution HRTF
N = size(weight_l_recon,2)*2;
original_hrtf_mag_l = 20*log10(2*abs(fft(hrir_left',N)));
original_hrtf_mag_l = original_hrtf_mag_l(1:ceil(N/2));
freq_l = (0 : (N/2)-1) * fs / N;

figure
plot(freq_l,original_hrtf_mag_l)
grid on
hold on
plot(freq_l,hrtf_mag_left,'r-')
hold off;
legend('Original','Reconstruction');
title(' Original HRTF and Reconstruction of Left Ear');
end


function reset_sliders_Callback(hObject, eventdata, handles)
global weight_l
global weight_r
global weight_l_recon
global weight_r_recon

weight_l_recon = weight_l;
weight_r_recon = weight_r;

set(handles.sliderl1,'Value', 1);
set(handles.sliderl2,'Value', 1);
set(handles.sliderl3,'Value', 1);
set(handles.sliderl4,'Value', 1);
set(handles.sliderl5,'Value', 1);
set(handles.sliderr1,'Value', 1);
set(handles.sliderr2,'Value', 1);
set(handles.sliderr3,'Value', 1);
set(handles.sliderr4,'Value', 1);
set(handles.sliderr5,'Value', 1);

plot_pca_subjects_left(hObject, eventdata, handles,0)
plot_pca_subjects_right(hObject, eventdata, handles,0)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in view_both.
function view_both_Callback(hObject, eventdata, handles)
% hObject    handle to view_both (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
