function varargout = gui_model(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_model_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_model_OutputFcn, ...
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

function gui_model_OpeningFcn(hObject, eventdata, handles, varargin)
global subject_id
global eq_id

% Choose default command line output for gui_model
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_model wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Init values on GUI startup
[subject_id,eq_id] = init_name();
set(handles.headeq,'Value', eq_id);

% Import DB
[~, db_names] = config('exp');
set(handles.select_db,'String',db_names); 
set(handles.sh_order,'Value', 2);
set(handles.bandpass,'Value', 1);
set(handles.weight_model,'Value', 2);
set(handles.signal_rep,'Value', 4);
weight_model_Callback(hObject, eventdata, handles)
select_db_Callback(hObject, eventdata, handles)

function varargout = gui_model_OutputFcn(~, ~, handles) 

varargout{1} = handles.output;

function select_db_Callback(hObject, eventdata, handles)
global calc_status
clearvars -global m
global m

calc_status = 0;
dbs = get(handles.select_db,'String');
selection = get(handles.select_db,'Value');
m.database.name = char(config_get(dbs{selection})); 
m = database_process(m);

set(handles.pc_numbers,'String',unique([1:20,30:10:100,125:25:size(m.database.hrirs,4) size(m.database.hrirs,4)]));
set(handles.pc_numbers,'Value', 10);
set(handles.position,'Value', 1);

% Show Spatial Resolution of DB
cleargui(hObject, eventdata, handles)
spatial_res(hObject, eventdata, handles)

function spatial_res(~, ~, handles)
global m

set(allchild(handles.spatial_plot),'visible','on');
axes(handles.spatial_plot)
cla

%plot a sphere with radius scale
%load('topo.mat','topo','topomap1');
[X,Y,Z]=sphere(24);

surface(X,Y,Z);
alpha(0.3)
colormap(gray)
grid on
hold on

%Markersize
if (size(m.database.angles,1) < 300)
    msize = 20;
else
    msize = 15;
end

% Convert to cartesian for plotting
r = ones(size(m.database.angles,1),1);
[xt,yt,r]=sph2cart(deg2rad(m.database.angles(:,1)),deg2rad(m.database.angles(:,2)),r);
plot3(xt,yt,r,'b.','MarkerSize',msize)
view(220,20)
rotate3d on

function cleargui(hObject, eventdata, handles)

% delete old uicontrols
set(allchild(handles.spatial_plot),'visible','off'); 
set(handles.spatial_plot,'visible','off'); 
set(handles.slider_modus,'Visible','Off')
set(handles.uitool_resetall,'Visible','Off')
set(handles.uitool_reset_active,'Visible','Off')
set(handles.uitool_save,'Visible','Off')
set(handles.uitool_load,'Visible','Off')
set(handles.uitool_midi,'Visible','Off')
set(handles.uitool_enableaudio,'Visible','Off')
set(handles.uitool_enableplot,'Visible','Off')
set(handles.uitool_enablehist,'Visible','Off')
set(handles.uitool_plot_sh,'Visible','Off')
set(handles.uitool_plot_sh_single,'Visible','Off')
set(handles.uitool_variance,'Visible','Off')

HideAudioSettings(hObject, eventdata, handles)
clearSliders(hObject, eventdata, handles)
pause(0.01)

function clearSliders(~, ~, ~)
h=findobj('style','radiobutton');
delete(h)
h=findobj('style','slider');
delete(h)
h=findobj('tag','var_text');
delete(h)
h=findobj('tag','controlpanel');
delete(h)
h=findobj('tag','cp_up');
delete(h)
h=findobj('tag','cp_down');
delete(h)
h=findobj('tag','cp_right');
delete(h)
h=findobj('tag','cp_left');
delete(h)
h=findobj('BackgroundColor',[0.6 0.6 0.6]);
delete(h)
h = findobj(findobj, '-regexp', 'Tag', '^slider_bg');
delete(h)


function calc_Callback(hObject, eventdata, handles)
global m

m.dataset = [];
m.set = [];
m.model = [];
m.weight_model = [];

rotate3d off

% delete old uicontrols
cleargui(hObject, eventdata, handles)
set(handles.uitool_calc,'Visible','Off')

status_process = uicontrol('Tag','status_process','FontSize',20,'FontWeight','Bold','ForeGroundColor', 'w','BackgroundColor','r','Style','text', 'Units','Normalized','Position',[0 0 1 1]);

% Get GUI values
all_sizes = get(handles.database_size,'String');
subjects = str2num(all_sizes{get(handles.database_size,'Value')});

all_sizes = get(handles.directions,'String');
directions = str2num(all_sizes{get(handles.directions,'Value')});

smooth_strings = get(handles.smoothing,'String');
smooth_val = str2double(smooth_strings(get(handles.smoothing,'Value')));

model_strings = get(handles.model,'String');
model_type = model_strings{get(handles.model,'Value')};

weight_model_strings = get(handles.weight_model,'String');
weight_model = weight_model_strings{get(handles.weight_model,'Value')};

% HRTF Model Parameter
m.dataset.parameter.bp_mode = get(handles.bandpass,'Value')-1;    
m.dataset.parameter.density = directions;  
m.dataset.parameter.smooth_ratio = smooth_val;
m.dataset.parameter.ears = {[1 2]}; 
m.dataset.parameter.calc_pos = 0;
m.dataset.parameter.subjects = subjects;
m.dataset.parameter.fft_size = [];

m.model.parameter.type = model_type;
m.model.parameter.ear_mode = 2;
m.model.parameter.input_mode = get(handles.signal_rep,'Value');
m.model.parameter.structure = 2;
m.model.parameter.pcs = get(handles.pc_numbers,'Value');

m.weight_model.parameter.order = get(handles.sh_order,'Value');
m.weight_model.parameter.order_initial = get(handles.sh_order,'Value');
m.weight_model.parameter.type = weight_model;
m.weight_model.parameter.regularize = 0;
    
[check_file,data_file] = check_data(m);
if (check_file == 1)
    setProcess(status_process,'Open Precalculated Data ...')  
    load(data_file);
else    
    
    % Dataset
    setProcess(status_process,'Dataset Preprocess ...')
    m = dataset_process(m);
    
    % Compute Model
    setProcess(status_process,'Compute Model ...')
    m = compute_model(m);
    m.set.subjects = 1;
    
    % Compute Weight Model
    if strcmp(m.weight_model.parameter.type,'global') 
        setProcess(status_process,'Compute Weight Model ...')
        m = compute_weight_model(m);
    end
    
    % Calc Mean Weights
    setProcess(status_process,'Compute Distribution of Weights ...')
    m = initial_weights(m);
    
    % Save Precalculated ICA Data
    save(data_file,'m','-v7.3');

end


% Calc Mean Weights
if ~isfield(m.weight_model,'sh_weights_mn')
    setProcess(status_process,'Compute Distribution of Weights ...')
    m = initial_weights(m);
end
    
m.set.subjects = 1;

% Get Position Indices for selected Trajectory
c_pos=findobj('tag','position');
[~,ind_daten] = trajectory_list(m.database.name,m.dataset.angles);
m.set.angle_ids = ind_daten{get(c_pos,'Value')};

setProcess(status_process,'Update GUI ...')
RefreshGUI(hObject, eventdata, handles)

set(handles.position,'Value',1)
set(handles.position,'String',trajectory_list(m.database.name,m.dataset.angles));
set(handles.uitool_calc,'Visible','On')
set(handles.uitool_resetall,'Visible','On')
set(handles.uitool_reset_active,'Visible','On')
set(handles.uitool_save,'Visible','On')
set(handles.uitool_load,'Visible','On')
set(handles.uitool_midi,'Visible','On')
set(handles.uitool_enableaudio,'Visible','On')
set(handles.uitool_enableplot,'Visible','On')
set(handles.uitool_enablehist,'Visible','On')
set(handles.uitool_plot_sh,'Visible','On')
set(handles.uitool_plot_sh_single,'Visible','On')
set(handles.uitool_variance,'Visible','On')

if (strcmp(get(handles.uitool_enableaudio,'State'),'on') == 1)
ShowAudioSettings(hObject, eventdata, handles)    
end

getPostion(hObject, eventdata, handles)
getSound(handles)
import_rir_list(hObject, eventdata, handles)

delete(status_process);

% Enable Audio Control Settings
ShowAudioSettings(hObject, eventdata, handles)

function RefreshGUI(hObject, eventdata, handles)
global m

status_process = uicontrol('Tag','status_process','FontSize',20,'FontWeight','Bold','ForeGroundColor', 'w','BackgroundColor','r','Style','text', 'Units','Normalized','Position',[0 0 1 1]);
setProcess(status_process,'Update GUI ...')

% Delete all SH Variance Text Layers
h = findobj(findobj, '-regexp', 'Tag', '^var_text_sh_pc');
delete(h)

% Create new sliders
slider_modus_Callback(hObject, eventdata, handles)

% Get Intial Slider Values
if strcmp(m.weight_model.parameter.type,'global') 
getSliderValuesSH(hObject)
set(handles.slider_modus,'Visible','On')
else
getSliderValuesPC(hObject)
set(handles.slider_modus,'Visible','Off')
end

% Select again previous pc or sh choice
reselectradiobuttons(hObject, eventdata, handles)


delete(status_process);

% Check Error: there should be no status process message in background
% status_process=findobj('tag','status_process');
% if (~isempty(status_process))
% delete(status_process);    
% end


function SliderPC2SH(~, ~, ~)
global m

% Create Button Group
button_group = uibuttongroup('SelectionChangeFcn', 'gui_model(''choose_pc'', gcbo, guidata(gcbo))','BackgroundColor',[0.6 0.6 0.6],'BorderType','none','Units','characters','Position',[33 0 21 36]);

% Create Buttons
posy = 365;
slid_range = str2num(get(findobj('tag','slider_range'),'String'));
var = m.model.latent/sum(m.model.latent)*100;

for pc = 1:m.model.parameter.pcs   
  
    pcno = sprintf('PC%i (%2.1f%%)',pc,var(pc));
    name_radio = sprintf('pc%i_radio',pc);
        
    posy = posy - 20;
    
    uicontrol('Tag',name_radio,'Parent',button_group,'FontSize',12,'FontWeight','normal','String',pcno,'Style','radiobutton','Units','pixels','Position', [10 posy 110 20]);
    
    posy1 = 365;
    
    if (strcmp(m.weight_model.parameter.type,'local') == 1)
    % Show PC Weights as Sliders    
    posy1 = CreateSliders_PC2SH_PCW(pc,posy1,slid_range);         
    end
    
    
    if (strcmp(m.weight_model.parameter.type,'global') == 1)
    % Show SH Weights as Sliders
    posy1 = CreateSliders_PC2SH_SHW(pc,posy1,slid_range);
    end
    
end


uicontrol('Tag','var_text','FontWeight','bold','HorizontalAlignment','Left','BackgroundColor',[0.6 0.6 0.6],'Parent',button_group,'FontSize',12,'String',sprintf('Total Variance: %2.1f%%',m.model.variance(m.model.parameter.pcs)),'Style','text','Units','pixels','Position', [10 posy-80 110 60]);


function [posy1] = CreateSliders_PC2SH_PCW(pc,posy1,slid_range)
global m

weights_mn = squeeze(m.model.weights_mn(1,m.set.angle_ids,1,pc));
weights_std = squeeze(m.model.weights_mn(1,m.set.angle_ids,1,pc));

if (size(weights_mn,2) > 1)
    % Trajectory
    weights_mn = mean(weights_mn);
    weights_std = std(weights_std);
end

name_sl = sprintf('slider%i',pc); 
posy1 = posy1-22;

% Min/Max values
min = (weights_mn-slid_range*weights_std);
max = (weights_mn+slid_range*weights_std);
val = weights_mn;

if (min > max)
    max_old = max;
    min_old = min;
    max = min_old;
    min = max_old;
end

% Create new Slider   
uicontrol('Tag',name_sl,'Backgroundcolor',[1 0 0],'Callback','gui_model(''slider_change_pc_pcw'', gcbo, guidata(gcbo))','Style','slider','Units','pixels','Position', [390 posy1 200 50],'Min',min,'Max',max,'Value', val);

function [posy1] = CreateSliders_PC2SH_SHW(pc,posy1,slid_range)
global m

for sh = 1:size(m.weight_model.sh_weights,2)
    %name_sl = sprintf('slider%i_%i',pc,sh);
    name_sl = sprintf('slider%i_%i',pc,sh);
    posy1 = posy1-22;

    slider_mn = squeeze(m.weight_model.sh_weights_mn(1,sh,1,pc));
    slider_std = squeeze(m.weight_model.sh_weights_std(1,sh,1,pc));

    % min/max values
    min = (slider_mn-slid_range*slider_std);
    max = (slider_mn+slid_range*slider_std);
    
    
    if (min > max)
    max_old = max;
    min_old = min;
    max = min_old;
    min = max_old;
    end
    
    % Check if adapted values are existent
    if isfield(m.weight_model,'sh_weights_adapt')
    % Use already adapted value    
    val = squeeze(m.weight_model.sh_weights_adapt(1,sh,1,pc));
    else
    % Use with Mean Value   
    val = slider_mn;
    end
    
     % Create new Slider 
    uicontrol('Tag',name_sl,'Backgroundcolor',[1 0 0],'Callback','gui_model(''slider_change_pc2sh'', gcbo, guidata(gcbo))','Style','slider','Units','pixels','Position', [390 posy1 200 50],'Min',min,'Max',max,'Value', val);

end


function [bcl,fcl] = get_ov_color(ov_dir)

% get color
switch (ov_dir)

    case 'left/right'
    bcl = 'g';   
    fcl = 'k';
    case 'up/down'
    bcl = 'y'; 
    fcl = 'k';
    case 'front/back'
    bcl = 'r'; 
    fcl = 'k';
    
    case 'none'
    bcl = 'k'; 
    fcl = 'w';    
    
end

function SliderSH2PC(~, ~, ~)
global m

slid_range = str2num(get(findobj('tag','slider_range'),'String'));

% Create Button Group
button_group = uibuttongroup('SelectionChangeFcn', 'gui_model(''choose_sh'', gcbo, guidata(gcbo))','BackgroundColor',[0.6 0.6 0.6],'BorderType','none','Units','characters','Position',[33 0 21 36]);

% Create Buttons
posy = 365;

for sh = 1:size(m.weight_model.sh_weights,2)    
  
    posy = posy - 20;
    shno = sprintf('SH%i',sh);
    name_radio = sprintf('sh%i_radio',sh);
      
    uicontrol('Tag',name_radio,'Parent',button_group,'FontSize',12,'FontWeight','normal','String',shno,'Style','radiobutton','Units','pixels','Position', [10 posy 110 20]);
    
   
        posy1 = 365;
        for pc = 1:m.model.parameter.pcs
        name_sl = sprintf('slider%i_%i',sh,pc);
        name_sl_bg = sprintf('slider_bg%i_%i',sh,pc);
        posy1 = posy1-22;
        
        slider_mn = squeeze(m.weight_model.sh_weights_mn(1,sh,1,pc));
        slider_std = squeeze(m.weight_model.sh_weights_std(1,sh,1,pc));
    
        % verify that value is between min/max values
        min = (slider_mn-slid_range*slider_std);
        max = (slider_mn+slid_range*slider_std);
        
        % Check if adapted values are existent
        if isfield(m.weight_model,'sh_weights_adapt')
        % Use already adapted value    
        val = squeeze(m.weight_model.sh_weights_adapt(1,sh,1,pc));
        else
        % Use with Mean Value   
        val = slider_mn;
        end
    
        % Create new Slider
        uicontrol('Tag',name_sl,'Callback','gui_model(''slider_change_sh2pc'', gcbo, guidata(gcbo))','Style','slider','Units','pixels','Position', [390 posy1 200 50],'Min',min,'Max',max,'Value', val);
        
        end
        
end

function setpc(~, ~,pc)
global m

% all Sliders invisible
h=findobj('style','slider');
set(h,'Visible','off')

% all SH Variance Text invisible
h = findobj(findobj, '-regexp', 'Tag', '^var_text_sh_pc');
set(h,'Visible','off')

% set sliders for current pc visible

switch (get(findobj('tag','weight_model'),'Value'))

    case 1
    if (get(findobj('tag','weight_model'),'Value') == 1)
    
    name_sl = sprintf('slider%i',pc);
    h=findobj('tag',name_sl);
    set (h,'Visible','On')  
    end

    
    case 2
        
    for sh=1:size(m.weight_model.sh_weights,2)
        name_sl = sprintf('slider%i_%i',pc,sh);
        h=findobj('tag',name_sl);
        set (h,'Visible','On')
    end
end


function setsh(~, ~,sh)
global m

% all Sliders invisible
h=findobj('style','slider');
set(h,'Visible','off')

% set pc sliders for current sh visible
for pc=1:m.model.parameter.pcs
    name_sl = sprintf('slider%i_%i',sh,pc);
    h=findobj('tag',name_sl);
    set (h,'Visible','On')   
end



function getSliderValuesPC(hObject,~,~)
global m
global pc_changed

% Which slider was changed?
slider = regexprep(get(hObject,'Tag'),'slider', '');
pc_changed = str2num(char(slider(1)));

% Calc PC Weights based on Slider Values
% Get Slider Values
h=findobj('style','slider');
slider_val  = get(h,'Value');
slider_val = cell2mat(slider_val);
slider_val = slider_val(end:-1:1);

m.model.weights_adapt = zeros(1,length(m.set.angle_ids),1,m.model.parameter.pcs);
m.model.weights_adapt(1,:,1,:) = repmat(slider_val,[1,length(m.set.angle_ids)])';


function getSliderValuesSH(hObject,~,~)
global m
global pc_changed

% Which slider was changed?
slider = regexprep(get(hObject,'Tag'),'slider', '');
current_val = textscan(slider,'%s','delimiter','_');
current_val = current_val{1};
pc_changed = str2num(char(current_val(1)));

% Calc SH Weights based on Slider Values
% Get Slider Values
h=findobj('style','slider');
slider_val  = get(h,'Value');
slider_val(end:-1:1);
slider_val = cell2mat(slider_val);

m.weight_model.sh_weights_adapt(1,:,1,:) = reshape(fliplr(slider_val'),size(m.weight_model.sh_weights,2),m.model.parameter.pcs);


function slider_change_pc_pcw(hObject,~,~)
global pc_changed

getSliderValuesPC(hObject)
reconstruction('adapt',0,1,pc_changed)

function slider_change_pc2sh(hObject,~,~)
global pc_changed

getSliderValuesSH(hObject)
reconstruction('adapt',0,1,pc_changed)

function slider_change_pc2sh_pca(hObject,~,~)
global pc_order
global sh_pc_number
global sh_slider_vals


% Which slider was changed?
slider = regexprep(get(hObject,'Tag'),'slider', '');
current_val = textscan(slider,'%s','delimiter','_');
current_val = current_val{1};
pc_changed = str2num(char(current_val(1)));


% Calc SH Weights based on Slider Values
% Get Slider Values
h=findobj('style','slider');
slider_val  = get(h,'Value');
slider_val(end:-1:1);
slider_val = cell2mat(slider_val);

sh_slider_vals = reshape(fliplr(slider_val'),sh_pc_number,pc_order);

ReconstructSHWeightsRC(sh_slider_vals);

reconstruction('adapt',0,1,pc_changed)


function ReconstructSHWeightsRC(sh_slider_vals)
global sh_pcs
global sh_pc_weights 
global sh_weights_rc
global pc_order
global sh_pc_number
global sh_pc_weights_rc

slider_mn = mean(sh_slider_vals);

for pc = 1:pc_order
    
    sh_pc_weights_rc = mean(sh_pc_weights{pc});
    sh_pc_weights_rc(1:sh_pc_number) = sh_slider_vals(:,pc);
    cur_sh_pcs = sh_pcs{pc};
    
    % Inverse PCA to get SH Weights
    sh_weights_rc(:,pc) = sh_pc_weights_rc(:,1:sh_pc_number) * cur_sh_pcs(:,1:sh_pc_number)';
    
end



function slider_change_sh2pc(hObject,~,~)
global m

% Which slider was changed?
slider = regexprep(get(hObject,'Tag'),'slider', '');
current_val = textscan(slider,'%s','delimiter','_');
current_val = current_val{1};
pc_changed = str2num(char(current_val(2)));

% Calc SH Weights based on Slider Values
% Get Slider Values
h=findobj('style','slider');
slider_val  = get(h,'Value');
slider_val(end:-1:1);
slider_val = cell2mat(slider_val);

m.weight_model.sh_weights_adapt(1,:,1,:) = reshape(fliplr(slider_val'),size(m.weight_model.sh_weights_adapt,4),size(m.weight_model.sh_weights_adapt,2))';

reconstruction('adapt',0,1,pc_changed)

function reconstruction(adaption_mode,sound_mode,play_reset,pc_changed)
global m


if (nargin < 4)
   pc_changed = 1; 
end

m = reconstruct_weights(m);


% Play Sound
if (sound_mode == 1)
    play_stimulus()
else
    if (get(findobj('tag','play_auto'),'Value') == 1) && (play_reset == 1)
    play_stimulus()
    end
end


% % Plot sphere with SH weights
% if (strcmp(get(findobj('tag','uitool_enableplot'),'State'),'on') == 1)
%     spherical_plot()
% end
% 
% % Plot histogram of SH weights
% if (strcmp(get(findobj('tag','uitool_enablehist'),'State'),'on') == 1)
%     spherical_histo(pc_changed)
% end
% 
% % Plot 3D SH weights (multiple windows)
% if (strcmp(get(findobj('tag','uitool_plot_sh'),'State'),'on') == 1)
%     plot_sh(sh_order,sh_weights_rc,angles,model.set.angle_ids,'multi',current_db)
% end
% 
% % Plot 3D SH weights (single window)
% if (strcmp(get(findobj('tag','uitool_plot_sh_single'),'State'),'on') == 1)
%     plot_sh(sh_order,sh_weights_rc,angles,model.set.angle_ids,'single',current_db)
% end


function play_stimulus()
global eq_id
global stim
global rir
global m

m.sound.stim = stim;
m.sound.rir = rir;
m.sound.eq_id = eq_id;
m.sound.silence = str2num(get(findobj('tag','silence_value'),'String'));
m.sound.play_mode = get(findobj('tag','play_simul'),'Value');

play_set(m);

function play_original_Callback(~, ~, ~)
global hrirs
global fs
global eq_id
global stim
global rir
global m

disp('old')
play_sound(squeeze(hrirs(ari_id,m.set.angle_ids,1,:)),squeeze(hrirs(ari_id,m.set.angle_ids,2,:)),m.set.angle_ids,fs,stim,rir,eq_id,str2num(get(findobj('tag','silence_value'),'String')),get(findobj('tag','play_simul'),'Value'))

function play_adapted_Callback(~, ~, ~)
global m

switch m.weight_model.parameter.type

    case 'global'

    % Calc SH Weights based on Slider Values
    % Get Slider Values
    h=findobj('style','slider');
    slider_val  = get(h,'Value');
    slider_val(end:-1:1);
    slider_val = cell2mat(slider_val);

    m.weight_model.sh_weights_adapt(1,:,1,:) = reshape(fliplr(slider_val'),size(m.weight_model.sh_weights,2),m.model.parameter.pcs);

    case 'local'
    % Calc PC Weights based on Slider Values
    % Get Slider Values
    h=findobj('style','slider');
    slider_val  = get(h,'Value');
    slider_val = cell2mat(slider_val);
    slider_val = slider_val(end:-1:1);

    m.model.weights_adapt = zeros(1,length(m.set.angle_ids),1,m.model.parameter.pcs);
    m.model.weights_adapt(1,:,1,:) = repmat(slider_val,[1,length(m.set.angle_ids)])';

        
end

reconstruction('adapt',1,1)




function play_generalized_Callback(~, ~, ~)
global m


% play generalized HRTF
%reconstruction('generalized',1,1)

switch m.weight_model.parameter.type

    case 'global'
    m.weight_model.sh_weights_adapt = m.weight_model.sh_weights_mn(:,:,:,1:m.model.parameter.pcs);
    case 'local'
    m.model.weights_adapt = m.model.weights_mn(:,m.set.angle_ids,:,1:m.model.parameter.pcs);   

end

m = reconstruct_weights(m);


% Play Sound
play_stimulus()




function choose_pc(hObject,eventdata,~)
global pc_active

%disp('choose_pc')
pc = regexprep(get(hObject,'Tag'),'_radio', '');
pc = regexprep(pc,'pc', '');
pc_active = str2num(pc);

setpc(hObject, eventdata,pc_active)

function choose_sh(hObject,eventdata,~)
global sh_active

sh = regexprep(get(hObject,'Tag'),'_radio', '');
sh = regexprep(sh,'sh', '');
sh_active = str2num(sh);

setsh(hObject, eventdata,sh_active)

function setProcess(status_process,text)
set(status_process,'String', sprintf('\n\n\n\n\n%s',text));
pause(0.01)



function getPostion(hObject, eventdata, handles)
global m

% Get Position Indices for selected Trajectory
c_pos=findobj('tag','position');
[~,ind_daten] = trajectory_list(m.database.name,m.dataset.angles);
m.set.angle_ids = ind_daten{get(c_pos,'Value')};


if strcmp(m.weight_model.parameter.type,'local')
   % Refresh Sliders based on selected position
   RefreshGUI(hObject, eventdata, handles) 
end


function position_Callback(hObject, eventdata, handles)

getPostion(hObject, eventdata, handles)
reconstruction('adapt',0,1)

function headeq_Callback(~, ~, handles)
global eq_id

eq_id = get(handles.headeq,'Value');



function getSound(handles)
global stim
global m

% Import other sounds
[ stim ] = import_sound(get(handles.sound,'Value'),m.database.fs);


function sound_Callback(~, ~, handles)
getSound(handles)
reconstruction('adapt',0,1)


function spherical_histo(pc_changed)
global pc_weights_rc
global m
global pc_weights

if (rem(length(m.set.angle_ids),2) == 1)
subplots = length(m.set.angle_ids) +1;
else
subplots = length(m.set.angle_ids); 
end

subp1 = subplots/2;
subp2 = subplots / subp1;

figure(4);
for pos=1:length(m.set.angle_ids)
    
    subplot(subp2,subp1,pos);
    cla;
    hist(pc_weights(:,m.set.angle_ids(pos),pc_changed))
    title(sprintf('PC %i / Az%i / El%i',pc_changed,m.dataset.angles(m.set.angle_ids(pos),1),angles(m.set.angle_ids(pos),2)))
    
    % Current Slider Value:
    hold on
    line([pc_weights_rc(m.set.angle_ids(pos),pc_changed) pc_weights_rc(m.set.angle_ids(pos),pc_changed)],get(gca,'Ylim'),'Color',[1 0 0]) 
     
end



function spherical_plot()
global pc_weights_rc
global pc_order
global m

if (rem(pc_order,2) == 1)
subplots = pc_order +1;
else
subplots = pc_order; 
end

subp1 = subplots/2;
subp2 = subplots / subp1;

[Thetas,Phis] = meshgrid(angles(:,1),angles(:,2));
[ccx,ccy,ccz] = sph2cart(Thetas/180*pi,Phis/180*pi,ones(size(Thetas)));
 
for pc=1:pc_order
    
    % ZI = griddata(angles(:,1),angles(:,2),pc_weights_rc(:,1),Thetas,Phis);
    F = TriScatteredInterp(angles(:,1),m.dataset.angles(:,2),squeeze(pc_weights_rc(:,pc)));
    ZI(pc,:,:) = F(Thetas,Phis);
    mn(pc) = squeeze(min(min(min(pc_weights_rc(:,pc))))); mx(pc) = squeeze(max(max(max(pc_weights_rc(:,pc)))));

end

figure(3);

% Add Position of current trajetory
[ccx1,ccy1,ccz1] = sph2cart(Thetas/180*pi,Phis/180*pi,ones(size(Thetas)));

ccx2 = ccx1(model.set.angle_ids,model.set.angle_ids);
ccy2 = ccy1(model.set.angle_ids,model.set.angle_ids);
ccz2 = ccz1(model.set.angle_ids,model.set.angle_ids);
    
for pc=1:pc_order
    subplot(subp2,subp1,pc);
    cla;
    % sphere
    surf(ccx,ccy,ccz,squeeze(ZI(pc,:,:)));
    title(sprintf('PC %i',pc));
    caxis([min(mn) max(mx)]);
    
    % current trajetory
    hold on    
    plot3(ccx2,ccy2,ccz2,'b.','MarkerSize',20);
    view(45,10)
    rotate3d on
    
    % arrow in front
    [xt,yt,zt] = sph2cart(0,0,1);
    plot3(xt,yt,zt,'k>','Markersize',14,'Markerfacecolor','k');

end


function reselectradiobuttons(hObject, eventdata, handles)
global pc_active
global sh_active

if (get(handles.slider_modus,'Value') == 1)
    % PC -> SH
    h = findobj('tag',sprintf('pc%i_radio',pc_active));
else
    % SH -> PC
    h = findobj('tag',sprintf('sh%i_radio',sh_active));
end

set(h,'Value',1);
   


function slider_modus_Callback(hObject, eventdata, handles)
global sh_active
global pc_active

if (isempty(sh_active) == 1)
    sh_active = 1;
end

if (isempty(pc_active) == 1)
    pc_active = 1;
end

% clear sliders and gui
clearSliders(hObject,eventdata,handles)

% create new sliders
if (get(handles.slider_modus,'Value') == 1)
    SliderPC2SH(hObject,eventdata,handles)
    setpc(hObject, eventdata,pc_active)
else
    SliderSH2PC(hObject,eventdata,handles)
    setsh(hObject, eventdata,sh_active)
end

reselectradiobuttons(hObject, eventdata, handles)

function ResetSliderSH(~, ~, ~)
global m

m.weight_model.sh_weights_adapt(1,:,1,1:m.model.parameter.pcs) = m.weight_model.sh_weights_mn(1,:,1,1:m.model.parameter.pcs);


for sh = 1:size(m.weight_model.sh_weights_adapt,2)         
    for pc = 1:size(m.weight_model.sh_weights_adapt,4)
        
    name_sl = sprintf('slider%i_%i',sh,pc); 
    h = findobj('tag',name_sl);
    set(h,'Value',squeeze(m.weight_model.sh_weights_adapt(1,sh,1,pc)));
    end
end
reconstruction('adapt',0,get(findobj('tag','play_reset'),'Value'))

function ResetSliderSH_active(~, ~, ~)
global sh_active
global m

m.weight_model.sh_weights_adapt(1,sh_active,1,1:m.model.parameter.pcs) = m.weight_model.sh_weights_mn(1,sh_active,1,1:m.model.parameter.pcs);


for pc = 1:size(m.weight_model.sh_weights_adapt,4)
    name_sl = sprintf('slider%i_%i',sh_active,pc); 
    h = findobj('tag',name_sl);
    set(h,'Value',squeeze(m.weight_model.sh_weights_adapt(1,sh_active,1,pc)));
end

reconstruction('adapt',0,get(findobj('tag','play_reset'),'Value'))


function ResetSliderPC_PCW(hObject, eventdata, handles)

% weights_mn = squeeze(model.weights_mn(1,model.set.angle_ids,1,1:model.parameter.pcs));
% 
% if (size(weights_mn,2) > 1)
%     % Trajectory
%     weights_mn = mean(weights_mn);
% end


RefreshGUI(hObject, eventdata, handles)

% model.weights_adapt(1,:,1,:) = repmat(weights_mn,size(model.set.angle_ids,1),1);

reconstruction('adapt',0,get(findobj('tag','play_reset'),'Value'))

function ResetSliderPC_ICW(hObject, eventdata, handles)
RefreshGUI(hObject, eventdata, handles)
reconstruction('adapt',0,get(findobj('tag','play_reset'),'Value'))

function ResetSliderPC_NNMF(hObject, eventdata, handles)
RefreshGUI(hObject, eventdata, handles)
reconstruction('adapt',0,get(findobj('tag','play_reset'),'Value'))


function ResetSliderPC_active_NNMF(hObject, eventdata, handles)
global nnmf_weights
global nnmf_weights_rc
global pc_active

nnmf_weights_rc(pc_active) = mean(nnmf_weights(:,pc_active));

name_sl = sprintf('slider%i',pc_active);
h = findobj('tag',name_sl);
set(h,'Value',nnmf_weights_rc(pc_active));

reconstruction('adapt',0,get(findobj('tag','play_reset'),'Value'))


function ResetSliderPC_active_ICW(hObject, eventdata, handles)
global ic_weights
global ic_weights_rc
global pc_active

ic_weights_rc(pc_active) = mean(ic_weights(:,pc_active));

name_sl = sprintf('slider%i',pc_active);
h = findobj('tag',name_sl);
set(h,'Value',ic_weights_rc(pc_active));

reconstruction('adapt',0,get(findobj('tag','play_reset'),'Value'))

function ResetSliderPC_active_PCW(hObject, eventdata, handles)
global pc_active
global m

weights_mn = squeeze(m.model.weights_mn(1,m.set.angle_ids,1,pc_active));

if (size(weights_mn,2) > 1)
    % Trajectory
    weights_mn = mean(weights_mn);
end

name_sl = sprintf('slider%i',pc_active);
h = findobj('tag',name_sl);
set(h,'Value',weights_mn);

m.model.weights_adapt(1,:,1,pc_active) = repmat(weights_mn,size(m.set.angle_ids,1),1);

reconstruction('adapt',0,get(findobj('tag','play_reset'),'Value'))


function ResetSliderPC_SHW(~, ~, ~)
global m

m.weight_model.sh_weights_adapt(:,:,:,1:m.model.parameter.pcs) = m.weight_model.sh_weights_mn(:,:,:,1:m.model.parameter.pcs);

for pc = 1:size(m.weight_model.sh_weights_adapt,4)         
    
    for sh = 1:size(m.weight_model.sh_weights_adapt,2)
        
    name_sl = sprintf('slider%i_%i',pc,sh); 
    h = findobj('tag',name_sl);
    set(h,'Value',squeeze(m.weight_model.sh_weights_adapt(:,sh,:,pc)));

    end
end
reconstruction('adapt',0,get(findobj('tag','play_reset'),'Value'))

function ResetSliderPC_SHWPCA(~, ~, ~)
global sh_pc_weights_original
global sh_pc_number
global sh_slider_vals

for pc = 1:size(sh_pc_weights_original,2)         
    for sh = 1:sh_pc_number
        
    name_sl = sprintf('slider%i_%i',pc,sh); 
    h = findobj('tag',name_sl);
    set(h,'Value',sh_pc_weights_original(sh,pc));

    end
end

sh_slider_vals = sh_pc_weights_original;
ReconstructSHWeightsRC(sh_slider_vals)

reconstruction('adapt',0,get(findobj('tag','play_reset'),'Value'))


function ResetSliderPC_active_SHW(~, ~, ~)
global pc_active
global m

m.weight_model.sh_weights_adapt(:,:,:,pc_active) = m.weight_model.sh_weights_mn(:,:,:,pc_active);
        
for sh = 1:size(m.weight_model.sh_weights_adapt,2)
    name_sl = sprintf('slider%i_%i',pc_active,sh); 
    h = findobj('tag',name_sl);
    set(h,'Value',squeeze(m.weight_model.sh_weights_adapt(:,sh,:,pc_active)));
end


reconstruction('adapt',0,get(findobj('tag','play_reset'),'Value'))

function ResetSliderPC_active_SHWPCA(~, ~, ~)
global pc_active
global sh_pc_weights_original
global sh_pc_number
global sh_slider_vals
global sh_pc_number
global sh_slider_vals


for sh = 1:sh_pc_number
    name_sl = sprintf('slider%i_%i',pc_active,sh); 
    h = findobj('tag',name_sl);
    set(h,'Value',sh_pc_weights_original(sh,pc_active));
end

sh_slider_vals(:,pc_active) = sh_pc_weights_original(:,pc_active);
ReconstructSHWeightsRC(sh_slider_vals)

reconstruction('adapt',0,get(findobj('tag','play_reset'),'Value'))


function LoadSHValues(~, ~, handles)
global subject_id
global m

sh_file = sprintf('../matlabdata/experiment/sh_values_%s_%i_%i.mat',m.database.name,subject_id,get(handles.position,'Value'));

if (exist(sh_file,'file') == 2)
    load(sh_file);
    
    % Get Slider Min/Max Values to prevent GUI Error when loaded values are outside the range    
    [tableMin,tableMax] = GetMinMaxValues();
    [m.weight_model.sh_weights_adapt] = updateSHValues(weights_save,m.weight_model.sh_weights_adapt);

    % Adapt if necessary
    for sh=1:size(m.weight_model.sh_weights_adapt,2)
       for pc=1:size(m.weight_model.sh_weights_adapt,4)
       
       % Min
       if (m.weight_model.sh_weights_adapt(1,sh,1,pc) < tableMin(sh,pc))
           m.weight_model.sh_weights_adapt(1,sh,1,pc) = tableMin(sh,pc);
       end
          
       % Max
       if (m.weight_model.sh_weights_adapt(1,sh,1,pc) > tableMax(sh,pc))
           m.weight_model.sh_weights_adapt(1,sh,1,pc) = tableMax(sh,pc);
       end
       
               
       end
        
    end
    
end

SetSHValues()


function [tableMin,tableMax] = GetMinMaxValues()
global m

slider_modus=findobj('tag','slider_modus');

if (get(slider_modus,'Value') == 1)
    % PC -> SH
    
    for pc = 1:size(m.weight_model.sh_weights_adapt,4)         
    for sh = 1:size(m.weight_model.sh_weights_adapt,2)
        
    name_sl = sprintf('slider%i_%i',pc,sh);
    h = findobj('tag',name_sl);
    tableMin(sh,pc) = get(h,'Min');
    tableMax(sh,pc) = get(h,'Max');

    end
    end

else
    % SH -> PC
    
    for sh = 1:size(m.weight_model.sh_weights_adapt,2)         
    for pc = 1:size(m.weight_model.sh_weights_adapt,4)
        
    name_sl = sprintf('slider%i_%i',sh,pc);     
    h = findobj('tag',name_sl);
    tableMin(sh,pc) = get(h,'Min');
    tableMax(sh,pc) = get(h,'Max');

    end
    end

end


function SetSHValues()
global m

slider_modus=findobj('tag','slider_modus');

if (get(slider_modus,'Value') == 1)
    % PC -> SH
    
    for pc = 1:size(m.weight_model.sh_weights_adapt,4)         
    for sh = 1:size(m.weight_model.sh_weights_adapt,2)
        
    name_sl = sprintf('slider%i_%i',pc,sh);
    h = findobj('tag',name_sl);
    set(h,'Value',m.weight_model.sh_weights_adapt(1,sh,1,pc));

    end
    end

else
    % SH -> PC
    
    for sh = 1:size(m.weight_model.sh_weights_adapt,2)         
    for pc = 1:size(m.weight_model.sh_weights_adapt,4)
        
    name_sl = sprintf('slider%i_%i',sh,pc); 
    h = findobj('tag',name_sl);
    set(h,'Value',m.weight_model.sh_weights_adapt(1,sh,1,pc));

    end
    end

end

function SaveSHValues(~, ~, handles)
global subject_id
global m

weights_save = m.weight_model.sh_weights_adapt;
save(sprintf('../matlabdata/experiment/sh_values_%s_%i_%i.mat',m.database.name,subject_id,get(handles.position,'Value')),'weights_save');

function uitool_calc_ClickedCallback(hObject, eventdata, handles)
calc_Callback(hObject, eventdata, handles)

function uitool_load_ClickedCallback(hObject, eventdata, handles)
global m

if strcmp(m.weight_model.parameter.type,'global')
    LoadSHValues(hObject, eventdata, handles)
else
    
end



function uitool_save_ClickedCallback(hObject, eventdata, handles)
global m

if strcmp(m.weight_model.parameter.type,'global')
    SaveSHValues(hObject, eventdata, handles)
else
    
end

function uitool_resetall_ClickedCallback(hObject, eventdata, handles)
global m

if strcmp(m.weight_model.parameter.type,'local')
    
    ResetSliderPC_PCW(hObject, eventdata, handles)
     
else
    if (get(handles.slider_modus,'Value') == 1)
    ResetSliderPC_SHW(hObject, eventdata, handles)
    end
    
    if (get(handles.slider_modus,'Value') == 2)
    ResetSliderSH(hObject, eventdata, handles)
    end
end




% if (get(handles.slider_modus,'Value') == 1)
% 
%     if (get(handles.weight_model,'Value') == 1)
%     ResetSliderPC_PCW(hObject, eventdata, handles)
%     end
%     
%     if (get(handles.weight_model,'Value') == 2)
%     ResetSliderPC_SHW(hObject, eventdata, handles)
%     end
%     
%     
% else
%     ResetSliderSH(hObject, eventdata, handles)
% end
    
function uitool_reset_active_ClickedCallback(hObject, eventdata, handles)
global m

if strcmp(m.weight_model.parameter.type,'local')
    
    ResetSliderPC_active_PCW(hObject, eventdata, handles)
     
else
    if (get(handles.slider_modus,'Value') == 1)
    ResetSliderPC_active_SHW(hObject, eventdata, handles)
    end
    
    if (get(handles.slider_modus,'Value') == 2)
    ResetSliderSH_active(hObject, eventdata, handles)
    end
end


function uitool_midi_OffCallback(~, ~, ~)

function uitool_midi_OnCallback(~, ~, ~)

% t = timer('TimerFcn', 'stat=false; disp(''Timer!'')',... 
%                  'StartDelay',10);
% start(t)
% 
% stat=true;
% while(stat==true)
% 
%   
%   [ctlnum devname] = midiid
%   
%   pause(1)
% end
% 
% 
% delete(t) 

% try simulink:
%ex_simplemidi

function uitool_enableplot_OffCallback(~, ~, ~)

if (ishandle(3)==1)
   close(3) 
end

function uitool_enableplot_OnCallback(~, ~, ~)
reconstruction('adapt',0,1)

function uitool_enableaudio_OffCallback(hObject, eventdata, handles)
HideAudioSettings(hObject, eventdata, handles)

function uitool_enableaudio_OnCallback(hObject, eventdata, handles)
ShowAudioSettings(hObject, eventdata, handles)

function ShowAudioSettings(~, ~, handles)
global current_db
global excluded_hrtf

set(handles.back_sound,'Visible','On')
set(handles.play_adapted,'Visible','On')
set(handles.play_generalized,'Visible','On')
set(handles.position,'Visible','On')
set(handles.text_pos,'Visible','On')
set(handles.text_headeq,'Visible','On')
set(handles.headeq,'Visible','On')
set(handles.text_sound,'Visible','On')
set(handles.sound,'Visible','On')
set(handles.rir,'Visible','On')
set(handles.rir_text,'Visible','On')
set(handles.play_auto,'Visible','On')
set(handles.play_simul,'Visible','On')
set(handles.play_reset,'Visible','On')
set(handles.silence_value,'Visible','On')
set(handles.text_pause,'Visible','On')

if (~isempty(strfind(current_db,'ari'))) && (excluded_hrtf == 0)
    set(handles.play_original,'Visible','On')
    set(handles.my_solution,'Visible','On')
end

function HideAudioSettings(~, ~, handles)
set(handles.back_sound,'Visible','Off')
set(handles.play_original,'Visible','Off')
set(handles.my_solution,'Visible','Off')
set(handles.play_adapted,'Visible','Off')
set(handles.play_generalized,'Visible','Off')
set(handles.position,'Visible','Off')
set(handles.text_pos,'Visible','Off')
set(handles.text_headeq,'Visible','Off')
set(handles.headeq,'Visible','Off')
set(handles.text_sound,'Visible','Off')
set(handles.sound,'Visible','Off')
set(handles.rir,'Visible','Off')
set(handles.rir_text,'Visible','Off')
set(handles.play_auto,'Visible','Off')
set(handles.play_simul,'Visible','Off')
set(handles.play_reset,'Visible','Off')
set(handles.silence_value,'Visible','Off')
set(handles.text_pause,'Visible','Off')


function uitool_enablehist_OffCallback(~, ~, ~)
if (ishandle(4)==1)
   close(4) 
end

function uitool_enablehist_OnCallback(~, ~, ~)
reconstruction('adapt',0,1)


function my_solution_Callback(~, ~, ~)
global sh_weights
global sh_weights_rc
global ari_id

sh_weights_rc = squeeze(sh_weights(ari_id,:,:));
SetSHValues()
reconstruction('adapt',0,1)


function uitool_plot_sh_OffCallback(~, ~, ~)
global pc_order

for i=10:10+pc_order
    if (ishandle(i)==1)
       close(i) 
    end
end

function uitool_plot_sh_OnCallback(~, ~, ~)
reconstruction('adapt',0,1)


function uitool_variance_OffCallback(~, ~, ~)
if (ishandle(30)==1)
   close(30) 
end


function uitool_variance_OnCallback(~, ~, ~)
showVariance()

function showVariance()
global pc_weights_rc
global sh_weights_rc
global pc_order
global m

total_var = 0;

% for pc=1:pc_order
%     total_var = total_var + latent(pc);
%     var1(pc) = total_var;
%     var2(pc) = latent(pc);
% end

% for pc = 1:pc_order
%     disp(sprintf('PC:%d,%.3f,%.3f',pc, min(min(squeeze(pc_weights(:,:,pc)))), max(max(squeeze(pc_weights(:,:,pc)))) ));    
% end

% 
% figure(30)
% subplot(3,1,1)
% plot(var1/sum(latent)*100,'r')
% title('Variance of PCs')
% grid on
% hold on
% bar(var2/sum(latent)*100)
% 
% subplot(3,1,2)
% hist(model.)
% title('PC Weights')
% grid on
% 
% subplot(3,1,3)
% hist(squeeze(model.weight_model.sh_weights_adapted(1,:,1,:)))
% title('Sh Weights')
% grid on

function uitool_plot_sh_single_OffCallback(hObject, eventdata, handles)
if (ishandle(40)==1)
   close(40) 
end

function uitool_plot_sh_single_OnCallback(hObject, eventdata, handles)
reconstruction('adapt',0,1)



function weight_model_Callback(hObject, eventdata, handles)

% Set Slider range and GUI elements

if(get(handles.weight_model,'Value') == 1)
    set(handles.sh_order_text,'Visible','Off')
    set(handles.sh_order,'Visible','Off')
    set(handles.slider_range,'String',3)
end

if(get(handles.weight_model,'Value') == 2)
    set(handles.sh_order_text,'Visible','On')
    set(handles.sh_order,'Visible','On')
    set(handles.slider_range,'String',10)
end


% if (refresh == 1)
% RefreshGUI(hObject, eventdata, handles)
% end


function import_rir_list(hObject, eventdata, handles)
global rir_files

% Detect all wav files
files = dir('sounds/rir/*.wav');
rir_files = {files.name};

menu_values = 'none';
for i=1:length(rir_files)
    menu_values = sprintf('%s|%s',menu_values,strrep(rir_files{i},'.wav',''));
end
set(handles.rir,'String',menu_values); 

function rir_Callback(hObject, eventdata, handles)
global rir
global fs
global rir_files

% Import other rirs
rir = import_rir(get(handles.rir,'Value'),rir_files,fs);

reconstruction('adapt',0,1)

function pc_numbers_Callback(hObject, eventdata, handles)

% if (get(handles.algo,'Value') == 1)   
% RefreshGUI(hObject, eventdata, handles)    
% end


% --- Executes on selection change in model.
function model_Callback(hObject, eventdata, handles)
% hObject    handle to model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns model contents as cell array
%        contents{get(hObject,'Value')} returns selected item from model


% --- Executes during object creation, after setting all properties.
function model_CreateFcn(hObject, eventdata, handles)
% hObject    handle to model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
