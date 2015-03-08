function ls_reconstruction_kfold(db,sav_fig)
% Test several effects (density, pcs, train subjects) on Reconstruction Error
% Hint: IEM database: PCA has to be calculated without 'econ'!!

% Input
% db: name of HRTF database
% sav_fig: save figures as EPS file - 0 (no) or 1 (yes)

close all

% CONFIG
%pc_numbers = [1 5 10 20 50 128];
pc_numbers = [1 5 10 20 50 128];
%dens = [1 3 5 8 10 20 30]; % Density 0 this controls the angle density of the grid, there could be a better implementation for this
dens = [1 3 5 10 15 20];
ears = 'both'; 
modes = {'lin'};

% dtf reshaped to 2D 
% N = boot_ci(train_sizes(t),@prin_comp,dtf,'both');
% N = boot_strp(train_sizes(t),@prin_comp,dtf,'both');
% gives confidence intervals for the principal components
% replace with rewritten calc_pcs where the number of pcs returned 
% is limited to the 90% variance limit


% Perform test conditions
h = waitbar(0,'Calculating...');

    for mod = 1:length(modes)
        [dtf,angles] = preprocess_db(db,modes{mod});    
        train_sizes = linspace(10,size(dtf,1),5);
        for t = 1:length(train_sizes)                     
            for nn = 1:5 % choose nn different random people
                k = randsample(size(dtf,1),train_sizes(t)); % draw a sample of length train_sizes(t) different people
                CVO = cvpartition(length(k),'KFold',10);  
                % For the Number of Tests to be done
                for i = 1:CVO.NumTestSets
                   su_train{t,i,nn} = k(find(CVO.training(i)==1));
                   su_test{t,i,nn} = k(find(CVO.test(i)==1));
                   [e_l_tst(t,i,nn,:,:,:,:),e_r_tst(t,i,nn,:,:,:,:)] = ls_rec_error(dtf(:,:,:,:),angles,su_train{t,i,nn},su_test{t,i,nn},dens,pc_numbers,ears,modes{mod});
                   tpt = randsample(su_train{t,i,nn},length(su_test{t,i,nn})); % temporarily draw a sample from training set, normally use all people in training 
                   [e_l_trn(t,i,nn,:,:,:,:),e_r_trn(t,i,nn,:,:,:,:)] = ls_rec_error(dtf(:,:,:,:),angles,su_train{t,i,nn},tpt,dens,pc_numbers,ears,modes{mod});
                end                    
            end
            waitbar(t / length(train_sizes))            
        end
    end


close(h)

e_l_tst = mean(e_l_tst,3);e_r_tst = mean(e_r_tst,3); % Mean over random sampling
e_l_tst = mean(e_l_tst,2);e_r_tst = mean(e_r_tst,2); % Mean over test sets

e_l_trn = mean(e_l_trn,3);e_r_trn = mean(e_r_trn,3); % Mean over random sampling
e_l_trn = mean(e_l_trn,2);e_r_trn = mean(e_r_trn,2); % Mean over test sets

for d = 1:length(dens)
    idx_trn = 1:dens(d):size(angles,1);
    idx_tst = setxor(1:size(angles,1),idx_trn);

    % Train
    e_l_train_train(:,:,d) = squeeze(mean(e_l_trn(:,:,:,:,d,:,idx_trn),7));
    e_r_train_train(:,:,d) = squeeze(mean(e_r_trn(:,:,:,:,d,:,idx_trn),7)); % Mean over directions

    e_l_train_test(:,:,d) = squeeze(mean(e_l_trn(:,:,:,:,d,:,idx_tst),7));
    e_r_train_test(:,:,d) = squeeze(mean(e_r_trn(:,:,:,:,d,:,idx_tst),7)); % Mean over directions

    
    % Test
    e_l_test_train(:,:,d) = squeeze(mean(e_l_tst(:,:,:,:,d,:,idx_trn),7));
    e_r_test_train(:,:,d) = squeeze(mean(e_r_tst(:,:,:,:,d,:,idx_trn),7)); % Mean over directions
    
    e_l_test_test(:,:,d) = squeeze(mean(e_l_tst(:,:,:,:,d,:,idx_tst),7));
    e_r_test_test(:,:,d) = squeeze(mean(e_r_tst(:,:,:,:,d,:,idx_tst),7)); % Mean over directions
    
end


% Plotting Options
plot_pcs(1,e_l_train_train,e_l_test_train,pc_numbers,train_sizes,dens,db,sav_fig);
plot_pcs(2,e_l_train_train,e_l_test_test,pc_numbers,train_sizes,dens,db,sav_fig);
plot_pcs(3,e_l_train_test,e_l_test_train,pc_numbers,train_sizes,dens,db,sav_fig);
plot_pcs(4,e_l_train_test,e_l_test_test,pc_numbers,train_sizes,dens,db,sav_fig);


plot_density(1,e_l_train_train,e_l_test_train,pc_numbers,train_sizes,dens,db,sav_fig);
plot_density(2,e_l_train_train,e_l_test_test,pc_numbers,train_sizes,dens,db,sav_fig);
plot_density(3,e_l_train_test,e_l_test_train,pc_numbers,train_sizes,dens,db,sav_fig);
plot_density(4,e_l_train_test,e_l_test_test,pc_numbers,train_sizes,dens,db,sav_fig);

% plot_var(lat,su_train);

end


% Plot Error of different PC numbers
function plot_pcs(i,e_l_trn,e_l_tst,pc_numbers,su_train,dens,db,sav_fig)

    for d = 1:length(dens)
        
        % Plot
        figure(1)
        clf;
        
        plot(su_train,squeeze(e_l_tst(:,:,d)),'-','LineWidth',2);
        legend(cellfun(@num2str, num2cell(pc_numbers), 'UniformOutput', false));
        hold on
        plot(su_train,squeeze(e_l_trn(:,:,d)),':','LineWidth',2);
        
        grid on
        xlabel('People in the Training Set')
        ylabel('error (db)')
        title(sprintf('Reconstruction Error for different PCs, density %i',dens(d)));

        %Save
        if (sav_fig == 1)
        set(1,'paperunits','centimeters','paperposition',[1 1 15 10])
        saveas(1,sprintf('../thesis/images/ls/ls_recon_%s_pcs_dens%i_%i',db,dens(d),i),'epsc');
        end
        
    end  
end

% Plot Error of different density values and PC numbers
function plot_density(i,e_l_trn,e_l_tst,pc_numbers,su_train,dens,db,sav_fig)

    for N=1:length(pc_numbers)
        
        % Plot
        figure(1)
        clf;
        
        plot(su_train,squeeze(e_l_tst(:,N,:)),'-','LineWidth',2);
        legend(cellfun(@num2str, num2cell(dens), 'UniformOutput', false));
        hold on
        plot(su_train,squeeze(e_l_trn(:,N,:)),':','LineWidth',2);

        grid on
        xlabel('People in the Training Set')
        ylabel('error (db)')
        title(sprintf('Reconstruction Error for different density values, PC%i',pc_numbers(N)));
        
        %Save
        if (sav_fig == 1)
        set(1,'paperunits','centimeters','paperposition',[1 1 15 10])
        saveas(1,sprintf('../thesis/images/ls/ls_recon_%s_dens_pc%i',db,pc_numbers(N)),'epsc');
        end
    
    end       
end


% Plot Variance
function plot_var(lat,su_train)

figure(6);
plot(su_train(d,:),squeeze(cumsum(lat(d,:,1:5),3))./repmat(squeeze(sum(lat(d,:,:),3))',1,5));
plot((sum(squeeze(cumsum(lat(d,:,:),3)),3)./repmat(squeeze(sum(lat(d,:,:),3))',1,128))');
var = (sum(squeeze(cumsum(lat(d,:,:),3)),3)./repmat(squeeze(sum(lat(d,:,:),3))',1,128));


var1 =  mean(var(:,pc))* 100;
grid on;
xlabel('People in the Set');
ylabel('Explained Variance');
title(sprintf('Explained Variance, %i PCs, Density: %i, Mode: %s',pc,dens(d),modes{mod}));

            
end

function pcs = calc_pcs(dtf,ear)

% DTF: Substract Mean
% m_s = mean(dtf,2); % Mean Across Angles
% dtf = dtf - repmat(m_s,[1 size(dtf,2) 1 1]);

% Only use a selection of subjects and angles
% angles_values = angles(angles_ind);
% data_dtf_pca = data_dtf(1:sub,angles_ind,:,:);

% Reshape PCA Input Matrix
% if (strcmp(ear,'left')) 
%     dtf = reshape(squeeze(dtf(:,:,1,:)),[],size(dtf,4)); 
% elseif (strcmp(ear,'right')) 
%     dtf = reshape(squeeze(dtf(:,:,2,:)),[],size(dtf,4));    
% elseif (strcmp(ear,'both')) 
%     dtf = reshape(dtf(:,:,:,:),[],size(dtf,4));    
% end

% PCA Decomposition
[pcs, pcws,latent] = princomp(dtf);

end

function [dtf,angles] = preprocess_db(db,mode)

fft_points = 256;
% Import HRIR DATA
[hrirs,~,~,angles] = db_import(db);
[angles,I] = sortrows(angles,[1 2]);
hrirs = hrirs(:,I,:,:);

dtf = abs(fft(hrirs(:,:,:,:),fft_points,4));
dtf = dtf(:,:,:,1:fft_points/2);

% Log or Linear Spectrum
if (strcmp(mode,'log') == 1) 
    dtf = 20*log10(dtf);
end

end