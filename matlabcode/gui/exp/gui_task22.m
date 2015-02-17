function varargout = gui_task22(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_task22_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_task22_OutputFcn, ...
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

% --- Executes just before gui_task22 is made visible.
function gui_task22_OpeningFcn(hObject, eventdata, handles, varargin)
global sub_id
global eq_id
global hSlider_az
global hSlider_el
global data_file
global test_sub
global test_data
global audio_output
global exp_mode

% Intit
gui_exp_mode(hObject, eventdata, handles)
[sub_id,eq_id] = init_name();  
eq_id = 0;

% config
db_name = 'ari';
inp_mode = 4;
test_sub = 1;
smooth = 128;

data_file = sprintf( '../matlabdata/experiment/data_%s/audio_output_%s_testsub%i_mode%i_sm%i_dtf_loc.mat',exp_mode,db_name,test_sub,inp_mode,smooth);

if (exist(data_file,'file') == 2)
     load(data_file,'test_data','audio_output'); 
else
    disp('ERROR on loading experiment data!')
end

set(handles.text_pos,'String',test_data.test_position_text{1})

initialize_output(hObject, eventdata, handles)
initialize_stimulus(hObject, eventdata, handles)

test_data.replays = zeros(1,length(audio_output.pc));

% Buttons
set(handles.button_play,'String','Start')
set(handles.save_pos,'Visible','Off') 
set(handles.text_pos,'Visible','Off')
set(handles.restart,'Visible','Off')

% Choose default command line output for gui_task22
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
fg1 = handles.axes_3d;
fg2 = handles.axes_az;
fg3 = handles.axes_el;

% Slider
hSlider_az = uicontrol('tag','slider_az','Style','slider','Units','pixels','Position', [315 337 250 60],'Min',-180,'Max',180,'Value', 0,'Callback',@(hObject,eventData,gui_handles) SliderData(hObject,eventData,fg1,fg2,fg3));
hListener_az = addlistener(hSlider_az,'Value','PostSet',@(hObject,eventData,gui_handles) SliderData(hObject,eventData,fg1,fg2,fg3));

hSlider_el = uicontrol('tag','slider_el','Style','slider','Units','pixels','Position', [290 160 60 170],'Min',-90,'Max',90,'Value', 0,'Callback',@(hObject,eventData,gui_handles) SliderData(hObject,eventData,fg1,fg2,fg3));
hListener_el = addlistener(hSlider_el,'Value','PostSet',@(hObject,eventData,gui_handles) SliderData(hObject,eventData,fg1,fg2,fg3));

% Initialize Figures
set(hSlider_az,'Value',1)
set(hSlider_az,'Value',0)


% Load Image
%[head1] = imread('images/HeadProfile.png');

axis_style(fg1,fg2,fg3)


function gui_exp_mode(hObject, eventdata, handles)
global exp_mode

choice = menu('Choose Experiment Mode','Test PCWs','Test SHWs');

switch(choice)
    
    case 1
    exp_mode = 'pcw';    
        
    case 2
    exp_mode = 'pcw2sh';      
end


function axis_style(fg1,fg2,fg3)

xlim(fg1,[-1 1])
ylim(fg1,[-1 1])
zlim(fg1,[-1 1])
set(fg1, 'XTick', []);
set(fg1, 'YTick', []);
set(fg1, 'ZTick', []);
set(fg1,'color','none')
set(fg1,'box','off');

xlim(fg2,[-1 1])
ylim(fg2,[-1 1])
zlim(fg2,[-1 1])
set(fg2, 'XTick', []);
set(fg2, 'YTick', []);
set(fg2, 'ZTick', []);
set(fg2,'color','none')
set(fg2,'box','off');

xlim(fg3,[-1 1])
ylim(fg3,[-1 1])
zlim(fg3,[-1 1])
set(fg3, 'XTick', []);
set(fg3, 'YTick', []);
set(fg3, 'ZTick', []);
set(fg3,'color','none')
set(fg3,'box','off');

% --- Outputs from this function are returned to the command line.
function varargout = gui_task22_OutputFcn(hObject, eventdata, handles) 
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
audio_output.pc = audio_output.pc(rand_sampl);
audio_output.play_order = audio_output.play_order(rand_sampl);
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
global model
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
%     set(handles.task2,'Backgroundcolor',[237,237,237]/255)
%     set(handles.task2,'Foregroundcolor','k')
    set(handles.save_pos,'Visible','On') 
    
    % Start Timer
    tic
    
    c = clock;
    id_string = sprintf('%i-%i-%i_%i-%i',c(1:5));
    
else
    % Track how often the subject plays a sound again
    test_data.replays(play_sample.ind) = test_data.replays(play_sample.ind) +1;
    
end

set(handles.button_play,'String','Play Again')

% Play one sound, only adapted, not reference
play_sound(squeeze(audio_output.data(play_sample.ind,audio_output.play_order(play_sample.ind),1,:))',squeeze(audio_output.data(play_sample.ind,audio_output.play_order(play_sample.ind),2,:))',1,audio_output.fs,stim,rir,eq_id,0.3,0)


function save_data(hObject, eventdata, handles)
global play_sample
global sub_id
global audio_output
global db_name
global exp_mode
global answ_task2
global test_data
global id_string

% Save Answer
% Load and Save Answer File
answ_file = sprintf( '../matlabdata/experiment/answ/answ_exp_task2_%s_sub%i_%s.mat',exp_mode,sub_id,id_string);

if (exist(answ_file,'file') == 2)
    load(answ_file);
end

%fprintf('Save Data %i\n',play_sample.ind)


answ.az(play_sample.ind) = answ_task2.az;
answ.el(play_sample.ind) = answ_task2.el;
answ.sample_ind(play_sample.ind) = play_sample.ind;
answ.pos(play_sample.ind) = audio_output.pos(play_sample.ind);
answ.pc(play_sample.ind) = audio_output.pc(play_sample.ind);
answ.play_order(play_sample.ind) = audio_output.play_order(play_sample.ind);
answ.adapt(play_sample.ind) = audio_output.adapt(play_sample.ind);
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


%--- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
global play_sample
global audio_output
global answ_task1

%disp(eventdata.Key);

if(strcmp(eventdata.Key,'s') == 1)
save_pos_Callback(hObject, eventdata, handles) 
end

if(strcmp(eventdata.Key,'a') == 1)
    button_play_Callback(hObject, eventdata, handles)
end

if(strcmp(eventdata.Key,'space') == 1)
    button_play_Callback(hObject, eventdata, handles)
end


function starttask2(hObject, eventdata, handles)
global hSlider_az
global hSlider_el
global play_sample
global audio_output

% Set Figures to 0/0
set(hSlider_az,'Value',0)
set(hSlider_el,'Value',0)

set(hSlider_az,'Backgroundcolor',[78,101,148]/255)
set(hSlider_az,'Foregroundcolor',[78,101,148]/255)


%fprintf('Start Task %i\n',play_sample.ind)

if (play_sample.ind < length(audio_output.pos))
button_next_Callback(hObject, eventdata, handles)
end



function SliderData(hObject, eventdata,fg1,fg2,fg3)
update_plot(fg1);
update_plot_az(fg2);
update_plot_el(fg3);

function update_plot(fg1)
global hSlider_az
global hSlider_el
global pos1_az
global pos1_el
global fig_mode

cla(fg1)
hold(fg1,'on');
% Sphere Grid
[X,Y,Z]=sphere(12);
x1= mesh(fg1,X,Y,Z,'CDataMapping','direct','EdgeAlpha',0.07);
alpha(x1,0.001)
rotate3d(fg1,'on')

az = [-pi:0.2:pi];
[xc,yc,zc] = sph2cart(az,zeros(size(az)),ones(size(az)));
[xc0,yc0,zc0] = sph2cart(0,0,1);

if (fig_mode == 1)
    [xt,yt,zt]=sph2cart(pos1_az/180*pi,pos1_el/180*pi,1);
    hold(fg1,'on');
    plot3(fg1,[xt],[yt],[zt] ,'-o','Markersize',14,'Markerfacecolor','g');
    hold(fg1,'on');
    plot3(fg1,[0],[0],[0] ,'-o','Markersize',10,'Markerfacecolor','g');
    hold(fg1,'on');
    plot3(fg1,[0 xt],[0 yt],[0 zt],'g--')
    
end

plot3(fg1,xc,yc,zc,'')
hold(fg1,'on');

% front
plot3(fg1,[0 xc0],[0 yc0],[0 zc0],'k-')
hold(fg1,'on');
view(fg1,-96,10)
plot3(fg1,xc0,yc0,zc0,'k>','Markersize',14,'Markerfacecolor','k');
ff = get(fg1,'parent');
%annotation(ff,'arrow',[888/1049 974/1049],[255/616 255/616])


[xt,yt,zt]=sph2cart(get(hSlider_az,'Value')/-180*pi,get(hSlider_el,'Value')/180*pi,1);
hold(fg1,'on');
plot3(fg1,[xt],[yt],[zt] ,'-o','Markersize',14,'Markerfacecolor','r');
hold(fg1,'on');
plot3(fg1,[0],[0],[0] ,'-o','Markersize',10,'Markerfacecolor','b');
hold(fg1,'on');
plot3(fg1,[0 xt],[0 yt],[0 zt],'r--')


% Axes
%axis(fg1,'equal','square')
xlim(fg1,[-1 1])
ylim(fg1,[-1 1])
zlim(fg1,[-1 1])
set(fg1, 'XTick', []);
set(fg1, 'YTick', []);
set(fg1, 'ZTick', []);
set(fg1,'color','none')
set(fg1,'box','off');

set(fg1,'visible','off')

function update_plot_az(fg2)
global hSlider_az
global pos1_az
global fig_mode

cla(fg2)

% Sphere Grid
[X,Y,Z]=sphere(12);
mesh(fg2,X,Y,zeros(size(Z)),'CDataMapping','direct','EdgeAlpha',0.07);

% Circle
az = [-pi:0.2:pi];
[xc,yc,zc] = sph2cart(az,zeros(size(az)),ones(size(az)));
[xc0,yc0,zc0] = sph2cart(0,0,1);
plot(fg2,xc,yc,'b')

if (fig_mode == 1)
   % indicate two positions 
    
   % Point
    hold(fg2,'on');
    [xt,yt,zt]=sph2cart(pos1_az/180*pi,0,1);
    plot(fg2,[0 xt],[0 yt],'g--','Markerfacecolor','k')
    plot(fg2,xt,yt ,'-o','Markersize',14,'Markerfacecolor','g');
end


% Front Marker
hold(fg2,'on');
plot(fg2,[0 xc0],[0 yc0],'--','Markerfacecolor','k')
%plot(fg2,xc0,yc0,'k>','Markersize',14,'Markerfacecolor','k');

% Point
hold(fg2,'on');
[xt,yt,zt]=sph2cart(get(hSlider_az,'Value')/180*pi,0,1);
plot(fg2,[0 xt],[0 yt],'r--','Markerfacecolor','k')
%ff = gcbf;
ff = get(fg2,'parent');
%get(ff,'Position')
annotation(ff,'arrow',[440/1049 440/1049],[497/616 583/616])
plot(fg2,xt,yt ,'-o','Markersize',14,'Markerfacecolor','r');

%Axis 
xlim(fg2,[-1 1])
ylim(fg2,[-1 1])
zlim(fg2,[-1 1])
set(fg2, 'XTick', []);
set(fg2, 'YTick', []);
set(fg2, 'ZTick', []);
set(fg2,'color','none')
set(fg2,'box','off');
view(fg2,90,270)
axis(fg2,'equal')
axis(fg2,'square')
set(fg2,'visible','off')

function update_plot_el(fg3)
global hSlider_el
global pos1_el
global fig_mode

cla(fg3)

% Sphere Grid
[X,Y,Z]=sphere(12);
mesh(fg3,X,Y,Z,'CDataMapping','direct','EdgeAlpha',0.07);


% Vertical Circle
el = [-pi:0.2:pi];
[xc,yc,zc] = sph2cart(zeros(size(el)),el,ones(size(el)));
plot3(fg3,xc,yc,zc,'b')

az = [-pi:0.2:pi];

if (fig_mode == 1)
   % indicate two positions 
    
   % Horizontal Circle
    [xc,yc,zc] = sph2cart(az,ones(size(az))*pos1_el/180*pi,ones(size(az)));
    hold(fg3,'on');
    plot3(fg3,xc,yc,zc,'g--')
end

% Horizontal Circle
[xc,yc,zc] = sph2cart(az,ones(size(az))*get(hSlider_el,'Value')/180*pi,ones(size(az)));
hold(fg3,'on');
plot3(fg3,xc,yc,zc,'r--')

% Front Marker
[xc0,yc0,zc0] = sph2cart(0,0,1);
plot3(fg3,[0 xc0],[0 yc0],[0 zc0],'--','Markerfacecolor','k')
hold(fg3,'on');
%plot3(fg3,xc0,yc0,zc0,'kv','Markersize',14,'Markerfacecolor','k');
ff = get(fg3,'parent');
annotation(ff,'arrow',[445/1049 531/1049],[245/616 245/616])

% Point
hold(fg3,'on');
[xt,yt,zt]=sph2cart(0,get(hSlider_el,'Value')/180*pi,1);
%plot3(fg3,[0 xt],[0 yt],[0 zt],'--','Markerfacecolor','k')
%hold(fg3,'on');
%plot3(fg3,xt,yt,zt ,'-o','Markersize',14,'Markerfacecolor','r');

hold(fg3,'on');
%plot3(fg3,[-xt xt],[-1 1],[zt zt],'--','Markerfacecolor','k')

% % Image
% hold(fg3,'on');
% %axes(fg3)
% %h = image([-0.1 0.1],[0.1 -0.1],head1);
% %rotate3d on

%Axis 
xlim(fg3,[-1 1])
ylim(fg3,[-1 1])
zlim(fg3,[-1 1])
set(fg3, 'XTick', []);
set(fg3, 'YTick', []);
set(fg3, 'ZTick', []);
set(fg3,'color','none')
set(fg3,'box','off');
view(fg3,0,0)
axis(fg3,'equal')
axis(fg3,'square')
set(fg3,'visible','off')

function [az,el] =ConvertAngles(az,el)

% convert  from [-180 180] to [0 360];
az = mod(-az,360);
el = el;
    

function SaveUserPos(hObject, eventdata, handles,pos_current,pos_max)
% pos_current: 1 or 2
% pos_max: user should indicate 1 or 2 positions

global hSlider_az
global hSlider_el
global answ_task2

% onyl 1 Pos, because Answer of Task1 = NO

[az,el] = ConvertAngles(get(hSlider_az,'Value'),get(hSlider_el,'Value'));
answ_task2.az = az;
answ_task2.el = el;

% Save Data
save_data(hObject, eventdata, handles)

function save_pos_Callback(hObject, eventdata, handles)
global play_sample
global audio_output

if (play_sample.ind == length(audio_output.pos))
    set(handles.button_play,'Enable','Off')
    set(handles.button_play,'String','Thank you!') 
    set(handles.save_pos,'Visible','Off') 
    set(handles.back_button,'Visible','Off') 
    set(handles.restart,'Visible','On') 
end

%fprintf('Save Button %i\n',play_sample.ind)

SaveUserPos(hObject, eventdata, handles,1,1)
starttask2(hObject, eventdata, handles)



function restart_Callback(hObject, eventdata, handles)
global sub_id
global eq_id
global test_data

% Intit
[sub_id,eq_id] = init_name();  
eq_id = 0; % no eq

set(handles.text_pos,'String',test_data.test_position_text{1})

initialize_output(hObject, eventdata, handles)
initialize_stimulus(hObject, eventdata, handles)

% Buttons
set(handles.restart,'Visible','Off')
set(handles.button_play,'String','Start')
set(handles.button_play,'Enable','on')
set(handles.save_pos,'Visible','On') 


function back_button_Callback(hObject, eventdata, handles)
