function varargout = gui_weights_fluct(varargin)
% GUI_WEIGHTS_FLUCT M-file for gui_weights_fluct.fig
%      GUI_WEIGHTS_FLUCT, by itself, creates a new GUI_WEIGHTS_FLUCT or raises the existing
%      singleton*.
%
%      H = GUI_WEIGHTS_FLUCT returns the handle to a new GUI_WEIGHTS_FLUCT or the handle to
%      the existing singleton*.
%
%      GUI_WEIGHTS_FLUCT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_WEIGHTS_FLUCT.M with the given input arguments.
%
%      GUI_WEIGHTS_FLUCT('Property','Value',...) creates a new GUI_WEIGHTS_FLUCT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_weights_fluct_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_weights_fluct_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_weights_fluct

% Last Modified by GUIDE v2.5 16-Nov-2011 21:57:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_weights_fluct_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_weights_fluct_OutputFcn, ...
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


% --- Executes just before gui_weights_fluct is made visible.
function gui_weights_fluct_OpeningFcn(hObject, eventdata, handles, varargin)

global azimuth_angles
global elevation_angles
global weights_l
global weights_r

% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_weights_fluct (see VARARGIN)

% Choose default command line output for gui_weights_fluct
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_weights_fluct wait for user response (see UIRESUME)
% uiwait(handles.figure1);

azimuth_angles = [-80 -65 -55 -45:5:45 55 65 80];
elevation_angles = -45 + 5.625*(0:49);

set(handles.azimuth,'String', azimuth_angles);
set(handles.pcnr,'String', [1:10]);

[weights_l,weights_r] = explore_weights('cipic');

% Start Values
set(handles.azimuth,'Value',13);
plotdata(hObject, eventdata, handles)


% --- Outputs from this function are returned to the command line.
function varargout = gui_weights_fluct_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function data_Callback(hObject, eventdata, handles)
plotdata(hObject, eventdata, handles)

function data_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function plotdata(hObject, eventdata, handles)

global azimuth_angles
global elevation_angles

az = get(handles.azimuth,'Value');
pc = get(handles.pcnr,'Value');
data = get(handles.data,'Value');


file_name = sprintf('../matlabdata/cipic_fluct/WEIGHTS_%i.mat',az);

switch data
    case 1
    load(file_name,'WEIGHTS');
    DATA = WEIGHTS;    
        
    case 2
    load(file_name,'WEIGHTS_LEFT');
    DATA = WEIGHTS_LEFT;
    
    case 3
    load(file_name,'WEIGHTS_RIGHT');
    DATA = WEIGHTS_RIGHT;

end
    
c1 = 1;
c2 = 45;

DATA_MEAN = mean(DATA);
DATA_STD = std(DATA);



plot_title1 = sprintf('PCW %i across all elevations for azimuth %d',pc, azimuth_angles(az));
plot_title2 = sprintf('Mean PCW %i',pc);

axes(handles.axes1)
cla;

plot(DATA(:,pc))
hold on
plot(DATA_MEAN,'black','LineWidth',3)
title(plot_title1)



function azimuth_Callback(hObject, eventdata, handles)

plotdata(hObject, eventdata, handles)

function azimuth_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pcnr_Callback(hObject, eventdata, handles)
plotdata(hObject, eventdata, handles)


function pcnr_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
