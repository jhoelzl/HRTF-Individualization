function exp_create_data(db,exp_mode,inp_mode,smooth,mode)

% Input
% db
% exp_mode: local or global
% inp_mode: 3=lin, 4=log
% smooth ratio: 1,2,4,8, etc.
% mode: 1=discrimination test; 2=localization test

% CONFIG    
m.dataset.parameter.bp_mode = [0]; % bp=0 no bp, or 1: using bp
m.dataset.parameter.density = [100]; % percent number of source angles;
m.dataset.parameter.calc_pos = 0;
m.dataset.parameter.subjects = [100]; % percent number of subjects
m.dataset.parameter.ears = {[1 2]}; % ears {1  2 [1 2]}
m.dataset.parameter.smooth_ratio = smooth; % smooth ratio of Fourier coefficients
m.dataset.parameter.fft_size = []; % FFT Size, leave blank [] for standard

m.model.parameter.input_mode = inp_mode;%1-4; lin/log magnitude
m.model.parameter.structure = [2]; % Subj or Freq or Pos as columns
m.model.parameter.ear_mode = [2];
m.model.parameter.type = 'pca'; % pca, ica or nmf
m.model.parameter.pcs = [999]; % PC Numbers %1 5 10 20

m.weight_model.parameter.type = exp_mode; % local or global
m.weight_model.parameter.order = 2; % SH Order
m.weight_model.parameter.order_initial = max(m.weight_model.parameter.order); % SH Order
m.weight_model.parameter.regularize = 0; % Matrix Regularization

% Core Calc
m = core_calc(db,1,0,m);

% Reshape PCWs
if m.model.parameter.ear_mode == 1
    m.model.pcws_res = ireshape_model(m.model.weights,m.model.parameter.structure,m.model.sz,m.model.parameter.ear_mode);
elseif m.model.parameter.ear_mode == 2
    sz_temp = m.model.parameter.sz; sz_temp(3) = 1;sz_temp(4) = 2*sz_temp(4);
    m.model.pcws_res = ireshape_model(m.model.weights,m.model.parameter.structure,sz_temp,m.model.parameter.ear_mode);
end

% Get Test Positions
[test_position_ind,text_positions] = initialize_test_positions1(m);
test_data.test_position_ind = m.dataset.angle_ids(test_position_ind);
test_data.test_position_text = text_positions;

%m.dataset.angle_ids(test_position_ind)

%test_subs = [1 6 44 47 53 58 59 64 65 78];% ari subjects with ITD=0 for test-positions
test_subs = [1];

for test_sub = 1:length(test_subs)
 
    
  %  model.dataset.database.itd_samples(test_subs(test_sub),model.dataset.angle_ids(test_position_ind))
  %  model.dataset.itd_samples(test_subs(test_sub),test_position_ind)
    
    % Create Audio Samples
    if (strcmp(exp_mode,'local') ==1)
        % PCA MODEL
        audio_output = initialize_output_local(m,test_position_ind,test_subs(test_sub),mode);
    else
        % PCA-SH MODEL
        audio_output = initialize_output_global(m,test_position_ind,test_subs(test_sub),mode);
    end
    
    test_data.test_sub = test_subs(test_sub);
    audio_output.fs = m.database.fs;

    % Save Data
    if(mode==1)
    data_file = sprintf( '../matlabdata/experiment/data_%s/audio_output_%s_testsub%i_mode%i_sm%i_dtf_dis.mat',exp_mode,db,test_subs(test_sub),inp_mode,smooth);
    else
    data_file = sprintf( '../matlabdata/experiment/data_%s/audio_output_%s_testsub%i_mode%i_sm%i_dtf_loc.mat',exp_mode,db,test_subs(test_sub),inp_mode,smooth);     
    end
    save(data_file,'audio_output','test_data','-v7.3');
end    
end

function [test_position_ind,text_positions] = initialize_test_positions1(m)

% Find indices for following 4 positions
az_pos = [0];
el_pos = [-30 0 30 60];
pos_ind = 0;

for pos_el = 1:length(el_pos)
    for pos_az = 1:length(az_pos)  
        ang_ind = find(m.dataset.angles(:,2) == el_pos(pos_el) & m.dataset.angles(:,1) == az_pos(pos_az));
        if (~isempty(ang_ind))
        pos_ind = pos_ind +1;
        test_position_ind(pos_ind) = find(m.dataset.angles(:,2) == el_pos(pos_el) & m.dataset.angles(:,1) == az_pos(pos_az));
        text_positions{pos_ind} = sprintf('AZ: %i / EL: %i',az_pos(pos_az),el_pos(pos_el));
        end
    end
end

end

function audio_output = initialize_output_local(m,test_position_ind,test_sub,mode)

% Calc all output samples
pc_numbers = 5;

% Reshape PCWs to [subjects,pos,pcws]
sz_temp = m.model.parameter.sz; sz_temp(3) = 1;sz_temp(4) = 2*sz_temp(4);
sz_temp2 = [1, 1, 2, sz_temp(4)/2];
pcws = m.model.pcws_res(:,test_position_ind,:,:);

% Perctile
if (mode == 1)
    audio_output.perc = [1 12.5 25 50 75 87.5 99];
    audio_output.perc_data = prctile(pcws,audio_output.perc,1);
elseif mode ==2
    audio_output.perc = [1 1 12.5 50 87.5 99 99];
    audio_output.perc_data = prctile(pcws,audio_output.perc,1);
    
    % extend range *1.5
    audio_output.perc_data(1,:,:,:) = audio_output.perc_data(2,:,:,:)*1.5;
    audio_output.perc_data(7,:,:,:) = audio_output.perc_data(6,:,:,:)*1.5;
    
    % normally min is negative and maximum pos,
    % but at pos1 with pc2: min is also pos, therefore:
    audio_output.perc_data(1,1,:,2) = audio_output.perc_data(2,1,:,2)/1.5; % for PC2
    
    audio_output.perc = [-1 1 12.5 50 87.5 99 101];
end


i=0;

% Calc Test Samples
for pos = 1:length(test_position_ind)   
    for pc = 1:pc_numbers
        
        % Calc Reference Stimulus
        pcws_rec = pcws(test_sub,pos,:,:);
        pcws_rec(1,1,1,pc) = squeeze(audio_output.perc_data(find(audio_output.perc == 50),pos,1,pc)); 
        
        % HRIR Reconstruction
        hrirs_reference = HRIRReconstruct(pcws_rec,m,sz_temp2,test_position_ind(pos),test_sub,1);
        
        figure(10)
        clf;
        
        for adapt=1:length(audio_output.perc)

            i=i+1;
            
            % Adapt PC Weights
            pcws_rec = pcws(test_sub,pos,:,:);
            pcws_rec(1,1,1,pc) = squeeze(audio_output.perc_data(adapt,pos,1,pc));           
            
            % HRIR Reconstruction
            m.set.hrirs = HRIRReconstruct(pcws_rec,m,sz_temp2,test_position_ind(pos),test_sub,adapt);
            
            % A/B sorting
            play_order = randperm(2);
            
             % Adapted Sample
            audio_output.data(i,play_order(1),:,:) = squeeze(m.set.hrirs);
            
            % Reference Sample: Original HRIR from Database
            %audio_output.data(i,play_order(2),:,:) = squeeze(model.dataset.hrirs(test_sub,test_position_ind(pos),:,:));
            % Reference Sample: Median 50% Value
            audio_output.data(i,play_order(2),:,:) = squeeze(hrirs_reference);
            
            % Save properties
            audio_output.play_order(i) = play_order(1);
            audio_output.pc(i) = pc;
           % audio_output.pos(i) = test_position_ind(pos);
            audio_output.pos(i) = m.dataset.angle_ids(test_position_ind(pos));
            audio_output.adapt(i) = audio_output.perc_data(adapt,pos,1,pc);
            audio_output.adapt_perc(i) = audio_output.perc(adapt);
        end  
        
        figure(10)
        grid on
        ylabel('amplitude [dB]')
        xlabel('frequency [kHz]')
        set(10,'paperunits','centimeters','paperposition',[1 1 18 10])
        saveas(10,sprintf('../thesis/images/exp/task1_pcw/spectrum/%s_mode%i_pos%i_pc%i',m.database.name,mode,pos,pc),'epsc'); 

        
    end
end

end


function [hrirs] = HRIRReconstruct(pcws_rec,m,sz_temp2,pos,test_sub,adapt)

    % PCA Reconstruction
    %model_data = squeeze(pcws_rec)' * m.model.basis' + m.model.mean;
    model_data = squeeze(pcws_rec)' * m.model.basis' + m.model.mean;
            
    % Log/Lin
    if (m.model.parameter.input_mode == 4)
    model_data = 10.^(squeeze(model_data)/20);
    end

    % Reshape
    m.set.hrtfs = ireshape_model(squeeze(model_data),m.model.parameter.structure,sz_temp2,m.model.parameter.ear_mode);
    
    % Plot
    % Freq Axis
    N = size(m.dataset.hrirs,4);    
    freq = (0 : (N/2)-0) * m.database.fs / N;
    freq = freq/1000; % in kHz
            
    figure(10)
    hold on
    if (adapt == 4)
       cl = 'r'; 
    else
       cl = 'k';
    end
    plot(freq,20*log10(squeeze(m.set.hrtfs(1,1,1,:))),'Color',cl)
    xlim([0 20])
    
    % HRIR
    [m.set.hrtfs,m.set.mphrirs] = minimum_phase_hrirs1(m,test_sub);  
    hrirs = itd_alignment1(m,pos,test_sub);
  
end


function audio_output = initialize_output_global(m,test_position_ind,test_sub,mode)

% Calc all output samples
pc_numbers = 3;
sh_number = 4;

% Reshape PCWs to [subjects,pos,pcws]
sz_temp = m.model.parameter.sz; sz_temp(3) = 1;sz_temp(4) = 2*sz_temp(4);
sz_temp2 = [1, 1, 2, sz_temp(4)/2];


% Prctile
%audio_output.perc = [35 50 65];
audio_output.perc = [12.5 25 50 75 87.5];
%audio_output.perc = [1 5 25 50 75 95 99];
audio_output.perc_data = prctile(m.weight_model.sh_weights,audio_output.perc);

i=0;

M = (m.weight_model.order+1)^2;

% Calc Test Samples
for pos = 1:length(test_position_ind)   
    
    for pc = 1:pc_numbers 
        for sh=1:sh_number
            for adapt=1:length(audio_output.perc)
            
                i=i+1;
                
                % Adapt SH Weights
                shws_adapt = squeeze(m.weight_model.sh_weights(test_sub,:,:));
                shws_adapt(sh,pc) = squeeze(audio_output.perc_data(adapt,sh,1,pc));
                
                % PCA Reconstruction 
                pcws_rec = m.dataset.sha(:,1:M)*squeeze(shws_adapt);
                pcws_rec = pcws_rec(test_position_ind(pos),:)';   
                
                % HRIR Reconstruction
                m.set.hrirs = HRIRReconstruct(pcws_rec,m,sz_temp2,test_position_ind(pos),test_sub);
                
                % A/B sorting
                play_order = randperm(2);

                % Adapted Sample
                audio_output.data(i,play_order(1),:,:) = squeeze(m.set.hrirs);

                % Reference Sample: Original HRIR form database
                audio_output.data(i,play_order(2),:,:) = squeeze(m.dataset.hrirs(test_sub,test_position_ind(pos),:,:));

                % Save properties
                audio_output.play_order(i) = play_order(1);
                audio_output.pc(i) = pc;
                audio_output.sh(i) = sh;
                audio_output.pos(i) = test_position_ind(pos);
                audio_output.adapt(i) = audio_output.perc_data(adapt,sh,1,pc);
                audio_output.adapt_perc(i) = audio_output.perc(adapt);

            end
        end
    end    
end

end

function [hrtfs,hrir_min] = minimum_phase_hrirs1(m,test_sub)

hrtfs = zeros(1,size(m.set.hrtfs,2),size(m.dataset.hrtfs,3),size(m.dataset.hrtfs,4)); 
hrir_min = zeros(1,size(m.set.hrtfs,2),size(m.dataset.hrirs,3),size(m.dataset.hrirs,4));
   
h = zeros(1,size(m.dataset.hrtfs,4));
for i1 = 1:size(hrir_min,1)
    for i2 = 1:size(hrir_min,2)
        for i3 = 1:size(hrir_min,3)
            h(1:size(m.set.hrtfs,4)) = m.set.hrtfs(i1,i2,i3,:);            
            h(size(m.dataset.hrtfs,4)/2+(2:size(m.dataset.hrtfs,4)/2)) = conj(m.set.hrtfs(i1,i2,i3,size(m.dataset.hrtfs,4)/2:-1:2));
            hrtfs(i1,i2,i3,:) = h;
            [~,htemp] = rceps(real(ifft(h)));            
            hrir_min(i1,i2,i3,:) = htemp;
        end
    end
end
end

function hrirs = itd_alignment1(m,pos,sub_itd)

hrirs = m.set.mphrirs;

if (m.dataset.itd_samples(sub_itd,pos) < 0)
    % right ear later
    hrirs(1,1,1,:) = circshift(squeeze(m.set.mphrirs(1,1,1,:)),0);
    hrirs(1,1,1,1:abs(m.dataset.itd_samples(sub_itd,pos))) = 0;
    hrirs(1,1,2,:) = squeeze(m.set.mphrirs(1,1,2,:));
%     disp('ITD NOT ZERO - RIGHT')
%     abs(model.dataset.itd_samples(sub_itd,pos))
%     sub_itd
%     pos
    
end

if (m.dataset.itd_samples(sub_itd,pos) > 0)
    % left ear later
    hrirs(1,1,2,:) = circshift(squeeze(m.set.mphrirs(1,1,2,:)),0);
    hrirs(1,1,2,1:abs(m.dataset.itd_samples(sub_itd,pos))) = 0;
    hrirs(1,1,1,:) = squeeze(m.set.mphrirs(1,1,1,:));
    
%     disp('ITD NOT ZERO - LEFT')
%     abs(model.dataset.itd_samples(sub_itd,pos))
%     sub_itd
%     pos
end  

end
