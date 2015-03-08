function varargout = gui_cor(varargin)
% GUI_COR M-file for gui_cor.fig
%      GUI_COR, by itself, creates a new GUI_COR or raises the existing
%      singleton*.
%
%      H = GUI_COR returns the handle to a new GUI_COR or the handle to
%      the existing singleton*.
%
%      GUI_COR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_COR.M with the given input arguments.
%
%      GUI_COR('Property','Value',...) creates a new GUI_COR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_cor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_cor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_cor

% Last Modified by GUIDE v2.5 17-Nov-2011 10:07:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_cor_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_cor_OutputFcn, ...
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

% --- Executes just before gui_cor is made visible.
function gui_cor_OpeningFcn(hObject, eventdata, handles, varargin)
global azimuth_angles
global elevation_angles

% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_cor (see VARARGIN)

% Choose default command line output for gui_cor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


azimuth_angles = [-80 -65 -55 -45:5:45 55 65 80];
elevation_angles = -45 + 5.625*(0:49);

set(handles.azimuth,'String', azimuth_angles);
set(handles.elevation,'String', elevation_angles);

set(handles.database,'Value',1);
set(handles.azimuth,'Value',13);
set(handles.elevation,'Value',9);

set(handles.pcnr1,'String', [1:10]);
set(handles.pcnr2,'String', [1:10]);

plotdata(hObject, eventdata, handles)

% UIWAIT makes gui_cor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function plotdata(hObject, eventdata, handles)
global data_text
global DATA_COR

% get gui selection
data_mode = get(handles.data,'Value');

switch data_mode
    
    case 1
    data_text = 'Weight';  
    data_text2 = 'weight of selected position';  
    data_text3 = 'weight of all other positions';
    set(handles.group,'String', 'group weights');
    
    case 2
    data_text = 'Weight';  
    data_text2 = 'weight of selected position';  
    data_text3 = 'weight of all other positions';
    set(handles.group,'String', 'group weights');
    
    case 3
    data_text = 'Weight';  
    data_text2 = 'weight of selected position';  
    data_text3 = 'weight of all other positions';
    set(handles.group,'String', 'group weights');
    
    case 4
    data_text = 'PC';  
    data_text2 = 'pc of selected position';  
    data_text3 = 'pc of all other positions';  
    set(handles.group,'String', 'group pcs');
        
    case 5
    data_text = 'PC';   
    data_text2 = 'pc of selected position';  
    data_text3 = 'pc of all other positions';  
    set(handles.group,'String', 'group pcs');
    
    case 6
    data_text = 'PC';   
    data_text2 = 'pc of selected position';  
    data_text3 = 'pc of all other positions';  
    set(handles.group,'String', 'group pcs');
    
    
end


set(handles.pc1_text,'String', data_text2);
set(handles.pc2_text,'String', data_text3);

az_val = get(handles.azimuth,'Value');
el_val = get(handles.elevation,'Value');

pc_val1 = get(handles.pcnr1,'Value');
pc_val2 = get(handles.pcnr2,'Value');

if (get(handles.database,'Value') ==1)
    DATA_COR = cipic_cor(data_mode,'cor',az_val,el_val,pc_val1,pc_val2);
else
    
    DATA_COR = global_cor(data_mode,'cor',az_val,el_val,pc_val1,pc_val2);
end

plotsurface(hObject, eventdata, handles)



function plotsurface(hObject, eventdata, handles)
global azimuth_angles
global elevation_angles
global DATA_COR
global data_text


az_val = get(handles.azimuth,'Value');
el_val = get(handles.elevation,'Value');

pc_val1 = get(handles.pcnr1,'Value');
pc_val2 = get(handles.pcnr2,'Value');

azimuth_real = azimuth_angles(az_val);
elevation_real = elevation_angles(el_val);

text = sprintf('Correlation between %s No.%i of Azimuth (%d), Elevation (%2.3f) and %s No.%i of all other positions',data_text,pc_val1,azimuth_real,elevation_real,data_text,pc_val2);

axes(handles.axes1)
cla;

% visualize only more than 0.75%
if (get(handles.cor,'Value') ==1)
DATA_COR_1 = DATA_COR;
DATA_COR_1(find(DATA_COR_1<0.75))=0;
surface(elevation_angles,azimuth_angles,DATA_COR_1);
%surface(DATA_COR_1);
% visualize all data
else
surface(elevation_angles,azimuth_angles,DATA_COR);
end

ylabel('Azimuth')
xlabel('Elevation')
colorbar
title(text)
if (get(handles.database,'Value') ==1)
axis([-45 230.625 -80 80])
else
axis([-30 45 0 315]) 
end



% --- Outputs from this function are returned to the command line.
function varargout = gui_cor_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;



function data_Callback(hObject, eventdata, handles)
if (get(handles.calc_change,'Value') == 1)
plotdata(hObject, eventdata, handles)
end

function data_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function elevation_Callback(hObject, eventdata, handles)
if (get(handles.calc_change,'Value') == 1)
plotdata(hObject, eventdata, handles)
end

function elevation_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function azimuth_Callback(hObject, eventdata, handles)
if (get(handles.calc_change,'Value') == 1)
plotdata(hObject, eventdata, handles)
end

function azimuth_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pcnr1_Callback(hObject, eventdata, handles)

if (get(handles.group,'Value') == 1)
pc_nr = get(handles.pcnr1,'Value');
set(handles.pcnr2,'Value',pc_nr);
end

if (get(handles.calc_change,'Value') == 1)
plotdata(hObject, eventdata, handles)
end

function pcnr1_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pcnr2_Callback(hObject, eventdata, handles)
if (get(handles.calc_change,'Value') == 1)
plotdata(hObject, eventdata, handles)
end

function pcnr2_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Untitled_1_Callback(hObject, eventdata, handles)


function calc_change_Callback(hObject, eventdata, handles)


function calculate_Callback(hObject, eventdata, handles)
plotdata(hObject, eventdata, handles)


function group_Callback(hObject, eventdata, handles)


function cor_Callback(hObject, eventdata, handles)
plotsurface(hObject, eventdata, handles)


function database_Callback(hObject, eventdata, handles)
global azimuth_angles
global elevation_angles


if (get(handles.database,'Value') ==1)
    % CIPIC
    azimuth_angles = [-80 -65 -55 -45:5:45 55 65 80];
    elevation_angles = -45 + 5.625*(0:49);

    set(handles.azimuth,'String', azimuth_angles);
    set(handles.elevation,'String', elevation_angles);

    set(handles.azimuth,'Value',13);
    set(handles.elevation,'Value',9);

else
    % GLOBAL
    azimuth_angles = [0 45 90 180 270 315];
    elevation_angles = [-30 -15 0 15 30 45];
    
    set(handles.elevation,'String', elevation_angles);
    set(handles.azimuth,'String', azimuth_angles);
    
    set(handles.elevation,'Value',3);
    set(handles.azimuth,'Value',1);
    
end

plotdata(hObject, eventdata, handles)


function database_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
