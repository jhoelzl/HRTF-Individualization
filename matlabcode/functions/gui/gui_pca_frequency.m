function varargout = gui_pca_frequency(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_pca_frequency_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_pca_frequency_OutputFcn, ...
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

function gui_pca_frequency_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_pca_frequency (see VARARGIN)

global current_pca
global weights

%% PERFORM PCA ANALYSIS
switch current_pca
    case 1
    % PCA on whole DB
    perform_pca_db(hObject, eventdata, handles);
    case 2   
    % PCA on whole Subject    
    perform_pca_subject(hObject, eventdata, handles);        
    case 3
    % PCA on selected Direction of all Subjects in selected DB    
    perform_pca_direction(hObject, eventdata, handles);
end

set(handles.slider1,'Value', 1);
set(handles.slider2,'Value', 1);
set(handles.slider3,'Value', 1);
set(handles.slider4,'Value', 1);
set(handles.slider5,'Value', 1);

reconstruct_nrs = 1:size(weights,1)/2;
set(handles.reconstruct_nr,'String', reconstruct_nrs);


set(handles.reconstruct_pcs,'Value', 5);
reconstruct_Callback(hObject, eventdata, handles,3) 

% Choose default command line output for gui_pca_frequency
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

function varargout = gui_pca_frequency_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;

function reconstruct_Callback(hObject, eventdata, handles,soundmode)
global weights_modified
global weights
global pcs
global mn
global MEAN_SUB
global dtf_original
global dtf_reconstruct
global data_reconstruct
global current_db
global DB
global ANGLES
global current_subject
global azimuth_real
global elevation_real
global current_pca
global fs
global hrir_db_length

% soundmode = 0: play original and reconstruction
% soundmode = 1: play original
% soundmode = 2: play reconstruction
% soundmode = 3: play reconstruction

% Get Numbers of PCs for Reconstructing
if (get(handles.reconstruct_pcs,'Value') == 11)
    dim = size(weights_modified,2);
else
    dim = get(handles.reconstruct_pcs,'Value');
end

reconstruct_nr = get(handles.reconstruct_nr,'Value');
data_reconstruct = reconstruct_pca(dim,weights_modified,pcs,mn);
data_reconstruct_ideal = reconstruct_pca(size(pcs,1),weights,pcs,mn);

% get Left DTF for GUI Plot
dtf_original = data_reconstruct_ideal(reconstruct_nr*2-1,:);
dtf_reconstruct = data_reconstruct(reconstruct_nr*2-1,:);

%% HRIR RECONSTRUCTION ON MINIMUMPHASE SYSTEM

% HRTF
hrtf_mag_left = data_reconstruct(reconstruct_nr*2-1,:) + squeeze(MEAN_SUB(reconstruct_nr,1,1,:))';
hrtf_mag_right = data_reconstruct(reconstruct_nr*2,:) + squeeze(MEAN_SUB(reconstruct_nr,1,2,:))';

% ITD
row_value = get_matrixvalue(azimuth_real,elevation_real,ANGLES);
[ ~,~,~,itd_samples] = calculate_itd(squeeze(DB(reconstruct_nr,row_value,1,:)),squeeze(DB(reconstruct_nr,row_value,2,:)));

% HRIR
[hrir_reconstr_left, hrir_reconstr_right] = ifft_minph(hrtf_mag_left,hrtf_mag_right,itd_samples,hrir_db_length);

    
%% HRIR ORIGINAL FROM DB

if (strcmp(current_db,'universal') == 1)
    
    switch(current_pca)
        case 1 
        % whole db
        universal_subject = ceil(reconstruct_nr / size(ANGLES,1));
        [~,hrir_length] = get_matrixvalue_universal(0,0,universal_subject);
        
        universal_value = reconstruct_nr - ((universal_subject-1)*size(ANGLES,1));
        
        hrir_left = squeeze(DB(universal_subject,universal_value,1,1:hrir_length));
        hrir_right = squeeze(DB(universal_subject,universal_value,2,1:hrir_length));
        
        case 2
        % one subject  
        [~,hrir_length] = get_matrixvalue_universal(0,0,reconstruct_nr);
        hrir_left = squeeze(DB(current_subject,reconstruct_nr,1,1:hrir_length));
        hrir_right = squeeze(DB(current_subject,reconstruct_nr,2,1:hrir_length));
        
        case 3
        % one direction
        [value,hrir_length] = get_matrixvalue_universal(elevation_real,azimuth_real,reconstruct_nr,ANGLES);
        hrir_left = squeeze(DB(reconstruct_nr,value,1,1:hrir_length));
        hrir_right = squeeze(DB(reconstruct_nr,value,2,1:hrir_length));
        
    end
    
else
    % all other dabatases
    
    switch(current_pca)
        case 1 
        % whole db
        sub1 = ceil(reconstruct_nr / size(ANGLES,1));
        row_value = reconstruct_nr - (sub1-1)*size(ANGLES,1);  
        
        hrir_left = squeeze(DB(sub1,row_value,1,:));
        hrir_right = squeeze(DB(sub1,row_value,2,:));
        
        case 2
        % one subject  
        hrir_left = squeeze(double(DB(current_subject,reconstruct_nr,1,:)));
        hrir_right = squeeze(double(DB(current_subject,reconstruct_nr,2,:)));
        
        case 3
        % one direction    
        row_value = get_matrixvalue(azimuth_real,elevation_real,ANGLES); 
        hrir_left = squeeze(double(DB(reconstruct_nr,row_value,1,:)));
        hrir_right = squeeze(double(DB(reconstruct_nr,row_value,2,:)));
    end
    
end
        
N = size(weights,2)*2;
freq = (0 : (N/2)-1) * fs / N;

% Plot DTF Left Reconstruction
axes(handles.reconstruct_hrtf_left)    
plot(freq,dtf_original)
grid on
hold on
plot(freq,dtf_reconstruct,'r-')
hold off;
title('DTF Reconstruction Left Ear');
legend('Original','Reconstruction')

% Plot HRIR Left Reconstruction and Original
axes(handles.hrir_left)    
plot(hrir_left)
grid on
hold on
plot(hrir_reconstr_left,'r')
hold off;
title('HRIR left');

% Plot HRIR Right Reconstruction and Original
axes(handles.hrir_right)    
plot(hrir_right)
grid on
hold on
plot(hrir_reconstr_right,'r')
hold off;
title('HRIR right');



if (get(handles.play_reconstruct_change,'Value') == 1) & (soundmode == 3)
% Play Reconstruction
play_sound([hrir_reconstr_left'; hrir_reconstr_right'],fs);
end

if (soundmode == 0)
% Play Original and Reconstruction
play_sound([hrir_left'; hrir_right'],fs);
pause(0.3)
play_sound([hrir_reconstr_left'; hrir_reconstr_right'],fs);
end

if (soundmode == 1)
% Play Original
play_sound([hrir_left'; hrir_right'],fs);
end

if (soundmode == 2)
% Play Reconstruction
play_sound([hrir_reconstr_left'; hrir_reconstr_right'],fs);
end

function reconstruct_pcs_Callback(hObject, eventdata, handles) 
global v
global weights_modified

% Get Numbers of PCs for Reconstructing
dim = get(handles.reconstruct_pcs,'Value');


if (get(handles.reconstruct_pcs,'Value') == 11)   
    total_var = 100;
    dim = size(weights_modified,2);
      
else

    total_var = 0;
    
    for i=1:dim
    total_var = total_var + v(i);
    end
    total_var = total_var / sum(v)*100;
    
end

% Total Variance

total_var = sprintf('Total Variance of first %i PCs: %2.2f ',dim,total_var);
total_var = [total_var,'%'];
set(handles.text_variance,'String', total_var);


reconstruct_Callback(hObject, eventdata, handles,3) 

function reconstruct_nr_Callback(hObject, eventdata, handles)
reconstruct_Callback(hObject, eventdata, handles,3) 

function play_reconstruct_Callback(hObject, eventdata, handles)
global data_reconstruct
global MEAN_SUB
global current_db
global current_azimuth
global current_elevation
global azimuth_real
global elevation_real
global DB
global DATA_DTF
global fs
global hrir_db_length
global ANGLES

reconstruct_nr = get(handles.reconstruct_nr,'Value');

% Get Original HRIR Datasets
if (strcmp(current_db,'universal') == 1)
    [row_value,hrir_length,fs] = get_matrixvalue_universal(azimuth_real,elevation_real,subject,ANGLES);
    hrir_left = squeeze(DB(reconstruct_nr,row_value,1,1:hrir_length))';
    hrir_right = squeeze(DB(reconstruct_nr,row_value,2,1:hrir_length))';
else
    
    row_value = get_matrixvalue(azimuth_real,elevation_real,ANGLES);
    hrir_left = squeeze(DB(reconstruct_nr,row_value,1,:))';
    hrir_right = squeeze(DB(reconstruct_nr,row_value,2,:))';
        
end

% ITD
[ ~,~,~,itd_samples] = calculate_itd(hrir_left,hrir_right);


%% HRIR ORIGINAL
% Magnitude Reconstruction of HRTF
hrtf_mag_left = DATA_DTF(:,reconstruct_nr*2-1) + MEAN_SUB(:,reconstruct_nr*2-1);
hrtf_mag_right = DATA_DTF(:,(reconstruct_nr*2)) + MEAN_SUB(:,(reconstruct_nr*2));

% Get Original HRTF Phase
hrtf_phase_left = DATA_PHASE(:,reconstruct_nr*2-1);
hrtf_phase_right = DATA_PHASE(:,(reconstruct_nr*2));

% Perform IFFT
[hrir_orig_left, hrir_orig_right] = perform_ifft(hrtf_mag_left,hrtf_mag_right,hrtf_phase_left,hrtf_phase_right,hrir_db_length);


%% HRIR RECONSTRUCTION
% Magnitude Reconstruction of HRTF
hrtf_mag_left = data_reconstruct(:,reconstruct_nr*2-1) + MEAN_SUB(:,reconstruct_nr*2-1);
hrtf_mag_right = data_reconstruct(:,(reconstruct_nr*2)) + MEAN_SUB(:,(reconstruct_nr*2));

% Get Original HRTF Phase
hrtf_phase_left = DATA_PHASE(:,reconstruct_nr*2-1);
hrtf_phase_right = DATA_PHASE(:,(reconstruct_nr*2));

% Perform IFFT
[hrir_reconstr_left, hrir_reconstr_right] = perform_ifft(hrtf_mag_left,hrtf_mag_right,hrtf_phase_left,hrtf_phase_right,hrir_db_length);


% Play Original and Reconstruction
play_sound([hrir_left'; hrir_right'],fs);
pause(0.3)
%play_sound([hrir_orig_left'; hrir_orig_right'],fs);
%pause(0.1)
play_sound([hrir_reconstr_left'; hrir_reconstr_right'],fs);

function slider1_Callback(hObject, eventdata, handles)
global weights
global weights_modified

score = weights(:,1);
new_value = get(handles.slider1,'Value');
weights_modified(:,1) = score * new_value;

reconstruct_Callback(hObject, eventdata, handles,3)

function slider2_Callback(hObject, eventdata, handles)
global weights
global weights_modified

score = weights(:,2);
new_value = get(handles.slider2,'Value');
weights_modified(:,2) = score * new_value;

reconstruct_Callback(hObject, eventdata, handles,3)

function slider3_Callback(hObject, eventdata, handles)
global weights
global weights_modified

score = weights(:,3);
new_value = get(handles.slider3,'Value');
weights_modified(:,3) = score * new_value;

reconstruct_Callback(hObject, eventdata, handles,3)

function slider5_Callback(hObject, eventdata, handles)
global weights
global weights_modified

score = weights(:,5);
new_value = get(handles.slider5,'Value');
weights_modified(:,5) = score * new_value;

reconstruct_Callback(hObject, eventdata, handles,3)

function slider4_Callback(hObject, eventdata, handles)
global weights
global weights_modified

score = weights(:,4);
new_value = get(handles.slider4,'Value');
weights_modified(:,4) = score * new_value;

reconstruct_Callback(hObject, eventdata, handles,3)

function show_sliders_Callback(hObject, eventdata, handles)
if(get(handles.show_sliders,'Value') == 1)
set(handles.slider1,'visible','on');
set(handles.slider2,'visible','on');
set(handles.slider3,'visible','on');
set(handles.slider4,'visible','on');
set(handles.slider5,'visible','on');
end

if(get(handles.show_sliders,'Value') == 0)
set(handles.slider1,'visible','off');
set(handles.slider2,'visible','off');
set(handles.slider3,'visible','off');
set(handles.slider4,'visible','off');
set(handles.slider5,'visible','off');
end

function reset_sliders_Callback(hObject, eventdata, handles)
global weights
global weights_modified

weights_modified = weights;

set(handles.slider1,'Value', 1);
set(handles.slider2,'Value', 1);
set(handles.slider3,'Value', 1);
set(handles.slider4,'Value', 1);
set(handles.slider5,'Value', 1);
reconstruct_Callback(hObject, eventdata, handles,3)

function reconstruct_mode_Callback(hObject, eventdata, handles)
reconstruct_Callback(hObject, eventdata, handles,2)
