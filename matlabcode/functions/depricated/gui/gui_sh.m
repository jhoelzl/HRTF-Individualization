function varargout = gui_sh(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_sh_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_sh_OutputFcn, ...
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

function gui_sh_OpeningFcn(hObject, eventdata, handles, varargin)
global subject_id
global ari_id
global eq_id

% Choose default command line output for gui_sh
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_sh wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Init values on GUI startup
[subject_id,eq_id,ari_id] = init_name();
set(handles.headeq,'Value', eq_id);

% Import DB
[~, db_names] = config('exp');
set(handles.select_db,'String',db_names); 
set(handles.sh_order,'Value', 2);
set(handles.pca_of_shws_pcs,'Value', 4);
set(handles.adapt_mode,'Value', 2);
adapt_mode_Callback(hObject, eventdata, handles)

select_db_Callback(hObject, eventdata, handles)

function varargout = gui_sh_OutputFcn(~, ~, handles) 

varargout{1} = handles.output;

function select_db_Callback(hObject, eventdata, handles)
global hrirs
global angles
global hrir_db_length
global fs
global current_db
global calc_status
global ari_id
global subject_ids
global excluded_hrtf

calc_status = 0;
dbs = get(handles.select_db,'String');
selection = get(handles.select_db,'Value');
current_db = char(config_get(dbs{selection}));

[hrirs,subject_ids,~,angles,~,hrir_db_length,~,~,~,~,fs,exp_sub] = db_import(current_db);

if (isempty(strfind(current_db,'ari')) == 0) && (ari_id ~= 0)
set(handles.include_own,'visible','on'); 
set(handles.include_own,'Value',0);
excluded_hrtf = 0;
else
set(handles.include_own,'visible','off');   
excluded_hrtf = 1;
end

set(handles.database_size,'String', exp_sub);
set(handles.database_size,'Value', length(exp_sub));
set(handles.pc_numbers,'String',[1:20,30:10:size(hrirs,4) size(hrirs,4)]);
set(handles.pc_numbers,'Value', 5);

set(handles.position,'Value', 1);

% Show Spatial Resolution of DB
cleargui(hObject, eventdata, handles)
spatial_res(hObject, eventdata, handles)

function spatial_res(~, ~, handles)
global angles

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
if (size(angles,1) < 300)
    msize = 20;
else
    msize = 15;
end

% Convert to cartesian for plotting
r = ones(size(angles,1),1);
[xt,yt,r]=sph2cart(angles(:,1),angles(:,2),r);
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
global hrirs
global current_db
global angles
clearvars -global pca_in pca_mean pcs pc_weights pc_weights_rc sh_weights sh_weights_rc sha shb e hrir_reconstr_left hrir_reconstr_right
global pc_weights
global pca_mean
global freq_mode
global pcs
global latent
global pca_in
global calc_status
global ari_id
global excluded_hrtf
global subjects
global fs
global ics
global ic_weights
rotate3d off

% delete old uicontrols
cleargui(hObject, eventdata, handles)
set(handles.uitool_calc,'Visible','Off')

status_process = uicontrol('Tag','status_process','FontSize',20,'FontWeight','Bold','ForeGroundColor', 'w','BackgroundColor','r','Style','text', 'Units','Normalized','Position',[0 0 1 1]);

% Get GUI values
all_sizes = str2num(get(handles.database_size,'String'));
subjects = all_sizes(get(handles.database_size,'Value'));
if (size(hrirs,1) > subjects)
    subjects = size(hrirs,1);
end

smooth_strings = (get(handles.smoothing,'String'));
smooth_strings(1,:) = {'0'};
smooth_val = str2double(smooth_strings(get(handles.smoothing,'Value')));

% Remove own HRTF from Database
if (isempty(strfind(current_db,'ari')) == 0) && (get(handles.include_own,'Value') == 0)
    sub_id_excl = ari_id;
    excluded_hrtf = 1;  
    subjects = subjects-1;
else
    excluded_hrtf = 0;
    sub_id_excl = 0;
end


db_precalculated = 0;
freq_mode = 2;

if (excluded_hrtf ==1)
db_file = sprintf('../matlabdata/db_pcs/pc_%s_sub%i_freqmode%i_smooth%i_%i_ex%i.mat',current_db,subjects,freq_mode,smooth_val,get(handles.pca_ica,'Value'),ari_id);
else
db_file = sprintf('../matlabdata/db_pcs/pc_%s_sub%i_freqmode%i_smooth%i_%i.mat',current_db,subjects,freq_mode,smooth_val,get(handles.pca_ica,'Value'));  
end

if (exist(db_file,'file') == 2)
setProcess(status_process,'Open Precalculated Data ...')    
load(db_file);
db_precalculated = 1;
end


% db_precalculated = 0; %for testing


if (db_precalculated == 0)
    
    if (get(handles.pca_ica,'Value') == 1)
        
    % PCA Input Matrix
    setProcess(status_process,'PCA Input Matrix ...')
    [pca_in,pca_mean] = pca_in2(hrirs,2,3,freq_mode,1:subjects,1:size(hrirs,2),0,0,size(hrirs,4),smooth_val,sub_id_excl,fs);
    
    
    % PCA
    setProcess(status_process,'PCA ...')
    [pcs,pc_weights,latent] = princomp(pca_in,'econ'); % both ears
    
    % Weights for Left and Right Ear
    pc_weights = reshape(pc_weights,[subjects,size(hrirs,2),size(hrirs,4)]);
    
    % Save Precalculated PCA Data
    save(db_file,'pcs','pc_weights','latent','pca_mean');
     
    end
    
    if (get(handles.pca_ica,'Value') == 2)
       
    % ICA Input Matrix
    setProcess(status_process,'ICA Input Matrix ...')
    [pca_in,pca_mean] = pca_in2(hrirs,2,1,freq_mode,1:subjects,1:size(hrirs,2),0,0,size(hrirs,4),smooth_val,sub_id_excl,fs);
    
    % ICA
    setProcess(status_process,'ICA ...')
    [ics] = fastica(pca_in, 'numOfIC', 10,'lastEig', 10,'verbose','off','interactivePCA','off');
    ic_weights = pca_in * ics';
    
    % Save Precalculated ICA Data
    save(db_file,'ics','ic_weights','pca_mean');
    end
    
    
end
    
delete(status_process);
calc_status = 1;
RefreshGUI(hObject, eventdata, handles)
%setProcess(status_process,'Update GUI ...')

% Start with Mean Value or Weights from random subject
% TO BE DONE

%set(handles.position,'String',source_list(current_db,angles));
set(handles.position,'Value',1)
set(handles.position,'String',trajectory_list(current_db,angles));
set(handles.slider_modus,'Visible','On')
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

position_Callback(hObject, eventdata, handles)


function RefreshGUI(hObject, eventdata, handles)
global sh_weights
global sh_weights_rc
global pc_weights
global pc_weights_rc
global pc_order
global sh_order
global sha
global angles
global calc_status

if (calc_status ==1) % only when PCA calculation was done before
    status_process = uicontrol('Tag','status_process','FontSize',20,'FontWeight','Bold','ForeGroundColor', 'w','BackgroundColor','r','Style','text', 'Units','Normalized','Position',[0 0 1 1]);
    
    % Save current SH values and update GUI after Slider Update
    if (isempty(sh_weights_rc) == 0)
        sh_weights_rc_old = sh_weights_rc;
        %disp('save SH values')
    else
        sh_weights_rc_old = '';
    end
    
    if (isempty(pc_weights_rc) == 0)
        pc_weights_rc_old = pc_weights_rc;
    else
        pc_weights_rc_old = '';
    end


    % Spherical Harmonics from PCA Weights
    setProcess(status_process,'Update GUI ...')
    sh_order_strings = (get(handles.sh_order,'String'));
    sh_order = str2double(sh_order_strings(get(handles.sh_order,'Value')));
    pc_order = get(handles.pc_numbers,'Value');
    [sh_weights,sha] = pca2sh(pc_weights,angles,pc_order,sh_order);
    
    
    % Calc Mean PC and SH Weights
    sh_weights_rc = squeeze(mean(sh_weights,1));
    pc_weights_rc = squeeze(mean(pc_weights,1));
    
    % Update old SH Values if existent
    if (isempty(sh_weights_rc_old) == 0)
    [sh_weights_rc] = updateSHValues(sh_weights_rc_old,sh_weights_rc);
    %disp('update SH values')
    end
    
    % Update old PC Values if existent
    if (isempty(pc_weights_rc_old) == 0)
    pc_weights_rc = pc_weights_rc_old;
    end
    
    % Delete all SH Variance Text Layers
    h = findobj(findobj, '-regexp', 'Tag', '^var_text_sh_pc');
    delete(h)

    % Create new sliders
    slider_modus_Callback(hObject, eventdata, handles)
    
    % Select again previous pc or sh choice
    reselectradiobuttons(hObject, eventdata, handles)
    
    % Color Overlay
    %color_overlay(hObject, eventdata, handles)
    
    delete(status_process);
    
    % Check Error: there should be no status process message in background
    status_process=findobj('tag','status_process');
    if (isempty(status_process) == 0)
    delete(status_process);    
    end
end


function SliderPC2SH(~, ~, ~)
global sh_weights
global sh_weights_rc
global latent
global ov_pc
global ov_sh
global ov_rot
global ov_dir

% Create Button Group
button_group = uibuttongroup('SelectionChangeFcn', 'gui_sh(''choose_pc'', gcbo, guidata(gcbo))','BackgroundColor',[0.6 0.6 0.6],'BorderType','none','Units','characters','Position',[33 0 21 36]);

% Create Buttons
posy = 365;
total_var = 0;

sh_modus = get(findobj('tag','adapt_mode'),'Value');

slid_range = str2num(get(findobj('tag','slider_range'),'String'));
color_ol=findobj('tag','color_overlay');

for pc = 1:size(sh_weights,3)    
  
    % Calc Variance
    var = latent(pc)/sum(latent)*100;
    total_var = total_var+var;
    
    posy = posy - 20;
    pcno = sprintf('PC%i (%2.1f%%)',pc,var);
    name_radio = sprintf('pc%i_radio',pc);
      
    uicontrol('Tag',name_radio,'Parent',button_group,'FontSize',12,'FontWeight','normal','String',pcno,'Style','radiobutton','Units','pixels','Position', [10 posy 110 20]);
    
    posy1 = 365;
    
    
    if (sh_modus == 1)
    % Show PC Weights as Sliders
    posy1 = CreateSliders_PC2SH_PCW(pc,posy1,slid_range,color_ol);
    end
    
    
    if (sh_modus == 2)
    % Show SH Weights as Sliders
    posy1 = CreateSliders_PC2SH_SHW(pc,posy1,slid_range,color_ol);
    end
    
    if (sh_modus == 3)
    % Show PCWs of SH Weights as Sliders
    posy1 = CreateSliders_PC2SH_SHWPCA(pc,posy1,slid_range,color_ol);
    end

end


uicontrol('Tag','var_text','FontWeight','bold','HorizontalAlignment','Left','BackgroundColor',[0.6 0.6 0.6],'Parent',button_group,'FontSize',12,'String',sprintf('Total Variance: %2.1f%%',total_var),'Style','text','Units','pixels','Position', [10 posy-80 110 60]);



function [posy1] = CreateSliders_PC2SH_PCW(pc,posy1,slid_range,color_ol)
global pc_weights
global current_positions

% Select PC Weights of current_positions
pc_weights_select = squeeze(pc_weights(:,current_positions,pc));

% Mean
pc_weights_select_mn = mean(pc_weights_select);
pc_weights_select_mn = mean(pc_weights_select_mn);

% Std
pc_weights_select_std = std(pc_weights_select);

if (size(pc_weights_select_std,2) > 1)
pc_weights_select_std = std(pc_weights_select_std);
end

name_sl = sprintf('slider%i',pc); 
posy1 = posy1-22;

% Min/Max values
min = (pc_weights_select_mn-slid_range*pc_weights_select_std);
max = (pc_weights_select_mn+slid_range*pc_weights_select_std);
val = pc_weights_select_mn;

if (val < min)
   val = min; 
end

if (val > max)
   val = max; 
end

% Create new Slider   
uicontrol('Tag',name_sl,'Backgroundcolor',[1 0 0],'Callback','gui_sh(''slider_change_pc_pcw'', gcbo, guidata(gcbo))','Style','slider','Units','pixels','Position', [390 posy1 200 50],'Min',min,'Max',max,'Value', val);
   

function [posy1] = CreateSliders_PC2SH_SHWPCA(pc,posy1,slid_range,color_ol)
global sh_weights
global sh_pcs
global sh_pc_weights
global sh_latent
global sh_pc_weights_original
global sh_pc_number
global sh_slider_vals

sh_pc_number = get(findobj('tag','pca_of_shws_pcs'),'Value');

sh_pc_weights_original = zeros(sh_pc_number,pc);
pca_in = squeeze(sh_weights(:,:,pc));

% Substract Mean
mean_sub = mean(pca_in,2);
mean_sub = repmat(mean_sub,1,size(pca_in,2));
pca_in = pca_in - mean_sub;

% PCA
[cur_sh_pcs,cur_sh_pc_weights,cur_sh_latent] = princomp(pca_in,'econ');
var = cur_sh_latent/sum(cur_sh_latent)*100;

sh_pcs{pc} = cur_sh_pcs;
sh_pc_weights{pc} = cur_sh_pc_weights;
sh_latent{pc} = cur_sh_latent;

for sh = 1:sh_pc_number
    
    posy1 = posy1-22;
    
    name_sl = sprintf('slider%i_%i',pc,sh); 
    name_sl_bg = sprintf('slider_bg%i_%i',pc,sh); 
        
    slider_mn = mean(cur_sh_pc_weights(:,sh));
    slider_std = std(cur_sh_pc_weights(:,sh));
    
    min = (slider_mn-slid_range*slider_std);
    max = (slider_mn+slid_range*slider_std);
    val = slider_mn;
    sh_pc_weights_original(sh,pc)=val;
    
    % Use Slider values from before, if existent
    if (isempty(sh_slider_vals) == 0)
        
        if (sh <= size(sh_slider_vals,1)) && (pc <= size(sh_slider_vals,2))
        
        val = sh_slider_vals(sh,pc);
        
        if (val > max)
            val = max;
        end
        
        if (val < min)
            val = min;
        end
        
        else
        val = slider_mn;      
        end
        
        
    end 
    
    
        
  % Create new Slider   
    uicontrol('Tag',name_sl,'Backgroundcolor',[1 0 0],'Callback','gui_sh(''slider_change_pc2sh_pca'', gcbo, guidata(gcbo))','Style','slider','Units','pixels','Position', [390 posy1 200 50],'Min',min,'Max',max,'Value', val);

     
end

name_sh_var = sprintf('var_text_sh_pc%i',pc); 
uicontrol('Tag',name_sh_var,'FontWeight','bold','HorizontalAlignment','Left','FontSize',12,'String',sprintf('Total Variance: %2.1f%%',sum(var(1:sh_pc_number))),'Style','text','Units','pixels','Position', [390 posy1-60 200 50]);




function [posy1] = CreateSliders_PC2SH_SHW(pc,posy1,slid_range,color_ol)
global sh_weights
global sh_weights_rc
global ov_pc
global ov_sh
global ov_rot
global ov_dir

    for sh = 1:size(sh_weights,2)
        name_sl = sprintf('slider%i_%i',pc,sh); 
        name_sl_bg = sprintf('slider_bg%i_%i',pc,sh); 
        posy1 = posy1-22;
        
        slider_mn = mean(sh_weights(:,sh,pc));
        slider_std = std(sh_weights(:,sh,pc));
        
        
        % verify that value is between min/max values
        min = (slider_mn-slid_range*slider_std);
        max = (slider_mn+slid_range*slider_std);
        val = sh_weights_rc(sh,pc);
        
        if (val > max) 
            val = max;
            sh_weights_rc(sh,pc) = val;
        end 
        
        if (val < min) 
            val = min;
            sh_weights_rc(sh,pc) = val;
        end 
        
        % Create background color for slider
        if (get(color_ol,'Value') == 1)        
            ind = find(strcmp(num2str(pc),ov_pc) & strcmp(num2str(sh),ov_sh));
            if (isempty(ind) == 0)
            [bcl,fcl] = get_ov_color(ov_dir{ind});
            uicontrol('Tag',name_sl_bg,'Foregroundcolor',fcl,'Backgroundcolor',bcl,'Style','text','Units','pixels','Position', [590 posy1+35 80 15],'String',ov_rot{ind});
            end
        end
        
        % Create new Slider   
        uicontrol('Tag',name_sl,'Backgroundcolor',[1 0 0],'Callback','gui_sh(''slider_change_pc2sh'', gcbo, guidata(gcbo))','Style','slider','Units','pixels','Position', [390 posy1 200 50],'Min',min,'Max',max,'Value', val);
        
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

function cp_update(hObject,~,~)
global sh_weights_rc

disp('test_button')


function SliderSH2PC(~, ~, ~)
global sh_weights
global sh_weights_rc
global ov_pc
global ov_sh
global ov_rot
global ov_dir


slid_range = str2num(get(findobj('tag','slider_range'),'String'));
color_ol=findobj('tag','color_overlay');

% Create Button Group
button_group = uibuttongroup('SelectionChangeFcn', 'gui_sh(''choose_sh'', gcbo, guidata(gcbo))','BackgroundColor',[0.6 0.6 0.6],'BorderType','none','Units','characters','Position',[33 0 21 36]);

% Create Buttons
posy = 365;

for sh = 1:size(sh_weights,2)    
  
    posy = posy - 20;
    shno = sprintf('SH%i',sh);
    name_radio = sprintf('sh%i_radio',sh);
      
    uicontrol('Tag',name_radio,'Parent',button_group,'FontSize',12,'FontWeight','normal','String',shno,'Style','radiobutton','Units','pixels','Position', [10 posy 110 20]);
    
   
        posy1 = 365;
        for pc = 1:size(sh_weights,3)
        name_sl = sprintf('slider%i_%i',sh,pc);
        name_sl_bg = sprintf('slider_bg%i_%i',sh,pc);
        posy1 = posy1-22;
        
        slider_mn = mean(sh_weights(:,sh,pc));
        slider_std = std(sh_weights(:,sh,pc));
        
        % verify that value is between min/max values
        min = (slider_mn-slid_range*slider_std);
        max = (slider_mn+slid_range*slider_std);
        val = sh_weights_rc(sh,pc);
        
        if (val > max) 
            val = max;
            sh_weights_rc(sh,pc) = val;
        end 
        
        if (val < min) 
            val = min;
            sh_weights_rc(sh,pc) = val;
        end 
        
        % Create background color for slider
        if (get(color_ol,'Value') == 1)        
            ind = find(strcmp(num2str(pc),ov_pc) & strcmp(num2str(sh),ov_sh));
        
            if (isempty(ind) == 0)
                
            [bcl,fcl] = get_ov_color(ov_dir{ind});             
            uicontrol('Tag',name_sl_bg,'Backgroundcolor',bcl,'Foregroundcolor',fcl,'Style','text','Units','pixels','Position', [590 posy1+35 100 15],'String',ov_rot{ind});
            end
        end
        
        % Create new Slider
        uicontrol('Tag',name_sl,'Callback','gui_sh(''slider_change_sh2pc'', gcbo, guidata(gcbo))','Style','slider','Units','pixels','Position', [390 posy1 200 50],'Min',min,'Max',max,'Value', val);
        
        end
        
end

function setpc(~, ~,pc)
global sh_weights

color_ol=findobj('tag','color_overlay');

% all Sliders invisible
h=findobj('style','slider');
set(h,'Visible','off')

% all SH Variance Text invisible
h = findobj(findobj, '-regexp', 'Tag', '^var_text_sh_pc');
set(h,'Visible','off')

if (get(findobj('tag','adapt_mode'),'Value') == 3)
h=findobj('tag',sprintf('var_text_sh_pc%i',pc));
set (h,'Visible','On')
end

if (get(color_ol,'Value') == 1)
% All Slider Background Layers invisble
h = findobj(findobj, '-regexp', 'Tag', '^slider_bg');
set(h,'Visible','Off')
end

% set sliders for current pc visible

switch (get(findobj('tag','adapt_mode'),'Value'))

    case 1
    if (get(findobj('tag','adapt_mode'),'Value') == 1)
    
    name_sl = sprintf('slider%i',pc);
    h=findobj('tag',name_sl);
    set (h,'Visible','On')  
    end

    
    case {2,3}
        
    for sh=1:size(sh_weights,2)

        if (get(color_ol,'Value') == 1)
        name_sl_bg = sprintf('slider_bg%i_%i',pc,sh);
        h=findobj('tag',name_sl_bg);
        set (h,'Visible','On')
        end

    name_sl = sprintf('slider%i_%i',pc,sh);
    h=findobj('tag',name_sl);
    set (h,'Visible','On')

    end
end


function setsh(~, ~,sh)
global sh_weights

color_ol=findobj('tag','color_overlay');

% all Sliders invisible
h=findobj('style','slider');
set(h,'Visible','off')

if (get(color_ol,'Value') == 1)
% All Slider Background Layers invisble
h = findobj(findobj, '-regexp', 'Tag', '^slider_bg');
set(h,'Visible','Off')
end

% set pc sliders for current sh visible
for pc=1:size(sh_weights,3)
    
    if (get(color_ol,'Value') == 1)
    name_sl_bg = sprintf('slider_bg%i_%i',sh,pc);
    h=findobj('tag',name_sl_bg);
    set (h,'Visible','On')
    end
    
    name_sl = sprintf('slider%i_%i',sh,pc);
    h=findobj('tag',name_sl);
    set (h,'Visible','On')
    
    
end


function slider_change_pc_pcw(hObject,~,~)
global pc_weights_rc
global pc_weights
global pc_order
global current_positions

% Which slider was changed?
slider = regexprep(get(hObject,'Tag'),'slider', '');
pc_changed = str2num(char(slider(1)));

% Calc PC Weights based on Slider Values
% Get Slider Values
h=findobj('style','slider');
slider_val  = get(h,'Value');
slider_val = cell2mat(slider_val);
slider_val = slider_val(end:-1:1);

pc_weights_rc = squeeze(mean(pc_weights(:,:,1:pc_order),1));
pc_weights_rc(current_positions,:) = repmat(slider_val',size(current_positions,1),1);

reconstruction('adapt',0,1,pc_changed)

function slider_change_pc2sh(hObject,~,~)
global sh_weights_rc

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

sh_weights_rc(1:size(sh_weights_rc,1),1:size(sh_weights_rc,2)) = reshape(fliplr(slider_val'),size(sh_weights_rc,1),size(sh_weights_rc,2));

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
global sh_weights_rc

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

sh_weights_rc(1:size(sh_weights_rc,1),1:size(sh_weights_rc,2)) = reshape(fliplr(slider_val'),size(sh_weights_rc,2),size(sh_weights_rc,1))';

reconstruction('adapt',0,1,pc_changed)

function reconstruction(adaption_mode,sound_mode,play_reset,pc_changed)
global current_db
global sha
global pcs
global sh_weights
global sh_weights_rc
global pc_weights_rc
global pc_weights
global pca_mean
global pc_order
global hrirs
global hrir_reconstr_left
global hrir_reconstr_right
global freq_mode
global current_positions
global fs
global ari_id
global excluded_hrtf
global sh_order
global angles


if (nargin < 4)
   pc_changed = 1; 
end

switch (get(findobj('tag','adapt_mode'),'Value'))
    
    case 1
        
        if (strcmp(adaption_mode,'adapt') == 1)
        % Reconstruction from Slider Values
        
        else
        % Reconstruction with Mean Values
        pc_weights_rc = squeeze(mean(pc_weights,1));
        end
        
    case {2,3}

        N = size(sh_weights,3); % PC numbers
        
        % Reconstruction of the principal component weights
        if (strcmp(adaption_mode,'adapt') == 1)
            % Reconstruction from Slider Values
            pc_weights_rc(:,1:N) = sha*squeeze(sh_weights_rc(:,1:N));
            %e(1,:,1:N) = sqrt(pc_weights(1,:,1:N) - pc_weights_rc(:,1:N)).^2; 
        else
            % Reconstruction with Mean Values
            sh_weights_mean = squeeze(mean(sh_weights,1));
            pc_weights_rc(:,1:N) = sha*sh_weights_mean(:,1:N); 
            
            %pc_weights_rc(:,1:N) = sha*squeeze(sh_weights_rc(:,1:N));
        end

end

% % Display Min/Max Values for checking
% for pc = 1:pc_order
%     disp(sprintf('PC:%d,%.3f,%.3f',pc, min(min(squeeze(pc_weights(:,:,pc)))), max(max(squeeze(pc_weights(:,:,pc)))) ));    
% end
% disp(' ')
% 
% for pc = 1:pc_order
%     disp(sprintf('PC:%d,%.3f,%.3f',pc, (min(squeeze(pc_weights_rc(:,pc)))), (max(squeeze(pc_weights_rc(:,pc)))) ));    
% end


% Reconstruct DTF    
reconstruct = pc_weights_rc(:,1:pc_order) * pcs(:,1:pc_order)';


% own pc weights solution
%reconstruct = squeeze(pc_weights(ari_id,:,1:pc_order)) * pcs(:,1:pc_order)';

reconstruct_left = reconstruct(current_positions,1:size(reconstruct,2)/2);
reconstruct_right = reconstruct(current_positions,size(reconstruct,2)/2+1:end);

% Add global mean
hrtf_mag_left =  reconstruct_left + repmat(squeeze(pca_mean(1,1,1,:))',[size(reconstruct_left,1),1]);
hrtf_mag_right =  reconstruct_right + repmat(squeeze(pca_mean(1,1,2,:))',[size(reconstruct_right,1),1]);

if (ari_id == 0)  || (isempty(ari_id) == 1) || (isempty(strfind(current_db,'ari')) == 0) || (excluded_hrtf == 0)
    itd_id = 1;
else
    itd_id = ari_id;
end

for i=1:length(current_positions)
    % ITD
    [~,~,~,itd_samples] = calculate_itd(squeeze(hrirs(itd_id,current_positions(i),1,:)),squeeze(hrirs(itd_id,current_positions(i),2,:)),fs);
    % HRIR
    [hrir_reconstr_left(i,:), hrir_reconstr_right(i,:)] = ifft_minph(hrtf_mag_left(i,:),hrtf_mag_right(i,:),itd_samples,size(hrirs,4),freq_mode);
end

% Play Sound
if (sound_mode == 1)
    play_stimulus()
else
    if (get(findobj('tag','play_auto'),'Value') == 1) && (play_reset == 1)
    play_stimulus()
    end
end


% Plot sphere with SH weights
if (strcmp(get(findobj('tag','uitool_enableplot'),'State'),'on') == 1)
    spherical_plot()
end

% Plot histogram of SH weights
if (strcmp(get(findobj('tag','uitool_enablehist'),'State'),'on') == 1)
    spherical_histo(pc_changed)
end

% Plot 3D SH weights (multiple windows)
if (strcmp(get(findobj('tag','uitool_plot_sh'),'State'),'on') == 1)
    plot_sh(sh_order,sh_weights_rc,angles,current_positions,'multi')
end

% Plot 3D SH weights (single window)
if (strcmp(get(findobj('tag','uitool_plot_sh_single'),'State'),'on') == 1)
    plot_sh(sh_order,sh_weights_rc,angles,current_positions,'single')
end


function play_stimulus()
global fs
global eq_id
global stim
global hrir_reconstr_left
global hrir_reconstr_right
global current_positions

for i=1:length(current_positions)
    stim_out{i} = get_stimulus([hrir_reconstr_left(i,:); hrir_reconstr_right(i,:)]',fs,stim,eq_id,str2num(get(findobj('tag','silence_value'),'String')));
end

play_sound_all(stim_out,current_positions,fs,get(findobj('tag','play_simul'),'Value'))

function play_original_Callback(~, ~, ~)
global hrirs
global current_positions
global fs
global eq_id
global stim
global ari_id

for i=1:length(current_positions)
    stim_out{i} = get_stimulus([squeeze(hrirs(ari_id,current_positions(i),1,:)) squeeze(hrirs(ari_id,current_positions(i),2,:))],fs,stim,eq_id,str2num(get(findobj('tag','silence_value'),'String'))); 
end

play_sound_all(stim_out,current_positions,fs,get(findobj('tag','play_simul'),'Value'))

function play_adapted_Callback(~, ~, ~)
reconstruction('adapt',1,1)

function play_generalized_Callback(~, ~, ~)
global current_db
global fs
global eq_id
global stim
global current_positions
global hrirs

if (isempty(strfind(current_db,'kemar')) == 0)
    % play kemar

    for i=1:length(current_positions)
        stim_out{i} = get_stimulus([squeeze(hrirs(end,current_positions(i),1,:)) squeeze(hrirs(end,current_positions(i),2,:))],fs,stim,eq_id,str2num(get(findobj('tag','silence_value'),'String')));
    end
   
    play_sound_all(stim_out,current_positions,fs,get(findobj('tag','play_simul'),'Value'))
else
    reconstruction('generalized',1,1)
    % play generalized HRTF
end

function choose_pc(hObject,eventdata,~)
global pc_active

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


function position_Callback(hObject, eventdata, handles)
global current_db
global angles
global current_positions

% Get Position Indices for selected Trajectory
c_pos=findobj('tag','position');
[~,ind_daten] = trajectory_list(current_db,angles);
current_positions = ind_daten{get(c_pos,'Value')};

if (get(handles.adapt_mode,'Value') == 1)
    % Refresh Sliders based on selected position
   RefreshGUI(hObject, eventdata, handles) 
end

reconstruction('adapt',0,1)

function headeq_Callback(~, ~, handles)
global eq_id

eq_id = get(handles.headeq,'Value');

function sound_Callback(~, ~, handles)
global stim
global fs

% Import other sounds
[ stim ] = import_sound(get(handles.sound,'Value'),fs);

reconstruction('adapt',0,1)


function spherical_histo(pc_changed)
global angles
global pc_weights_rc
global current_positions
global pc_weights

if (rem(length(current_positions),2) == 1)
subplots = length(current_positions) +1;
else
subplots = length(current_positions); 
end

subp1 = subplots/2;
subp2 = subplots / subp1;

figure(4);
for pos=1:length(current_positions)
    
    subplot(subp2,subp1,pos);
    cla;
    hist(pc_weights(:,current_positions(pos),pc_changed))
    title(sprintf('PC %i / Az%i / El%i',pc_changed,angles(current_positions(pos),1),angles(current_positions(pos),2)))
    
    % Current Slider Value:
    hold on
    line([pc_weights_rc(current_positions(pos),pc_changed) pc_weights_rc(current_positions(pos),pc_changed)],get(gca,'Ylim'),'Color',[1 0 0]) 
     
end



function spherical_plot()
global angles
global pc_weights_rc
global pc_order
global current_positions

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
    F = TriScatteredInterp(angles(:,1),angles(:,2),squeeze(pc_weights_rc(:,pc)));
    ZI(pc,:,:) = F(Thetas,Phis);
    mn(pc) = squeeze(min(min(min(pc_weights_rc(:,pc))))); mx(pc) = squeeze(max(max(max(pc_weights_rc(:,pc)))));

end

figure(3);

% Add Position of current trajetory
[ccx1,ccy1,ccz1] = sph2cart(Thetas/180*pi,Phis/180*pi,ones(size(Thetas)));

ccx2 = ccx1(current_positions,current_positions);
ccy2 = ccy1(current_positions,current_positions);
ccz2 = ccz1(current_positions,current_positions);
    
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
global sh_weights
global sh_weights_rc

sh_weights_rc = squeeze(mean(sh_weights,1));

for sh = 1:size(sh_weights,2)         
    for pc = 1:size(sh_weights,3)
        
    name_sl = sprintf('slider%i_%i',sh,pc); 
    h = findobj('tag',name_sl);
    set(h,'Value',sh_weights_rc(sh,pc));

    end
end
reconstruction('adapt',0,get(findobj('tag','play_reset'),'Value'))

function ResetSliderSH_active(~, ~, ~)
global sh_weights
global sh_weights_rc
global sh_active

sh_weights_rc(sh_active,:) = squeeze(mean(sh_weights(:,sh_active,:),1));

for pc = 1:size(sh_weights,3)
    name_sl = sprintf('slider%i_%i',sh_active,pc); 
    h = findobj('tag',name_sl);
    set(h,'Value',sh_weights_rc(sh_active,pc));
end

reconstruction('adapt',0,get(findobj('tag','play_reset'),'Value'))


function ResetSliderPC_PCW(hObject, eventdata, handles)
global pc_order
global pc_weights
global pc_weights_rc
global current_positions

RefreshGUI(hObject, eventdata, handles)

% Get Slider Values
h=findobj('style','slider');
slider_val  = get(h,'Value');
slider_val = cell2mat(slider_val);
slider_val = slider_val(end:-1:1);

pc_weights_rc = squeeze(mean(pc_weights(:,:,1:pc_order),1));
pc_weights_rc(current_positions,:) = repmat(slider_val',size(current_positions,1),1);

reconstruction('adapt',0,get(findobj('tag','play_reset'),'Value'))

function ResetSliderPC_active_PCW(hObject, eventdata, handles)
global pc_active
global pc_weights
global pc_weights_rc
global current_positions
global pc_order

% Select PC Weights of current_positions
pc_weights_select = squeeze(pc_weights(:,current_positions,pc_active));

% Mean
pc_weights_select_mn = mean(pc_weights_select);
pc_weights_select_mn = mean(pc_weights_select_mn);

% Std
pc_weights_select_std = std(pc_weights_select);

if (size(pc_weights_select_std,2) > 1)
pc_weights_select_std = std(pc_weights_select_std);
end

name_sl = sprintf('slider%i',pc_active);
h = findobj('tag',name_sl);
set(h,'Value',pc_weights_select_mn);


% Get Slider Values
h=findobj('style','slider');
slider_val  = get(h,'Value');
slider_val = cell2mat(slider_val);
slider_val = slider_val(end:-1:1);

pc_weights_rc = squeeze(mean(pc_weights(:,:,1:pc_order),1));
pc_weights_rc(current_positions,:) = repmat(slider_val',size(current_positions,1),1);


reconstruction('adapt',0,get(findobj('tag','play_reset'),'Value'))


function ResetSliderPC_SHW(~, ~, ~)
global sh_weights
global sh_weights_rc

sh_weights_rc = squeeze(mean(sh_weights,1));

for pc = 1:size(sh_weights,3)         
    for sh = 1:size(sh_weights,2)
        
    name_sl = sprintf('slider%i_%i',pc,sh); 
    h = findobj('tag',name_sl);
    set(h,'Value',sh_weights_rc(sh,pc));

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
global sh_weights
global sh_weights_rc
global pc_active

sh_weights_rc(:,pc_active) = squeeze(mean(sh_weights(:,:,pc_active),1));
        
for sh = 1:size(sh_weights,2)
    name_sl = sprintf('slider%i_%i',pc_active,sh); 
    h = findobj('tag',name_sl);
    set(h,'Value',sh_weights_rc(sh,pc_active));
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
global sh_weights_rc 
global current_db
global subject_id

sh_file = sprintf('../matlabdata/experiment/sh_values_%s_%i_%i.mat',current_db,subject_id,get(handles.position,'Value'));

if (exist(sh_file,'file') == 2)
    load(sh_file);
    
    % Get Slider Min/Max Values to prevent GUI Error when loaded values are outside the range    
    [tableMin,tableMax] = GetMinMaxValues();
    [sh_weights_rc] = updateSHValues(sh_weights_rc_save,sh_weights_rc);

    % Adapt if necessary
    for sh=1:size(sh_weights_rc,1)
       for pc=1:size(sh_weights_rc,2)
       
       % Min
       if (sh_weights_rc(sh,pc) < tableMin(sh,pc))
           sh_weights_rc(sh,pc) = tableMin(sh,pc);
       end
          
       % Max
       if (sh_weights_rc(sh,pc) > tableMax(sh,pc))
           sh_weights_rc(sh,pc) = tableMax(sh,pc);
       end
       
               
       end
        
    end
    
end

SetSHValues()


function [tableMin,tableMax] = GetMinMaxValues()
global sh_weights


slider_modus=findobj('tag','slider_modus');

if (get(slider_modus,'Value') == 1)
    % PC -> SH
    
    for pc = 1:size(sh_weights,3)         
    for sh = 1:size(sh_weights,2)
        
    name_sl = sprintf('slider%i_%i',pc,sh);
    h = findobj('tag',name_sl);
    tableMin(sh,pc) = get(h,'Min');
    tableMax(sh,pc) = get(h,'Max');

    end
    end

else
    % SH -> PC
    
    for sh = 1:size(sh_weights,2)         
    for pc = 1:size(sh_weights,3)
        
    name_sl = sprintf('slider%i_%i',sh,pc);     
    h = findobj('tag',name_sl);
    tableMin(sh,pc) = get(h,'Min');
    tableMax(sh,pc) = get(h,'Max');

    end
    end

end




function SetSHValues()
global sh_weights
global sh_weights_rc

slider_modus=findobj('tag','slider_modus');

if (get(slider_modus,'Value') == 1)
    % PC -> SH
    
    for pc = 1:size(sh_weights,3)         
    for sh = 1:size(sh_weights,2)
        
    name_sl = sprintf('slider%i_%i',pc,sh);
    h = findobj('tag',name_sl);
    set(h,'Value',sh_weights_rc(sh,pc));

    end
    end

else
    % SH -> PC
    
    for sh = 1:size(sh_weights,2)         
    for pc = 1:size(sh_weights,3)
        
    name_sl = sprintf('slider%i_%i',sh,pc); 
    h = findobj('tag',name_sl);
    set(h,'Value',sh_weights_rc(sh,pc));

    end
    end

end

function SaveSHValues(~, ~, handles)
global sh_weights_rc 
global current_db
global subject_id

sh_weights_rc_save = sh_weights_rc;
save(sprintf('../matlabdata/experiment/sh_values_%s_%i_%i.mat',current_db,subject_id,get(handles.position,'Value')),'sh_weights_rc_save');

function uitool_calc_ClickedCallback(hObject, eventdata, handles)
calc_Callback(hObject, eventdata, handles)

function uitool_load_ClickedCallback(hObject, eventdata, handles)
LoadSHValues(hObject, eventdata, handles)

function uitool_save_ClickedCallback(hObject, eventdata, handles)
SaveSHValues(hObject, eventdata, handles)

function uitool_resetall_ClickedCallback(hObject, eventdata, handles)

if (get(handles.slider_modus,'Value') == 1)
   
    if (get(handles.adapt_mode,'Value') == 1)
    ResetSliderPC_PCW(hObject, eventdata, handles)
    end
    
    if (get(handles.adapt_mode,'Value') == 2)
    ResetSliderPC_SHW(hObject, eventdata, handles)
    end
    
    if (get(handles.adapt_mode,'Value') == 3)
    ResetSliderPC_SHWPCA(hObject, eventdata, handles)
    end
    
else
    ResetSliderSH(hObject, eventdata, handles)
end
    
function uitool_reset_active_ClickedCallback(hObject, eventdata, handles)

if (get(handles.slider_modus,'Value') == 1)
    
    if (get(handles.adapt_mode,'Value') == 1)
    ResetSliderPC_active_PCW(hObject, eventdata, handles)
    end
    
    if (get(handles.adapt_mode,'Value') == 2)
    ResetSliderPC_active_SHW(hObject, eventdata, handles)
    end
    
    if (get(handles.adapt_mode,'Value') == 3)
    ResetSliderPC_active_SHWPCA(hObject, eventdata, handles)
    end
    
else
    ResetSliderSH_active(hObject, eventdata, handles)
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
set(handles.play_auto,'Visible','On')
set(handles.play_simul,'Visible','On')
set(handles.play_reset,'Visible','On')
set(handles.silence_value,'Visible','On')
set(handles.text_pause,'Visible','On')

if (isempty(strfind(current_db,'ari')) == 0) && (excluded_hrtf == 0)
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
global latent
global pc_order

total_var = 0;

for pc=1:pc_order
    total_var = total_var + latent(pc);
    var1(pc) = total_var;
    var2(pc) = latent(pc);
end

% for pc = 1:pc_order
%     disp(sprintf('PC:%d,%.3f,%.3f',pc, min(min(squeeze(pc_weights(:,:,pc)))), max(max(squeeze(pc_weights(:,:,pc)))) ));    
% end


figure(30)
subplot(3,1,1)
plot(var1/sum(latent)*100,'r')
title('Variance of PCs')
grid on
hold on
bar(var2/sum(latent)*100)

subplot(3,1,2)
hist(pc_weights_rc)
title('PC Weights')
grid on

subplot(3,1,3)
hist(sh_weights_rc)
title('Sh Weights')
grid on

function uitool_plot_sh_single_OffCallback(hObject, eventdata, handles)
if (ishandle(40)==1)
   close(40) 
end

function uitool_plot_sh_single_OnCallback(hObject, eventdata, handles)
reconstruction('adapt',0,1)


function color_overlay_Callback(hObject, eventdata, handles)
global ov_pc
global ov_sh
global ov_rot
global ov_dir

if (get(handles.color_overlay,'Value') == 1)
   
   % Import txt-file with control data
   [ov_pc,ov_sh,ov_rot,ov_dir] = import_overlay();
    
    
   slider_modus_Callback(hObject, eventdata, handles)
else
   % delete background 
   h = findobj(findobj, '-regexp', 'Tag', '^slider_bg');
   delete(h)

end

function adapt_mode_Callback(hObject, eventdata, handles)

if(get(handles.adapt_mode,'Value') == 1)
    set(handles.color_overlay,'Visible','Off')
    set(handles.shw_pcs_number_text,'Visible','Off')
    set(handles.pca_of_shws_pcs,'Visible','Off')
    set(handles.sh_order_text,'Visible','Off')
    set(handles.sh_order,'Visible','Off')
end

if(get(handles.adapt_mode,'Value') == 2)
    set(handles.color_overlay,'Visible','On')
    set(handles.shw_pcs_number_text,'Visible','Off')
    set(handles.pca_of_shws_pcs,'Visible','Off')
    set(handles.sh_order_text,'Visible','On')
    set(handles.sh_order,'Visible','On')
end

if(get(handles.adapt_mode,'Value') == 3)
    set(handles.color_overlay,'Visible','Off')
    set(handles.shw_pcs_number_text,'Visible','On')
    set(handles.pca_of_shws_pcs,'Visible','On')
    set(handles.sh_order_text,'Visible','On')
    set(handles.sh_order,'Visible','On')
end

RefreshGUI(hObject, eventdata, handles)



function play_reset_Callback(hObject, eventdata, handles)


function play_simul_Callback(hObject, eventdata, handles)



function pca_ica_Callback(hObject, eventdata, handles)
