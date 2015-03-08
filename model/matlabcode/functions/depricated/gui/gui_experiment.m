function varargout = gui_experiment(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_experiment_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_experiment_OutputFcn, ...
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

function gui_experiment_OpeningFcn(hObject, eventdata, handles, varargin)
global subject_id
global eq_id
global ari_id

handles.output = hObject;
guidata(hObject, handles);

% UIWAIT makes gui_experiment wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%set(handles.play_measured,'visible','off');
[subject_id,eq_id,ari_id] = init_name();
% old: [eq_id,text] = init_name(subject_id);

set(handles.id,'String', text);
set(handles.headphone_eq,'Value', eq_id);

% Init values on GUI startup
set(handles.select_db,'Value', 2);
set(handles.calc_mode,'Value', 2);
set(handles.reconstruct_pcs,'Value', 7);

db_ids =  config('exp');
set(handles.select_db,'String',db_ids);
select_db_Callback(hObject, eventdata, handles)

set(handles.soundmode,'Value', 3);
set(handles.fft_points,'Value', 4);
setButtons(hObject, eventdata, handles)
setSlidersExtend(hObject, eventdata, handles)

function setButtons(hObject, eventdata, handles)
global current_db
global subject_id
global measured_available

measured_available = 0;
% show/hide buttons "solution_10" and "Measured"
% switch(current_db)
%     
%     case {'ari','universal','cipic','iem','ircam'}
%         
%     if (subject_id == 102) || (subject_id == 103) || (subject_id == 104)
%         
%         set(handles.play_tuning,'Position',[30.11, 33, 19.71 3]);
%         set(handles.play_averaged,'Position',[50.18, 33, 19.71 3]);
%         set(handles.play_measured,'visible','on');
%         set(handles.solution_10,'visible','on');
%         set(handles.solution_subject,'visible','on');
%         set(handles.add_mean,'visible','on');
%         measured_available = 1;
%     else
%         set(handles.play_tuning,'Position',[26.28, 33, 19.71 3]);
%         set(handles.play_averaged,'Position',[58.28, 33, 19.71 3]);
%         set(handles.solution_10,'visible','off');
%         set(handles.solution_subject,'visible','off');
%         set(handles.add_mean,'visible','off');
%         
%     end
% 
%     otherwise
%         set(handles.play_measured,'visible','off');
%         set(handles.solution_10,'visible','off');
%         set(handles.solution_subject,'visible','off');
%         set(handles.add_mean,'visible','off');
%         set(handles.play_tuning,'Position',[39.28, 33, 19.71 3]);
%         set(handles.play_averaged,'Position',[60, 33, 19.71 3]);
%         
%         
% end

% Set Value in solution_10 Subject Popupmenu for Josef and Georgios
switch(subject_id)
    
    case 103
    switch(current_db)
        case {'ari','universal'}
        set(handles.solution_subject,'Value',64);
    end
        
        
    case 104
    switch(current_db)
        case {'ari','universal'}
        set(handles.solution_subject,'Value',65);     
    end    
        
end

function varargout = gui_experiment_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function select_db_Callback(hObject, eventdata, handles)
clearvars -global DB ANGLES MEAN_SUB pcs weights v mn  
global DB
global ANGLES
global hrir_db_length
global current_db
global fs


% Import Database
all_dbs = get(handles.select_db,'String');
current_db = char(all_dbs(get(handles.select_db,'Value')));

[DB,~,~,ANGLES,~,hrir_db_length,~,~,~,~,fs,exp_sub] = db_import(current_db);
set(handles.database_size,'String', exp_sub);
set(handles.database_size,'Value', length(exp_sub));
set(handles.solution_subject,'Value',1);
set(handles.solution_subject,'String', 1:size(DB,1));

setButtons(hObject, eventdata, handles)

% Set the appropriate Values in the trajectories or location menus    
soundmode_Callback(hObject, eventdata, handles)
setStatusText(handles,'Click "Calc!" to update data',2)

function start_test(hObject, eventdata, handles)

% Calculate PCA of selected positions
clearvars -global MEAN_SUB pcs weights weights_reconstruct v mn  

global current_db
global DB
global MEAN_SUB
global weights
global pcs
global v
global mn
global current_positions

% Get FFT Points
all_points = (get(handles.fft_points,'String'));
fft_points = str2double(all_points(get(handles.fft_points,'Value')));

% PCA
set(handles.gui_process,'visible', 'on');
setProcessText(handles,'Processing - Wait!',1)
setStatusText(handles,'',0)
%set(handles.status_figure,'alpha','flat')
current_positions = get_positions(hObject, eventdata, handles);
[pcs,weights,v,mn,MEAN_SUB,subjects_list] = pca_get(1:getSubjects(hObject, eventdata, handles),current_positions,current_db,DB,get(handles.calc_mode,'Value'),get(handles.pca_mode,'Value'),1,1,get(handles.outliers,'Value'),fft_points,handles);

% Update GUI Elements
set(handles.solution_subject,'String',subjects_list)
set_playpos(hObject, eventdata, handles)
set_variance(hObject, eventdata, handles)
set_pcs(hObject, eventdata, handles)
UpdateSlidersText(hObject, eventdata, handles)
UpdateSliders(hObject, eventdata, handles)
setProcessText(handles,'',0)
set(handles.gui_process,'visible', 'off');

function play_averaged_Callback(hObject, eventdata, handles)
global fs
global current_positions
global weights
global stim
global eq_id


if(isempty(weights) == 0)
    
    subjects = getSubjects(hObject, eventdata, handles);
    position = get(handles.position,'Value');

    switch(get(handles.calc_mode,'Value'))
    
    case 1 % PCA1
    % Reconstruct PCA without slider change / = generalized HRTF set
    [hrir_reconstr_left,hrir_reconstr_right] = reconstr_pca1(hObject, eventdata, handles,mean(weights));
    
    % Play in loop
    if (get(handles.play_change,'Value') == 1 ) || (get(handles.soundmode,'Value') == 1)   
    play_pca1(hrir_reconstr_left,hrir_reconstr_right,get(handles.play_positions,'Value'),current_positions,fs,stim,eq_id);  
    end
    
    case 2 % PCA2
    % PCA Reconstruction without slider change    
    pos_start_left = subjects*(position-1)+1;
    pos_end_left = pos_start_left + subjects-1;
    
    weights_reconstruct = mean(weights(pos_start_left:pos_end_left,:));
    [hrir_reconstr_left,hrir_reconstr_right] = reconstr_pca2(hObject,eventdata,handles,weights_reconstruct);
    
    % Play selected source position
    if (get(handles.play_change,'Value') == 1 ) || (get(handles.soundmode,'Value') == 1)   
    play_sound([hrir_reconstr_left hrir_reconstr_right],fs,stim,eq_id);
    end
    
        
    case 3 % PCA3
    % PCA Reconstruction without slider change    
    pos_start = subjects*(position-1)+1;
    pos_end = pos_start + subjects-1;
    
    weights_reconstruct = mean(weights(pos_start:pos_end,:));
    [hrir_reconstr_left,hrir_reconstr_right] = reconstr_pca3(hObject,eventdata,handles,weights_reconstruct);
   
    % Play selected source position
    if (get(handles.play_change,'Value') == 1 ) || (get(handles.soundmode,'Value') == 1)   
    play_sound([hrir_reconstr_left hrir_reconstr_right],fs,stim,eq_id);
    end
    
    end
else
ErrorStart(hObject, eventdata, handles)
end

function play_tuning_Callback(hObject, eventdata, handles)
global weights

if(isempty(weights) == 0)
reconstruction(hObject, eventdata, handles,1)
else
ErrorStart(hObject, eventdata, handles)
end

function play_measured_Callback(hObject, eventdata, handles)
global DB
global fs
global current_positions
global current_db
global stim
global weights
global eq_id

if(isempty(weights) == 0)
play_measured(current_db,current_positions,DB,fs,get(handles.solution_subject,'Value'),get(handles.play_positions,'Value'),get(handles.soundmode,'Value'),get(handles.position,'Value'),stim,eq_id)  
else
ErrorStart(hObject, eventdata, handles)
end
function save_session_Callback(hObject, eventdata, handles)
global slider_saved

slider_saved = zeros(10,1);

for i=1:10   
     slider_name = sprintf('handles.slider%i',i);
     slider_saved(i) = get(eval(slider_name),'Value');
end

% % Save Subject Weights in File
% weights_file = sprintf('../matlabdata/experiment/sub_%i.mat',subject_id);   
%   
% if (exist(weights_file,'file') == 2)
%     load(weights_file,'weights');
%     disp('Saved')
% end
%         
% weights(:,experiment_position) = weights_experiment;
% save(weights_file,'weights','subject_id');    

function reset_slider_Callback(hObject, eventdata, handles)
global slider_intervall
global weights

if(isempty(weights) == 0)
    
    set(handles.solution_all,'Foregroundcolor','black')
    set(handles.solution_10,'Foregroundcolor','black')

    switch(get(handles.calc_mode,'Value'))
    
    case 1 % PCA1
    pca1_sliders(hObject, eventdata, handles,slider_intervall)
    
    case 2 % PCA2
    pca2_sliders( hObject, eventdata, handles,slider_intervall)    
        
    case 3 % PCA3
    pca3_sliders( hObject, eventdata, handles,slider_intervall)    
        
    end

reconstruction(hObject, eventdata, handles,0)

else
ErrorStart(hObject, eventdata, handles)  
end

function UpdateSliders(hObject, eventdata, handles)
global slider_intervall

slider_intervall = 3;

switch(get(handles.calc_mode,'Value'))
    
    case 1
    pca1_sliders(hObject, eventdata, handles,slider_intervall)
    
    case 2
    pca2_sliders(hObject, eventdata, handles,slider_intervall)
    
    case 3
    pca3_sliders(hObject, eventdata, handles,slider_intervall)    
      
end

function UpdateSlidersText(hObject, eventdata, handles)
global weights
global v

% Calculate standard deviation and for each PCW
std_dev = std(weights);

% Get weight numbers
if (length(v) < 10)
    weight_no = length(v);
else
    weight_no = 10;
end

% Sort descend by variance
for i=1:10
    
    if (weight_no >= i)
    slider_text{i} = sprintf('(%i) %2.2f%% (%2.2f)',i,v(i)/sum(v)*100,std_dev(i));
    else
    slider_text{i} = '';    
    end
end
        
set(handles.results_variance,'String', slider_text);

function set_variance(hObject, eventdata, handles)
global v
global current_db

% Get total Variance of selected pcs
total_var = 0;
total_var2 = 0;
selected_pcs = get_pcs_number(hObject, eventdata, handles);

if (selected_pcs > size(v,1))
    selected_pcs = size(v,1);
end

for i=1:selected_pcs
total_var = total_var + v(i);
end
   
% Find numbers of pcs for 90% variance
for i=1:length(v)
    if (i==1)
    total_var2(i) = v(i);
    else   
    total_var2(i) = total_var2(i-1) + v(i);
    end
end

total_var2 = total_var2/sum(v)*100;
pc_min = find(total_var2 >= 90);
pc_min = pc_min(1);

total_var = total_var/sum(v)*100;
switch(get(handles.pca_mode,'Value'))
    case 1
    text1 = 'DTFs subjects mean';    
    case 2
    text1 = 'DTFs global mean';      
    case 3
    text1 = 'HRIRs';      
end

switch(get(handles.soundmode,'Value'))
    case 1
    text2 = 'static position';    
    case 2
    text2 = 'trajecory';      
    case 3
    text2 = 'all positions';     
end


% Get FFT Points
all_points = (get(handles.fft_points,'String'));
fft_points = str2double(all_points(get(handles.fft_points,'Value')));


% Get Band Limit Value
if (get(handles.band_limit,'Value') ~= 1) && (get(handles.pca_mode,'Value') ~= 3) % no HRIR
    all_band = cellstr(get(handles.band_limit,'String'));
    band_limit_value = char(all_band(get(handles.band_limit,'Value')));
    band_limit_text = sprintf(' / BL %s',band_limit_value);
else
    band_limit_text = '';
end 

% Result Text
settings_text = sprintf('<html><b>%s / PCA%i / %s / %s / FFT %i%s</b></html>',upper(current_db),get(handles.calc_mode,'Value'),text1,text2,fft_points,band_limit_text);
total_variance_text = sprintf('%i PCs: %2.2f%% - %i PCs essential for 90%% variance',selected_pcs,total_var,pc_min); 

% Add new Result on Top in Popup menu
result_list = get(handles.result,{'string','value'});
set(handles.result,'string',{total_variance_text,result_list{1}{:}},'value',1)

% Add new Result on Top in Popup menu
result_list = get(handles.result,{'string','value'});
set(handles.result,'string',{settings_text,result_list{1}{:}},'value',2)

function reconstruction(hObject, eventdata, handles,soundmode)
global weights
global fs
global hrir_reconstr_left
global hrir_reconstr_right
global current_positions
global stim
global eq_id
global solution_mode

subjects = getSubjects(hObject, eventdata, handles);
position = get(handles.position,'Value');
sol_sub = get(handles.solution_subject,'Value');

switch(get(handles.calc_mode,'Value'))
    
case 1 % PCA1
    
    % PCA Reconstruction with 10 slider values and mean values of other
    % weights
    weights_reconstruct = mean(weights);
    
    for i=1:10   
    slider_name = sprintf('handles.slider%i',i);
    weights_reconstruct(i) = get(eval(slider_name),'Value');
    end
    
    % PCA Reconstruction with all correct weights
    if (solution_mode == 2 )
    weights_reconstruct(11:end) = weights(sol_sub,11:end);
    end
    
    [hrir_reconstr_left,hrir_reconstr_right] = reconstr_pca1(hObject,eventdata,handles,weights_reconstruct);
    
    % Play in loop
    if (get(handles.play_change,'Value') == 1 ) || (get(handles.soundmode,'Value') == 1)   
    play_pca1(hrir_reconstr_left,hrir_reconstr_right,get(handles.play_positions,'Value'),current_positions,fs,stim,eq_id);  
    end    
        
case {2,3} % PCA2, PCA3
    
     % Get Slider Values  
     weights_sliders = zeros(10,1);
     for i=1:10   
         slider_name = sprintf('handles.slider%i',i);
         weights_sliders(i) = get(eval(slider_name),'Value');
     end    
    
    % PCA Reconstruction with 10 slider values and mean values of other
    % weights
    pos_start = subjects*(position-1)+1;
    pos_end = pos_start + subjects-1;
    
    weights_reconstruct = mean(weights(pos_start:pos_end,:));
    weights_reconstruct(1:10) = weights_sliders;
    
    
    % PCA Reconstruction with all correct weights
    if (solution_mode == 2 )
    weights_reconstruct(11:end) = weights(pos_start + sol_sub-1,11:end);    
    end
    
    if (get(handles.calc_mode,'Value') == 2)
    [hrir_reconstr_left,hrir_reconstr_right] = reconstr_pca2(hObject,eventdata,handles,weights_reconstruct);
    end
    
    if (get(handles.calc_mode,'Value') == 3)
    [hrir_reconstr_left,hrir_reconstr_right] = reconstr_pca3(hObject,eventdata,handles,weights_reconstruct);
    end
    
    % Play Position
    if (get(handles.play_change,'Value') == 1 ) || (get(handles.soundmode,'Value') == 1)     
        play_sound([hrir_reconstr_left hrir_reconstr_right],fs,stim,eq_id);
    end
    
end

function reconstruct_pcs_Callback(hObject, eventdata, handles)
global weights

if(isempty(weights) == 0)
    set_variance(hObject, eventdata, handles)
    pause(0.001)
    reconstruction(hObject, eventdata, handles,0)
else
ErrorStart(hObject, eventdata, handles)    
end

function soundmode_Callback(hObject, eventdata, handles)
global ANGLES
global current_db


switch (get(handles.soundmode,'Value'))
    
case {1,3} % static source position   
  
    set(handles.text_position,'String', 'azimuth / elevation');
    set(handles.positions_text,'visible','off');
    set(handles.play_positions,'visible','off');
    set(handles.position,'Value', 1);
    set(handles.position,'String',source_list(current_db,ANGLES));
       
case 2 % trajectories
      
    set(handles.text_position,'String', 'trajectories');
    set(handles.positions_text,'visible','on');
    set(handles.play_positions,'visible','on');
    set(handles.position,'Value', 1);
    set(handles.position,'String',trajectory_list(current_db,ANGLES));
       
end




setStatusText(handles,'Click "Calc!" to update data',2)
setSlidersExtend(hObject, eventdata, handles)

function admin_off_Callback(hObject, eventdata, handles)
set(handles.select_db,'visible','off');
set(handles.db_text,'visible','off');
set(handles.database_size,'visible','off');
set(handles.text_numbers,'visible','off');
set(handles.text_position,'visible','off');
set(handles.position,'visible','off');
set(handles.calc_mode,'visible','off');
set(handles.calc_mode_text,'visible','off');
set(handles.mode_text,'visible','off');
set(handles.soundmode,'visible','off');
set(handles.positions_text,'visible','off');
set(handles.play_positions,'visible','off');
set(handles.pca_mode,'visible','off');
set(handles.pca_mode_text,'visible','off');
set(handles.band_limit,'visible','off');
set(handles.calc,'visible','off');
set(handles.band_limit_text,'visible','off');
set(handles.gui_status,'visible','off');
set(handles.outliers,'visible','off');
set(handles.fft_points,'visible','off');
set(handles.fft_points_text,'visible','off');
set(handles.az_extend,'visible','off');
set(handles.el_extend,'visible','off');
set(handles.az_extend_text,'visible','off');
set(handles.el_extend_text,'visible','off');
set(handles.panel_play,'visible','off');
set(handles.panel_plot,'visible','off');
set(handles.panel_results,'visible','off');
set(handles.panel_extend,'visible','off');
set(handles.solution_10,'visible','off');
set(handles.solution_subject,'visible','off');
set(handles.solution_all,'visible','off');
set(handles.admin_off,'visible','off');
set(handles.admin_on,'visible','on');

function admin_on_Callback(hObject, eventdata, handles)
set(handles.select_db,'visible','on');
set(handles.db_text,'visible','on');
set(handles.database_size,'visible','on');
set(handles.text_numbers,'visible','on');
set(handles.text_position,'visible','on');
set(handles.position,'visible','on');
set(handles.calc_mode,'visible','on');
set(handles.calc_mode_text,'visible','on');
set(handles.soundmode,'visible','on');
set(handles.mode_text,'visible','on');
set(handles.calc,'visible','on');
set(handles.pca_mode,'visible','on');
set(handles.pca_mode_text,'visible','on');
set(handles.band_limit,'visible','on');
set(handles.band_limit_text,'visible','on');
set(handles.outliers,'visible','on');
set(handles.positions_text,'visible','on');
set(handles.gui_status,'visible','on');
set(handles.play_positions,'visible','on');
set(handles.fft_points,'visible','on');
set(handles.fft_points_text,'visible','on');
set(handles.az_extend,'visible','on');
set(handles.el_extend,'visible','on');
set(handles.az_extend_text,'visible','on');
set(handles.el_extend_text,'visible','on');
set(handles.panel_play,'visible','on');
set(handles.panel_plot,'visible','on');
set(handles.panel_results,'visible','on');
set(handles.panel_extend,'visible','on');
set(handles.solution_10,'visible','on');
set(handles.solution_subject,'visible','on');
set(handles.solution_all,'visible','on');
set(handles.admin_off,'visible','on');
set(handles.admin_on,'visible','off');

function sort_mode_Callback(hObject, eventdata, handles)
UpdateSliders(hObject, eventdata, handles)
reconstruction(hObject, eventdata, handles,0)

function sliderChange_Callback(hObject, eventdata, handles)
global weights

if(isempty(weights) == 0)
set(handles.solution_10,'Foregroundcolor','black')
reconstruction(hObject, eventdata, handles,0)
else
ErrorStart(hObject, eventdata, handles)
end

function show_axes_Callback(hObject, eventdata, handles)

function show_data(hObject, eventdata, handles)

global hrir_reconstr_left
global hrir_reconstr_right
global measured_left
global measured_right
global fs

if (get(handles.plot_hrir_left,'Value') == 1)

if (get(handles.select_db,'Value') ==3) || (get(handles.select_db,'Value') ==5)
    
    % Perform FFT
    [fft_measured_left,~,freq_measured_left] = perform_fft(measured_left(:,1),fs);
    [fft_measured_right,~,freq_measured_right] = perform_fft(measured_right(:,1),fs);
    
    [fft_reconstruct_left,~,freq_reconstruct_left] = perform_fft(hrir_reconstr_left(:,1),fs);
    [fft_reconstruct_right,~,freq_reconstruct_right] = perform_fft(hrir_reconstr_right(:,1),fs);

% Plot in new figure
figure(1);clf;
subplot(2,1,1);
hold on;
plot(freq_reconstruct_left,fft_reconstruct_left,'r');
hold on
plot(freq_measured_left,fft_measured_left,'b');

subplot(2,1,2);
hold on;
plot(freq_reconstruct_right,fft_reconstruct_right,'r');
hold on
plot(freq_measured_right,fft_measured_right,'b');


% Set focus to gui again

fig = gcbf;

figure(fig)

end

end

function solution_subject_Callback(hObject, eventdata, handles)
global weights
if(isempty(weights) == 0)
solution_perform(hObject, eventdata, handles)
else
ErrorStart(hObject, eventdata, handles)    
end

function solution_perform(hObject, eventdata, handles)
global weights
global subjects

% Set Slider Values for specific person
position = get(handles.position,'Value');
sol_sub = get(handles.solution_subject,'Value');

% check size of weights
if (size(weights,2) < 10)
    slider_numbers = size(weights,2);
else
    slider_numbers = 10;
end

switch(get(handles.calc_mode,'Value'))
        
        case 1 % PCA 1
        for i=1:slider_numbers
        slider_name = sprintf('handles.slider%i',i);
        set(eval(slider_name),'Value',weights(sol_sub,i));
        end     

        case {2,3} % PCA2, PCA3
            
        if (get(handles.soundmode,'Value') == 1)
        pos_start = 1;
        end
        
        if (get(handles.soundmode,'Value') == 2) || (get(handles.soundmode,'Value') == 3)
        pos_start = subjects*(position-1)+1;
        end 
        
        for i=1:slider_numbers
        slider_name = sprintf('handles.slider%i',i);
        set(eval(slider_name),'Value',weights(pos_start + sol_sub-1,i));
        end    
                  
end

reconstruction(hObject, eventdata, handles,0)

function solution_10_Callback(hObject, eventdata, handles)
global weights
global solution_mode

if(isempty(weights) == 0)

    set(handles.solution_all,'Foregroundcolor','black')
    set(handles.solution_10,'Foregroundcolor','red')
    solution_mode = 1;
    solution_perform(hObject, eventdata, handles)
else
    ErrorStart(hObject, eventdata, handles)   
end

function solution_all_Callback(hObject, eventdata, handles)
global weights
global solution_mode

if(isempty(weights) == 0)
    set(handles.solution_all,'Foregroundcolor','red')
    set(handles.solution_10,'Foregroundcolor','black')
    solution_mode = 2;
    solution_perform(hObject, eventdata, handles)
else
    ErrorStart(hObject, eventdata, handles)   
end

function sphere_Callback(hObject, eventdata, handles)

figure(2)

[a,b,c] = sphere(24);

h= surf(a,b,c);
set(h,'FaceAlpha',0.2); 
axis image

hold on

r=1.1;
az=90;
el=0;
plot3(r*sin(az)*cos(el), r*sin(az)*sin(el), r*cos(az), 'r*', 'MarkerSize',10,'LineWidth',5);
axis square

hold off

function plot_hrirs_Callback(hObject, eventdata, handles)

global hrir_reconstr_left
global hrir_reconstr_right
global measured_left
global measured_right
global avg_hrir_left
global avg_hrir_right

switch (get(handles.pca_mode,'Value'))
    
    case 1
    title_text = 'DTF with subject mean';
    case 2
    title_text = 'DTF with global mean';  
    case 3
    title_text = 'HRIR';    
end
    

figure
plot(reshape(measured_left,1,size(measured_left,1)*size(measured_left,2)),'g');
hold on
plot(reshape(avg_hrir_left,1,size(avg_hrir_left,1)*size(avg_hrir_left,2)));
hold on
plot(reshape(hrir_reconstr_left,1,size(hrir_reconstr_left,1)*size(hrir_reconstr_left,2)),'r');
title(title_text)

legend('Measured','Averaged','Reconstructed')

function calc_Callback(hObject, eventdata, handles)
start_test(hObject, eventdata, handles)

function position_Callback(hObject, eventdata, handles)
global weights


if (isempty(weights) == 0) && (get(handles.soundmode,'Value') == 3)

    % refresh sliders for trajectories / all positions
      UpdateSliders(hObject, eventdata, handles)
      
else
setStatusText(handles,'Click "Calc!" to update data',2)
end

function database_size_Callback(hObject, eventdata, handles)
setStatusText(handles,'Click "Calc!" to update data',2)

function calc_mode_Callback(hObject, eventdata, handles)
setStatusText(handles,'Click "Calc!" to update data',2)
setSlidersExtend(hObject, eventdata, handles)

if (get(handles.calc_mode,'Value') == 1)
set(handles.outliers,'visible','on');
else
set(handles.outliers,'visible','off');
end

function pca_mode_Callback(hObject, eventdata, handles)

if (get(handles.pca_mode,'Value') == 1)
    set(handles.add_mean,'Visible','on')
else
    set(handles.add_mean,'Visible','off')
end

setStatusText(handles,'Click "Calc!" to update data',2)

function band_limit_Callback(hObject, eventdata, handles)
setStatusText(handles,'Click "Calc!" to update data',2)

function outliers_Callback(hObject, eventdata, handles)
setStatusText(handles,'Click "Calc!" to update data',2)

function fft_points_Callback(hObject, eventdata, handles)

% Get FFT Points
all_points = (get(handles.fft_points,'String'));
fft_points = str2double(all_points(get(handles.fft_points,'Value')));

switch (fft_points)
    case 2048
    values_string = 'no|256|128|64|32|16|8|4|2';   
    case 1024
    values_string = 'no|128|64|32|16|8|4|2';     
    case 512
    values_string = 'no|64|32|16|8|4|2';     
    case 256
    values_string = 'no|32|16|8|4|2';     
    case 128
    values_string = 'no|16|8|4|2';    
    case 64
    values_string = 'no|8|4|2';    
    case 32
    values_string = 'no|4|2';    
    case 16
    values_string = 'no|2';    
    case 8
    values_string = 'no|2';     
end

set(handles.band_limit,'Value', 1);
set(handles.band_limit,'String', values_string);
setStatusText(handles,'Click "Calc!" to update data',2)

function sound_stimulus_Callback(hObject, eventdata, handles)
global stim
global fs
global weights

if(isempty(weights) == 0)
    [ stim ] = import_sound(get(handles.sound_stimulus,'Value'),fs);
    reconstruction(hObject, eventdata, handles,0)
else
    ErrorStart(hObject, eventdata, handles)
end

function az_extend_Callback(hObject, eventdata, handles)
global weights

if(isempty(weights) == 0)
UpdateSliders(hObject, eventdata, handles)
else
ErrorStart(hObject, eventdata, handles)  
end

function el_extend_Callback(hObject, eventdata, handles)
global weights

if(isempty(weights) == 0)
UpdateSliders(hObject, eventdata, handles)
else
ErrorStart(hObject, eventdata, handles) 
end

function setSlidersExtend(hObject, eventdata, handles)

if (get(handles.calc_mode,'Value') ~= 1) && (get(handles.soundmode,'Value') == 3)
set(handles.panel_extend,'visible','on');
else
set(handles.panel_extend,'visible','off');
end

function plot_pcw_Callback(hObject, eventdata, handles)
if (get(handles.plot_pcw,'Value') == 0) && (ishandle(4)==1)
   close(4) 
end

function plot_pcw_no_Callback(hObject, eventdata, handles)

function plot_hrtf_left_Callback(hObject, eventdata, handles)
if (get(handles.plot_hrtf_left,'Value') == 0) && (ishandle(3) == 1)
   close(3) 
end

function plot_hrir_left_Callback(hObject, eventdata, handles)
if (get(handles.plot_hrir_left,'Value') == 0) && (ishandle(2)==1)
   close(2) 
end

function plot_hrtf_right_Callback(hObject, eventdata, handles)
if (get(handles.plot_hrtf_right,'Value') == 0) && (ishandle(6) == 1)
   close(6) 
end

function plot_hrir_right_Callback(hObject, eventdata, handles)
if (get(handles.plot_hrir_right,'Value') == 0) && (ishandle(7)==1)
   close(7) 
end

function add_mean_Callback(hObject, eventdata, handles)
global weights

if(isempty(weights) == 0)
reconstruction(hObject, eventdata, handles,0)
else
ErrorStart(hObject, eventdata, handles)    
end

function headphone_eq_Callback(hObject, eventdata, handles)
global eq_id
global weights

if(isempty(weights) == 0)
eq_id = get(handles.headphone_eq,'Value');
reconstruction(hObject, eventdata, handles,0)
else
ErrorStart(hObject, eventdata, handles)
end

function load_session_Callback(hObject, eventdata, handles)
global slider_saved

for i=1:10   
     slider_name = sprintf('handles.slider%i',i);
     set(eval(slider_name),'Value',slider_saved(i));
end

function ErrorStart(hObject, eventdata, handles)
msgbox('Click "Calc" to begin','Error','help')  
