function exp_1_plot()

% IDs:

% 103_1  Josef log 32 DTF
% 103_2  Josef log 32 DTF
% 104_1  Georgios Marentakis log 32 DTF
% 104_2  Georgios Marentakis log 32 DTF
% 1_1   Dominik Hollerweger log 32 DTF
% 1_2   Dominik Hollerweger log 32 DTF
% 2_1   Stefan Lösler log 32 DTF
% 2_2   Stefan Lösler log 32 DTF
% 3_1   Wolfgang Hrauda log 32 DTF
% 3_2   Wolfgang Hrauda log 32 DTF
% 4_1   Nico Seddiki log 32 DTF
% 4_2   Nico Seddiki log 32 DTF
% 5_1   Benedikt Brands log 32 DTF
% 5_2   Benedikt Brands log 32 DTF
% 6_1   Thomas Kumar log 32 DTF
% 6_2   Thomas Kumar log 32 DTF
% 7_1   Julia Hölzl log 32 DTF
% 7_2   Julia Hölzl log 32 DTF
% 8_1   Johannes Steiner log 32 DTF
% 8_2   Johannes Steiner log 32 DTF
% 9_1   Sepp Hölzl log 32 DTF
% 9_2   Sepp Hölzl log 32 DTF


% Subject IDs
subjects_ids = [103 1 2 3 4 5 6 7 8 9];
%subjects_ids = [103 104 1 2 3 4 5 6 7 8 9];

% Load Answer File
for sub = 1:length(subjects_ids)
    
    for rep =1:2
        
    answ_file = sprintf('../matlabdata/experiment/answ/answ_exp_task1_pcw_sub%i_%i.mat',subjects_ids(sub),rep);
    
        if (exist(answ_file,'file') == 2)
            X = load(answ_file);
            repetitions(sub) = rep;
            answ_task1(sub,rep,:) = X.answ.answ_task1;
            sample_ind(sub,rep,:) = X.answ.sample_ind;
            answ_pos(sub,rep,:) = X.answ.pos;
            answ_pc(sub,rep,:) = X.answ.pc;
            adapt(sub,rep,:) = X.answ.adapt;
            adapt_perc(sub,rep,:) = X.answ.adapt_perc;
            perc(sub,rep,:) = X.answ.perc;
            perc_data(sub,rep,:,:,:,:) = X.answ.perc_data;
            time(sub,rep) = X.answ.time;
            pos_ind(sub,rep,:) = X.answ.test_data.test_position_ind;
            pos_ind_text{sub,rep,:} = X.answ.test_data.test_position_text;
            replays(sub,rep,:) = X.answ.test_data.replays;
            
        else    
            
        end
    end
end

% Parameters
total_samples = 140;
adapt_vals = squeeze(perc(1,1,:));
pcs = 5;
positions = 4;
pos_abs={'-30/0','0/0','30/0','60/0'};

hr = zeros(length(subjects_ids),4,5,7,2);
fa = zeros(length(subjects_ids),4,5,7,2);
er_all_c = zeros(length(subjects_ids),4,5,7,2);
er_all_m = zeros(length(subjects_ids),4,5,7,2);

c=0;
% go through each sample
for sub=1:length(subjects_ids)
    for rep=1:repetitions(sub)
        c=c+1;
        for sa=1:total_samples
            
            Y(find(answ_pos(sub,rep,sa)==pos_ind(sub,rep,:)),answ_pc(sub,rep,sa),find(adapt_perc(sub,rep,sa) == perc(sub,rep,:)),sub,rep) = answ_task1(sub,rep,sa);
            
            % HIT: answer=yes, and change 
            if (answ_task1(sub,rep,sa) == 1)
            hr(sub,find(answ_pos(sub,rep,sa)==pos_ind(sub,rep,:)),answ_pc(sub,rep,sa),find(adapt_perc(sub,rep,sa) == perc(sub,rep,:)),rep) = hr(sub,find(answ_pos(sub,rep,sa)==pos_ind(sub,rep,:)),answ_pc(sub,rep,sa),find(adapt_perc(sub,rep,sa) == perc(sub,rep,:)),rep) +1;
            end

            % False Alarm: answer=yes, but no change
            if (adapt_perc(sub,rep,sa) == 50) && (answ_task1(sub,rep,sa) == 1)
            fa(sub,find(answ_pos(sub,rep,sa)==pos_ind(sub,rep,:)),answ_pc(sub,rep,sa),find(adapt_perc(sub,rep,sa) == perc(sub,rep,:)),rep) = fa(sub,find(answ_pos(sub,rep,sa)==pos_ind(sub,rep,:)),answ_pc(sub,rep,sa),find(adapt_perc(sub,rep,sa) == perc(sub,rep,:)),rep)+1;
            end

            % Correct rejection: answer=no, and no change
            if (adapt_perc(sub,rep,sa) == 50) && (answ_task1(sub,rep,sa) == 0)
            er_all_c(sub,find(answ_pos(sub,rep,sa)==pos_ind(sub,rep,:)),answ_pc(sub,rep,sa),find(adapt_perc(sub,rep,sa) == perc(sub,rep,:)),rep) = er_all_c(sub,find(answ_pos(sub,rep,sa)==pos_ind(sub,rep,:)),answ_pc(sub,rep,sa),find(adapt_perc(sub,rep,sa) == perc(sub,rep,:)),rep)+1;
            end

            % miss / false rejection: answer=no, but change
            if (adapt_perc(sub,rep,sa) ~= 50) && (answ_task1(sub,rep,sa) == 0)
            er_all_m(sub,find(answ_pos(sub,rep,sa)==pos_ind(sub,rep,:)),answ_pc(sub,rep,sa),find(adapt_perc(sub,rep,sa) == perc(sub,rep,:)),rep) = er_all_m(sub,find(answ_pos(sub,rep,sa)==pos_ind(sub,rep,:)),answ_pc(sub,rep,sa),find(adapt_perc(sub,rep,sa) == perc(sub,rep,:)),rep) +1; 
            end   
                 
        end
    end    
end


cc = hsv(length(subjects_ids));
lw1 = 1.3;

%[d_p,d_sub] = exp_sen_old(hr,fa,subjects_ids);
[d_p,d_sub,hr_sub,fa_sub] = exp_sen(hr,fa,subjects_ids);


% figure(10)
% set(10,'DefaultAxesColorOrder',cc)
% %plot(squeeze(mean(d_sub(:,1,:,:),1))','o--','LineWidth',1.3)
% plot(squeeze(d_sub(:,:,1,1))','o--','LineWidth',1.3)
% cell_sub = cellstr(num2str(subjects_ids', 'Sub %-d'));
% legend(cell_sub,'Location','SouthEast')
% grid on

Y= Y/total_samples*100;
Z = mean(Y,5);
cc = hsv(length(subjects_ids));
lw1 = 1.3;

for pos=1:4
   
    figure(20+pos) 
    clf;
    plot(adapt_vals,squeeze(mean(Z(pos,:,:,:)*100,4))','o--','LineWidth',1.4)
    legend({'PC1','PC2','PC3','PC4','PC5'},'Location','North')
    grid on
    ylabel('detected difference (percent)')
    xlabel('percentiles')
    title('Psychometric Function')

    xtix = {'1th','12.5th','25th','50th','75th','87.5th','99th'};   % Your labels
    xtixloc = [1 12.5 25 50 75 87.5 99];
    set(gca,'XTickMode','auto','XTickLabel',xtix,'XTick',xtixloc);                        
                        
                            
    set(20+pos,'paperunits','centimeters','paperposition',[1 1 18 10])
  %  saveas(20+pos,sprintf('../thesis/images/exp/task1_pcw/pf_pos%i',pos),'epsc');
    
    
end

% Averaged Sensitivity
for pos=1:4
   
    figure(10+pos)
    clf;
    
    plot(adapt_vals,squeeze(mean(d_sub(:,pos,:,:),1))','o--','LineWidth',1.3)
    legend({'PC1','PC2','PC3','PC4','PC5'},'Location','North')
    grid on
    ylabel('sensitivity')
    xlabel('percentiles')
    title('Sensitivity - Mean over Subjects') 
    ylim([-0.5 3.5])
    
    xtix = {'1th','12.5th','25th','50th','75th','87.5th','99th'};   % Your labels
    xtixloc = [1 12.5 25 50 75 87.5 99];
    set(gca,'XTickMode','auto','XTickLabel',xtix,'XTick',xtixloc);
    
    set(10+pos,'paperunits','centimeters','paperposition',[1 1 18 10])
    %saveas(10+pos,sprintf('../thesis/images/exp/task1_pcw/subject_mean/sen_pos%i',pos),'epsc'); 
end

% Pooled Sensitivity
for pos=1:4
   
    figure(30+pos)
    clf;
    plot(adapt_vals,squeeze(d_p(pos,:,:))','o--','LineWidth',1.3)
    legend({'PC1','PC2','PC3','PC4','PC5'},'Location','North')
    grid on
    ylabel('sensitivity')
    xlabel('percentiles')
    title('Sensitivity - Pooled') 
    %ylim([0 4.5])
    
    xtix = {'1th','12.5th','25th','50th','75th','87.5th','99th'};   % Your labels
    xtixloc = [1 12.5 25 50 75 87.5 99];
    set(gca,'XTickMode','auto','XTickLabel',xtix,'XTick',xtixloc);        
    ylim([-1 4])
    set(30+pos,'paperunits','centimeters','paperposition',[1 1 18 10])
   % saveas(30+pos,sprintf('../thesis/images/exp/task1_pcw/pooled/sen_pos%i',pos),'epsc'); 
end

% ROC
for pos=1:4
    
    figure(50+pos)
    clf;
    
        for adapt = 1:7
        hold on
        plot(squeeze(mean(fa_sub(:,pos,:,adapt),1)),squeeze(mean(hr_sub(:,pos,:,adapt),1)),'o--','LineWidth',1.3)
        end
        
    grid on
    ylabel('Hit Rate')
    xlabel('False Alarm')
    title('ROC')    
    
    set(50+pos,'paperunits','centimeters','paperposition',[1 1 18 10])
    saveas(50+pos,sprintf('../thesis/images/exp/task1_pcw/roc/sen_pos%i',pos),'epsc'); 
end
end