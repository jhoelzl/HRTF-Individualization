function listen_single_hrtf(hObject, eventdata, handles)

% Listen single HRTF
global current_db
global DB
global current_elevation
global current_azimuth
global current_subject
global fs
global ANGLES
global hrir_db_length
global azimuth_real
global elevation_real

% Get All Elevation Listbox values
current_elevation = get(handles.elevation,'Value'); 
all_elevation = str2num(get(handles.elevation,'String'));
elevation_real = all_elevation(current_elevation);

% Get All Azimuth Listbox values
current_azimuth = get(handles.azimuth,'Value'); 
all_azimuth = str2num(get(handles.azimuth,'String'));
azimuth_real = all_azimuth(current_azimuth);


% Get Subject
Selection = get(handles.subject,'Value'); 
handles.Selection = Selection; 
current_subject = Selection;


if (strcmp(current_db,'universal') == 1)
    [row,hrir_db_length,fs] = get_matrixvalue_universal(elevation_real,azimuth_real,current_subject,ANGLES);        
else
    row = get_matrixvalue(azimuth_real,elevation_real,ANGLES);  
end

out_left = squeeze(double(DB(current_subject,row,1,1:hrir_db_length)));
out_right = squeeze(double(DB(current_subject,row,2,1:hrir_db_length)));

 stim = stimulus2(20,500,fs);
play_sound([out_left'; out_right'],1,fs,stim,0,0,0,0);


%play_sound(hrir_reconstr_left,hrir_reconstr_right,current_positions,fs,stim,rir,eq_id,silence,play_simul)


%% Enable Smooth FFT
% if(get(handles.play_smooth,'Value') == 1)
% 
% % Smooth DTF / HRTF Options
%     switch get(handles.fft_smooth,'Value')
%         case 1
%         intervall = 1;     
%         case 2
%         intervall = 2;    
%         case 3
%         intervall = 5;
%         case 4
%         intervall = 10;
%         case 5
%         intervall = 15;
%         case 6 
%         intervall = 20;  
%         case 7
%         intervall = 30;  
%     end
%     
% 
% left_fft = fft(out_left,1024);
% right_fft = fft(out_right,1024);
% 
% Pll = abs(left_fft).^2;
% Prr = abs(right_fft).^2;
% 
% Pll = Pll(1:intervall:end);
% Prr = Prr(1:intervall:end);
% 
% %zeropadding = 1024-length(Pll);
% 
% %Pll = [Pll; zeros(zeropadding,1)];
% %Prr = [Prr; zeros(zeropadding,1)];
% 
% construct_left = real(ifft(sqrt(Pll),1024));
% construct_right = real(ifft(sqrt(Prr),1024));
% 
% play_sound([construct_left'; construct_right' ],44100);
% 
% end
    
end
