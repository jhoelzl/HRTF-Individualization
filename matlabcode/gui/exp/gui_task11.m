function varargout = gui_task11(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_task11_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_task11_OutputFcn, ...
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

% --- Executes just before gui_task11 is made visible.
function gui_task11_OpeningFcn(hObject, eventdata, handles, varargin)
global sub_id
global eq_id
global exp_mode
global db_name
global data_file
global test_data
global audio_output
global smooth

% Intit
gui_exp_mode(hObject, eventdata, handles)
[sub_id,eq_id] = init_name();  
eq_id = 0; % no eq

% config
%init_smooth(hObject, eventdata, handles)
db_name = 'ari';
inp_mode = 4;
test_sub = 1;
smooth = 128;

data_file = sprintf( '../matlabdata/experiment/data_%s/audio_output_%s_testsub%i_mode%i_sm%i_dtf_dis.mat',exp_mode,db_name,test_sub,inp_mode,smooth);

if (exist(data_file,'file') == 2)
     load(data_file,'test_data','audio_output'); 
else
    disp('ERROR on loading experiment data!')
end

test_data.inp_mode = inp_mode;
test_data.test_sub = test_sub;
test_data.smooth = smooth;

set(handles.text_pos,'String',test_data.test_position_text{1})

initialize_output(hObject, eventdata, handles)
initialize_stimulus(hObject, eventdata, handles)

test_data.replays = zeros(1,length(audio_output.pc));

% Buttons
set(handles.button_play,'String','Start')
set(handles.answ_yes,'Enable','Off') 
set(handles.answ_no,'Enable','Off') 
set(handles.text_pos,'Visible','Off') % choose for analyzing or testing
set(handles.restart,'Visible','Off')

% Choose default command line output for gui_task11
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);



function gui_exp_mode(hObject, eventdata, handles)
global exp_mode

choice = menu('Choose Experiment Mode','Test PCWs','Test SHWs');

switch(choice)
    case 1
    exp_mode = 'pcw';    
        
    case 2
    exp_mode = 'pcw2sh';      
end


function init_smooth(hObject, eventdata, handles)
global smooth

choice = menu('Choose Smoothing Rate','No','256','128','64','32','16');

switch(choice)
    case 1
    smooth = 0;  
    
    case 2
    smooth = 256;  
    
    case 3
    smooth = 128;  
    
    case 4
    smooth = 64;  
    
    case 5
    smooth = 32;  
    
    case 6
    smooth = 16;     
           
end


% --- Outputs from this function are returned to the command line.
function varargout = gui_task11_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function initialize_stimulus(~, ~, handles)
global stim
global rir
global audio_output

% Import other sounds
stim = import_sound(7,audio_output.fs);
rir = 1;           

function selectpos(hObject, eventdata, handles,num)
global play_sample

% next or prev
play_sample.ind = play_sample.ind + num;

% Update GUI
UpdateGuiInfos(hObject, eventdata, handles)

function UpdateGuiInfos(hObject, eventdata, handles)
global test_data
global play_sample
global audio_output
global exp_mode

play_sample.pos_count = find(test_data.test_position_ind == audio_output.pos(play_sample.ind));

% Update GUI
set(handles.text_count,'String',sprintf('%i / %i',play_sample.ind,length(audio_output.pos)))

if (strcmp(exp_mode,'pcw2sh') == 1)
admin_string = sprintf('Pos: %s, PC%i, SH:%i, Adapt: %.2f, Perc: %i',test_data.test_position_text{play_sample.pos_count},audio_output.pc(play_sample.ind),audio_output.sh(play_sample.ind),audio_output.adapt(play_sample.ind),audio_output.perc(play_sample.ind));
else
admin_string = sprintf('Pos: %s, PC%i, Adapt: %.2f, Perc: %i',test_data.test_position_text{play_sample.pos_count},audio_output.pc(play_sample.ind),audio_output.adapt(play_sample.ind),audio_output.adapt_perc(play_sample.ind));    
end

%set(handles.text_pos,'Visible','On')

set(handles.text_pos,'String',admin_string);


function initialize_output(hObject, eventdata, handles)
global play_sample
global audio_output
global exp_mode

% Random Mixing of Sound Samples
rand_sampl = randperm(length(audio_output.pc));
audio_output.data = audio_output.data(rand_sampl,:,:,:);
audio_output.play_order = audio_output.play_order(rand_sampl);
audio_output.pc = audio_output.pc(rand_sampl);
audio_output.pos = audio_output.pos(rand_sampl);
audio_output.adapt = audio_output.adapt(rand_sampl);
audio_output.adapt_perc = audio_output.adapt_perc(rand_sampl);

if (strcmp(exp_mode,'pcw2sh') == 1)
audio_output.sh = audio_output.sh(rand_sampl);
end

% Initialize GUI
play_sample.ind = 1;

% Update GUI
UpdateGuiInfos(hObject, eventdata, handles)

function button_next_Callback(hObject, eventdata, handles)
selectpos(hObject, eventdata, handles,1)
button_play_Callback(hObject, eventdata, handles)


function button_play_Callback(hObject, eventdata, handles)
global audio_output
global stim
global rir
global eq_id
global play_sample
global id_string
global test_data

if (strcmp(get(handles.button_play,'String'),'Start') == 1)
    
    % Colors, Buttons
    %set(handles.task1,'Backgroundcolor','r')
    set(handles.task1,'Backgroundcolor',[78,101,148]/255)
    set(handles.task1,'Foregroundcolor','w')
    set(handles.answ_yes,'Enable','On')
    set(handles.answ_no,'Enable','On')

    % Start Timer
    tic
    c = clock;
    id_string = sprintf('%i-%i-%i_%i-%i',c(1:5));
else
    
    % Track how often the subject plays a sound again
    test_data.replays(play_sample.ind) = test_data.replays(play_sample.ind) +1;
end

set(handles.button_play,'String','Play Again (space)')

% Play sound
play_sound(squeeze(audio_output.data(play_sample.ind,:,1,:)),squeeze(audio_output.data(play_sample.ind,:,2,:)),1:size(audio_output.data,2),audio_output.fs,stim,rir,eq_id,0.3,0)

function save_data(hObject, eventdata, handles)
global play_sample
global sub_id
global audio_output
global test_data
global db_name
global exp_mode
global answ_task1
global id_string

% Save Answer
% Load and Save Answer File
answ_file = sprintf( '../matlabdata/experiment/answ/answ_exp_task1_%s_sub%i_%s.mat',exp_mode,sub_id,id_string);

if (exist(answ_file,'file') == 2)
    load(answ_file);
end

answ.answ_task1(play_sample.ind) = answ_task1;
answ.sample_ind(play_sample.ind) = play_sample.ind;
answ.pos(play_sample.ind) = audio_output.pos(play_sample.ind);
answ.pc(play_sample.ind) = audio_output.pc(play_sample.ind);
answ.adapt(play_sample.ind) = audio_output.adapt(play_sample.ind);
answ.play_order(play_sample.ind) = audio_output.play_order(play_sample.ind);
answ.adapt_perc(play_sample.ind) = audio_output.adapt_perc(play_sample.ind);
answ.perc_data = audio_output.perc_data;
answ.perc = audio_output.perc;
answ.db = db_name;
answ.test_data = test_data;

if (strcmp(exp_mode,'pcw2sh') == 1)
answ.sh(play_sample.ind) = audio_output.sh(play_sample.ind);    
end

if (play_sample.ind == length(audio_output.pos))
answ.time = toc;
end

save(answ_file,'answ');

function figure1_KeyPressFcn(hObject, eventdata, handles)
global play_sample
global audio_output
global answ_task1

%disp(eventdata.Key);

if(strcmp(eventdata.Key,'y') == 1)
  answ_yes_Callback(hObject, eventdata, handles)

end

if(strcmp(eventdata.Key,'n') == 1)
   answ_no_Callback(hObject, eventdata, handles)
    
end

if(strcmp(eventdata.Key,'a') == 1)
    %disp('again')
    button_play_Callback(hObject, eventdata, handles)
end

if(strcmp(eventdata.Key,'space') == 1)
    %disp('again')
    button_play_Callback(hObject, eventdata, handles)
end



function answ_yes_Callback(hObject, eventdata, handles)
global answ_task1
global play_sample
global audio_output

answ_task1 = 1;
set(handles.answ_yes,'Enable','Off') 
set(handles.answ_no,'Enable','Off') 

% Save Data
save_data(hObject, eventdata, handles)

if (play_sample.ind == length(audio_output.pos))
    set(handles.button_play,'Enable','Off')
    set(handles.button_play,'String','Thank you!')
    set(handles.answ_yes,'Enable','Off')
    set(handles.answ_no,'Enable','Off') 
    set(handles.task1,'Backgroundcolor',[237,237,237]/255)
    set(handles.task1,'Foregroundcolor','k')  
    set(handles.restart,'Visible','On')
else
    % Next Sound
    starttask1(hObject, eventdata, handles)
end



function answ_no_Callback(hObject, eventdata, handles)
global answ_task1
global play_sample
global audio_output

answ_task1 = 0;
set(handles.answ_yes,'Enable','Off') 
set(handles.answ_no,'Enable','Off') 

% Save Data
save_data(hObject, eventdata, handles)

if (play_sample.ind == length(audio_output.pos))
    set(handles.button_play,'Enable','Off')
    set(handles.button_play,'String','Thank you!')
    set(handles.answ_yes,'Enable','Off')
    set(handles.answ_no,'Enable','Off') 
    set(handles.task1,'Backgroundcolor',[237,237,237]/255)
    set(handles.task1,'Foregroundcolor','k')  
    set(handles.restart,'Visible','On')
    
else
    % Next Sound
    starttask1(hObject, eventdata, handles)
end


function starttask1(hObject, eventdata, handles)
global play_sample
global audio_output

%set(handles.task1,'Backgroundcolor','r')
set(handles.task1,'Backgroundcolor',[78,101,148]/255)
set(handles.task1,'Foregroundcolor','w')
set(handles.answ_yes,'Enable','On')
set(handles.answ_no,'Enable','On')

if (play_sample.ind < length(audio_output.pos))
button_next_Callback(hObject, eventdata, handles)
end


function restart_Callback(hObject, eventdata, handles)
global sub_id
global eq_id
global test_data

% Intit
[sub_id,eq_id] = init_name();  
eq_id = 0; % no eq

% Buttons
set(handles.restart,'Visible','Off')
set(handles.button_play,'String','Start')
set(handles.answ_yes,'Enable','Off') 
set(handles.answ_no,'Enable','Off') 
%set(handles.text_pos,'Visible','Off') % choose for analyzing or testing

set(handles.text_pos,'String',test_data.test_position_text{1})

initialize_output(hObject, eventdata, handles)
initialize_stimulus(hObject, eventdata, handles)

set(handles.button_play,'String','Start')
set(handles.button_play,'Enable','on')
