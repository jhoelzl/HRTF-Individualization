function [ hrir_reconstr_left,hrir_reconstr_right ] = reconstr_pca2( hObject,eventdata,handles,weights_reconstruct )

global pcs
global mn
global MEAN_SUB
global hrir_db_length
global DB
global measured_available
global fs

select_pcs = get_pcs_number(hObject, eventdata, handles);
pca_position = get(handles.position,'Value');
pca_mode = get(handles.pca_mode,'Value');
sol_sub = get(handles.solution_subject,'Value');

% Store adjusted weights in GLOBAL_SCORES

if (pca_mode <= 2) % PCA DTF MODE
    
    % DTF
    reconstruct_left = (pcs(:,1:select_pcs) * weights_reconstruct(:,1:select_pcs)')' + mn;
    
    % HRTF
    if (get(handles.pca_mode,'Value') == 1) && (get(handles.add_mean,'Value') == 1)
    % subjects mean, all subjects
    hrtf_mag_left = squeeze(mean(MEAN_SUB(:,1,1,:),1))' + reconstruct_left;
    hrtf_mag_right = squeeze(mean(MEAN_SUB(:,1,1,:),1))' + reconstruct_left;
    end
    
    if (get(handles.pca_mode,'Value') == 1) && (get(handles.add_mean,'Value') == 2)
    % subjects mean, own mean
    hrtf_mag_left = squeeze(MEAN_SUB(sol_sub,1,1,:))' + reconstruct_left;
    hrtf_mag_right = squeeze(MEAN_SUB(sol_sub,1,1,:))' + reconstruct_left;
    end
    
    if (get(handles.pca_mode,'Value') == 2)
    % global mean
    hrtf_mag_left = squeeze(MEAN_SUB(1,1,1,:))' + reconstruct_left;
    hrtf_mag_right = squeeze(MEAN_SUB(1,1,1,:))' + reconstruct_left;
    end
    
    % ITD
    [~,~,~,itd_samples] = calculate_itd(squeeze(DB(sol_sub,pca_position,1,:)),squeeze(DB(1,pca_position,2,:)));

    % HRIR Reconstruction on MinPh
    [hrir_reconstr_left, hrir_reconstr_right,reconstruct_left,reconstruct_right] = ifft_minph(hrtf_mag_left,hrtf_mag_right,itd_samples,hrir_db_length);

else    
    % PCA HRIR MODE
    reconstruct_left = (pcs(:,1:select_pcs) * weights_reconstruct(:,1:select_pcs)')' + mn;
    reconstruct_right = reconstruct_left;
    
    % Time alignment / ITD
    [~,~,~,itd_samples] = calculate_itd(squeeze(DB(1,pca_position,1,:)),squeeze(DB(1,pca_position,2,:)));
    [hrir_reconstr_left,hrir_reconstr_right] = itd_alignment(reconstruct_left',reconstruct_right',itd_samples);
       
end

% Plot HRIRs Left
if (get(handles.plot_hrir_left,'Value') == 1)
[~,hrir_min_left] = rceps(squeeze(DB(sol_sub,pca_position,1,:)));
figure(2)
clf;
plot(hrir_min_left,'b') 
hold on
plot(reconstruct_left,'r')

title('HRIR Left Reconstruction')
legend('Measured','Reconstruction')
grid on
end

% Plot HRIRs Right
if (get(handles.plot_hrir_right,'Value') == 1)
[~,hrir_min_right] = rceps(squeeze(DB(sol_sub,pca_position,2,:)));      
figure(7)
clf;
plot(hrir_min_right,'b') 
hold on
plot(reconstruct_right,'r')

title('HRIR Right Reconstruction')
legend('Measured','Reconstruction')
grid on
end

% Plot HRTFs Left from HRIR
if (get(handles.plot_hrtf_left,'Value') == 1) && (pca_mode == 3)
[~,hrir_min_left] = rceps(squeeze(DB(sol_sub,pca_position,1,:)));
N = 1024;
freq = (0 : (N/2)-1) * fs / N;
hrtf_measured_left = 20*log10(2*abs(fft(hrir_min_left,N)));
hrtf_reconstructed_left = 20*log10(2*abs(fft(reconstruct_left,N)));

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
[~,hrir_min_right] = rceps(squeeze(DB(sol_sub,pca_position,2,:)));
N = 1024;
freq = (0 : (N/2)-1) * fs / N;
hrtf_measured_right = 20*log10(2*abs(fft(hrir_min_right,N)));
hrtf_reconstructed_right = 20*log10(2*abs(fft(reconstruct_right,N)));

figure(6)
clf;
plot(freq,hrtf_measured_right(1:N/2),'b')
hold on
plot(freq,hrtf_reconstructed_right(1:N/2),'r')  
    
rmse_right=rmse(hrtf_measured_right(1:N/2),hrtf_reconstructed_right(1:N/2));
title(sprintf('HRTF Right Reconstruction with %2.2f dB RMS error',rmse_right))
legend('Measured','Reconstruction')
end


% Plot HRTFs Left
if (get(handles.plot_hrtf_left,'Value') == 1) && (pca_mode <= 2)
freq = (0 : (size(hrtf_mag_right,2))-1) * fs / (2*size(hrtf_mag_right,2));    
measured_hrtf_left = 20*log10(2*abs(fft(squeeze(DB(sol_sub,pca_position,1,:)),length(hrtf_mag_left)*2)));

figure(3)
clf;
plot(freq,hrtf_mag_left,'r')
hold on
semilogx(freq,measured_hrtf_left(1:length(hrtf_mag_left)),'b')

title('HRTF Left Reconstruction')
legend('HRTF left Reconstruction','HRTF left measured') 
grid on

rmse_left=rmse(measured_hrtf_left(1:length(hrtf_mag_left)),hrtf_mag_left);
title(sprintf('HRTF Left Reconstruction with %2.2f dB RMS error',rmse_left))
legend('Measured','Reconstruction')
end


% Plot HRTFs Right
if (get(handles.plot_hrtf_right,'Value') == 1) && (pca_mode <= 2) 
freq = (0 : (size(hrtf_mag_right,2))-1) * fs / (2*size(hrtf_mag_right,2));
measured_hrtf_right = 20*log10(2*abs(fft(squeeze(DB(sol_sub,pca_position,2,:)),length(hrtf_mag_left)*2)));
    
figure(6)
clf;
plot(freq,hrtf_mag_right,'r')
hold on
semilogx(freq,measured_hrtf_right(1:length(hrtf_mag_left)),'b')
grid on

rmse_right=rmse(measured_hrtf_right(1:length(hrtf_mag_left)),hrtf_mag_right);
title(sprintf('HRTF Left Reconstruction with %2.2f dB RMS error',rmse_right))
legend('HRTF right Reconstruction','HRTF right measured')   
end

%Plot for Report

% figure(3)
% %clf;
% freq = (0 : (size(hrtf_mag_right,2))-1) * fs / (2*size(hrtf_mag_right,2));
% freq = freq/ 1000;
% hold on
% plot(freq,hrtf_mag_left,'b')
% plot(freq,hrtf_mag_left,'r','LineWidth',2)
% xlabel('frequency [kHz]')
% ylabel('magnitude [dB]')
% xlim([0 22])
% grid on



end