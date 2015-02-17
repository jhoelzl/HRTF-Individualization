function varargout = gui_cor_anthro(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_cor_anthro_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_cor_anthro_OutputFcn, ...
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

% --- Executes just before gui_cor_anthro is made visible.
function gui_cor_anthro_OpeningFcn(hObject, eventdata, handles, varargin)
global w_l
global w_r
global anthro_data
global az
global el
global angles
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_cor_anthro (see VARARGIN)

% Choose default command line output for gui_cor_anthro
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

set(handles.pcnr,'String', [1:10]);
%set(handles.anthro_data,'String', [1:67]);


% Import HRIR DATA
fft_points = 256;
[hrirs,~,~,angles] = db_import('cipic');
data_dtf = abs(fft(hrirs,fft_points,4));
data_dtf = data_dtf(:,:,:,1:fft_points/2);

% Substract Mean
m_s = mean(data_dtf,2); % Mean Across Angles
data_dtf = data_dtf - repmat(m_s,[1 size(hrirs,2) 1 1]);

az = unique(angles(:,1));
el = unique(angles(:,2)); 

% Reshape
pca_in_l = reshape(squeeze(data_dtf(:,:,1,:)),[],fft_points/2);
pca_in_r = reshape(squeeze(data_dtf(:,:,2,:)),[],fft_points/2);

% PCA
[~, w_l] = princomp(pca_in_l,'econ');
[~, w_r] = princomp(pca_in_r,'econ');

% Weights for Left and Right Ear
w_l = reshape(w_l,size(squeeze(data_dtf(:,:,1,:))));
w_r = reshape(w_r,size(squeeze(data_dtf(:,:,2,:))));

[anthro_data] = get_cipic_anthro();
plotdata(hObject, eventdata, handles)


function plotdata(hObject, eventdata, handles)
global w_l
global w_r
global anthro_data
global el
global az
global angles

pcw = get(handles.pcnr,'Value');
choose_anthro = get(handles.anthro_data,'Value');
ear = get(handles.data,'Value');
data_anthro = anthro_data(:,choose_anthro);

if (ear == 1)
data_weights = squeeze(w_l(:,:,pcw));
data_text = 'Weight Left';
else
data_weights = squeeze(w_r(:,:,pcw));
data_text = 'Weight Right';
end

data_weights = reshape(data_weights,45,25,50,1);
%ae = reshape(angles,25,50,1);
% Get Anthro Text
Selection = get(handles.anthro_data,'String'); 
handles.Selection = Selection; 
all_data = Selection;
anthro_text = all_data(choose_anthro);

text = sprintf('Correlation between %s No.%i and %s',data_text,pcw,anthro_text{1});

corrdata = zeros(25,50);

for i=1:25
    for j=1:50
    R = corrcoef(squeeze(data_weights(:,i,j)),data_anthro);
    corrdata(i,j) = sign(R(2,1))*sqrt(abs(R(2,1)));
    end     
end


%min(min(corrdata))
%max(max(corrdata))



axes(handles.axes1)
cla;
%figure
surface(el,az,corrdata);
ylabel('Azimuth')
xlabel('Elevation')
title(text)


% --- Outputs from this function are returned to the command line.
function varargout = gui_cor_anthro_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;


function pcnr_Callback(hObject, eventdata, handles)
plotdata(hObject, eventdata, handles)

function pcnr2_Callback(hObject, eventdata, handles)
plotdata(hObject, eventdata, handles)


function pcnr2_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function anthro_data_Callback(hObject, eventdata, handles)
plotdata(hObject, eventdata, handles)

function back_Callback(hObject, eventdata, handles)

anthro_val_current = get(handles.anthro_data,'Value');

if (anthro_val_current > 1)

set(handles.anthro_data,'Value',anthro_val_current-1);

plotdata(hObject, eventdata, handles)
end

function next_Callback(hObject, eventdata, handles)

anthro_val_current = get(handles.anthro_data,'Value');

if (anthro_val_current < 67)
set(handles.anthro_data,'Value',anthro_val_current+1);
plotdata(hObject, eventdata, handles)
end


function cor_Callback(hObject, eventdata, handles)
plotdata(hObject, eventdata, handles)


function data_Callback(hObject, eventdata, handles)
plotdata(hObject, eventdata, handles)
