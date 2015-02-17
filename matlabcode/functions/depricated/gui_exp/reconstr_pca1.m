function [hrir_reconstr_left,hrir_reconstr_right] = reconstr_pca1(hObject,eventdata,handles,weights_reconstruct)

global mn
global pcs
global MEAN_SUB
global current_positions
global hrir_db_length
global DB
global fs

% Gui Elements
select_pcs = get_pcs_number(hObject, eventdata, handles);
pca_mode = get(handles.pca_mode,'Value');
play_positions = get(handles.play_positions,'Value');
sol_index = get(handles.solution_subject,'Value');
sol_sub_value = get(handles.solution_subject,'Value');
sol_sub_list = str2num(get(handles.solution_subject,'String'));
sol_sub = sol_sub_list(sol_sub_value);

% PCA Reconstruction
data_reconstruct = (pcs(:,1:select_pcs) * weights_reconstruct(:,1:select_pcs)')' + mn;

% Init
c = 0;
signal_length = size(data_reconstruct,2)/length(current_positions)/2;

hrtf_mag_left = zeros(signal_length,length(current_positions));
hrtf_mag_right = zeros(signal_length,length(current_positions));

hrir_min_left = zeros(hrir_db_length,length(current_positions));
hrir_min_right = zeros(hrir_db_length,length(current_positions));

hrir_left_no = zeros(signal_length*2,length(current_positions));
hrir_right_no = zeros(signal_length*2,length(current_positions));

hrir_reconstr_left = zeros(hrir_db_length,length(current_positions));
hrir_reconstr_right = zeros(hrir_db_length,length(current_positions));
    
    
    for pos=1:length(current_positions)

        if (pca_mode <= 2) % PCA DTF MODE

            % Split DTF
            c=c+1;
            dtf_mag_l = data_reconstruct((c-1)*signal_length+1:c*signal_length)';

            c=c+1;
            dtf_mag_r = data_reconstruct((c-1)*signal_length+1:c*signal_length)';

            % DTF -> HRTF
            if (pca_mode == 1) && (get(handles.add_mean,'Value') == 1)
            % add subjects mean / use all means
            hrtf_mag_left(:,pos) = dtf_mag_l+ squeeze(mean(MEAN_SUB(:,1,1,:),1));
            hrtf_mag_right(:,pos) = dtf_mag_r + squeeze(mean(MEAN_SUB(:,1,2,:),1));
            end
            
            if (pca_mode == 1) && (get(handles.add_mean,'Value') == 2)
            % add subjects mean / add mean from selected subject
            hrtf_mag_left(:,pos) = dtf_mag_l+ squeeze(MEAN_SUB(sol_index,1,1,:));
            hrtf_mag_right(:,pos) = dtf_mag_r + squeeze(MEAN_SUB(sol_index,1,2,:));
            end
            
            if (pca_mode ==2)
            % add global mean    
            hrtf_mag_left(:,pos) = dtf_mag_l+ squeeze(MEAN_SUB(1,1,1,:));
            hrtf_mag_right(:,pos) = dtf_mag_r + squeeze(MEAN_SUB(1,1,2,:));    
            end
            
            % ITD
            [~,~,~,itd_samples] = calculate_itd(squeeze(DB(sol_sub,current_positions(pos),1,:)),squeeze(DB(1,current_positions(pos),2,:)));
            
            % IFFT - HRIR
            [hrir_reconstr_left(:,pos), hrir_reconstr_right(:,pos),hrir_left_no(:,pos),hrir_right_no(:,pos)] = ifft_minph(hrtf_mag_left(:,pos),hrtf_mag_right(:,pos),itd_samples,hrir_db_length);            
            

        else  % HRIR PCA MODE 
            
            % Split positions
            c=c+1;
            hrir_min_left(:,pos) = data_reconstruct((c-1)*signal_length+1:c*signal_length)';
            
            c=c+1;
            hrir_min_right(:,pos) = data_reconstruct((c-1)*signal_length+1:c*signal_length)';
            
            % Time alignment / ITD
            [~,~,~,itd_samples] = calculate_itd(squeeze(DB(sol_sub,current_positions(pos),1,:)),squeeze(DB(1,current_positions(pos),2,:)));
            [hrir_left,hrir_right] = itd_alignment(hrir_min_left(:,pos),hrir_min_right(:,pos),itd_samples);

            hrir_reconstr_left(:,pos) = hrir_left;
            hrir_reconstr_right(:,pos) = hrir_right;
            
        
        end


end

 % Get selected position for plotting
 
if (get(handles.soundmode,'Value') == 2) 
    % Trajectories
    
    if (play_positions > length(current_positions))
    play_positions = 1;
    end
    
    pca_position = current_positions(play_positions);
    
else
    % static position
    pca_position = get(handles.position,'Value');
    play_positions = 1;
    
end


% Plot HRIRs Left
if (get(handles.plot_hrir_left,'Value') == 1)
[~,hrir_orig_min_left] = rceps(squeeze(DB(sol_sub,pca_position,1,:)));
figure(2)
clf;
plot(hrir_orig_min_left,'b') 
hold on
plot(hrir_min_left(:,play_positions),'r')

title('HRIR Left Reconstruction')
legend('Measured','Reconstruction')
grid on
end

% Plot HRIRs Right
if (get(handles.plot_hrir_right,'Value') == 1)
[~,hrir_orig_min_right] = rceps(squeeze(DB(sol_sub,pca_position,2,:)));      
figure(7)
clf;
plot(hrir_orig_min_right,'b') 
hold on
plot(hrir_min_right(:,play_positions),'r')

title('HRIR Right Reconstruction')
legend('Measured','Reconstruction')
grid on
end

% Plot HRTFs Left from HRIR
if (get(handles.plot_hrtf_left,'Value') == 1) && (pca_mode == 3)
[~,hrir_orig_min_left] = rceps(squeeze(DB(sol_sub,pca_position,1,:)));
N = 1024;
freq = (0 : (N/2)-1) * fs / N;
hrtf_measured_left = 20*log10(2*abs(fft(hrir_orig_min_left,N)));
hrtf_reconstructed_left = 20*log10(2*abs(fft(hrir_min_left(:,play_positions),N)));

figure(3)
clf;
plot(freq,hrtf_measured_left(1:N/2),'b')
hold on
plot(freq,hrtf_reconstructed_left(1:N/2),'r')
grid on
    
rmse_left=rmse(hrtf_measured_left(1:N/2),hrtf_reconstructed_left(1:N/2));
title(sprintf('HRTF Left Reconstruction with %2.2f dB RMS error',rmse_left))
legend('Measured','Reconstruction')
end


% Plot HRTFs Right from HRIR
if (get(handles.plot_hrtf_right,'Value') == 1) && (pca_mode == 3)
[~,hrir_orig_min_right] = rceps(squeeze(DB(sol_sub,pca_position,2,:)));
N = 1024;
freq = (0 : (N/2)-1) * fs / N;
hrtf_measured_right = 20*log10(2*abs(fft(hrir_orig_min_right,N)));
hrtf_reconstructed_right = 20*log10(2*abs(fft(hrir_min_right(:,play_positions),N)));

figure(6)
clf;
plot(freq,hrtf_measured_right(1:N/2),'b')
hold on
plot(freq,hrtf_reconstructed_right(1:N/2),'r')  
    
rmse_right=rmse(hrtf_measured_right(1:N/2),hrtf_reconstructed_right(1:N/2));
title(sprintf('HRTF Right Reconstruction with %2.2f dB RMS error',rmse_right))
legend('Measured','Reconstruction')
end


% Plot HRTFs Left (only selected pos)
if (get(handles.plot_hrtf_left,'Value') == 1) && (pca_mode <= 2)
freq = (0 : (size(hrtf_mag_right,1))-1) * fs / (2*size(hrtf_mag_right,1));    
measured_hrtf_left = 20*log10(2*abs(fft(squeeze(DB(sol_sub,pca_position,1,:)),size(hrtf_mag_left,1)*2)));

figure(3)
clf;
plot(hrtf_mag_left(:,play_positions),'r')
hold on
semilogx(measured_hrtf_left(1:size(hrtf_mag_left,1)),'b')

title('HRTF Left Reconstruction')
legend('HRTF left Reconstruction','HRTF left measured') 
grid on

rmse_left=rmse(measured_hrtf_left(1:size(hrtf_mag_left,1)),hrtf_mag_left(:,play_positions));
title(sprintf('HRTF Left Reconstruction with %2.2f dB RMS error',rmse_left))
legend('Measured','Reconstruction')
end


% Plot HRTFs Right (only selected pos)
if (get(handles.plot_hrtf_right,'Value') == 1) && (pca_mode <= 2)
freq = (0 : (size(hrtf_mag_right,1))-1) * fs / (2*size(hrtf_mag_right,1)); 
measured_hrtf_right = 20*log10(2*abs(fft(squeeze(DB(sol_sub,pca_position,2,:)),size(hrtf_mag_left,1)*2)));
    
figure(6)
clf;
plot(hrtf_mag_right(:,play_positions),'r')
hold on
semilogx(measured_hrtf_right(1:size(hrtf_mag_right,1)),'b')
grid on

rmse_right=rmse(measured_hrtf_right(1:size(hrtf_mag_right,1)),hrtf_mag_right(:,play_positions));
title(sprintf('HRTF Right Reconstruction with %2.2f dB RMS error',rmse_right))
legend('HRTF right Reconstruction','HRTF right measured')   
end

end

