function exp_task11_pcw()

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
subjects_ids = [103 104 1 2 3 4 5 6 7 8 9];
%subjects_ids = [103 104 6 7 8];

% Load Answer File
for sub = 1:length(subjects_ids)
    
    for rep =1:2
        
    answ_file = sprintf('../matlabdata/experiment/answ/answ_exp_task1_pcw_sub%i_%i.mat',subjects_ids(sub),rep);
    
        if (exist(answ_file,'file') == 2)
            X = load(answ_file);
            repetitions(sub) = rep;
            answ_task1(sub,rep,:) = X.answ.answ_task1;
            sample_ind(sub,rep,:) = X.answ.sample_ind;
            pos(sub,rep,:) = X.answ.pos;
            pc(sub,rep,:) = X.answ.pc;
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

er_pos = zeros(4,positions);
er_pc = zeros(4,5);
er_sub = zeros(4,length(subjects_ids));
er_adapt = zeros(4,length(perc(1,1,:)));
er_sample = zeros(4,total_samples);
er_sample1 = zeros(4,length(subjects_ids),total_samples);
er_subpc = zeros(4,length(subjects_ids),5);
er_pospc = zeros(4,4,5);


er_all_h = zeros(length(subjects_ids),4,5,7,2);
er_all_f = zeros(length(subjects_ids),4,5,7,2);
er_all_c = zeros(length(subjects_ids),4,5,7,2);
er_all_m = zeros(length(subjects_ids),4,5,7,2);

c=0;
% go through each sample
for sub=1:length(subjects_ids)
    for rep=1:repetitions(sub)
        c=c+1;
        for sa=1:total_samples
            
            Y(find(pos(sub,rep,sa)==pos_ind(sub,rep,:)),pc(sub,rep,sa),find(adapt_perc(sub,rep,sa) == perc(sub,rep,:)),sub,rep) = answ_task1(sub,rep,sa);
            
            % HIT: answer=yes, and change 
            if (adapt_perc(sub,rep,sa) ~= 50) && (answ_task1(sub,rep,sa) == 1)
            er_all_h(sub,find(pos(sub,rep,sa)==pos_ind(sub,rep,:)),pc(sub,rep,sa),find(adapt_perc(sub,rep,sa) == perc(sub,rep,:)),rep) = er_all_h(sub,find(pos(sub,rep,sa)==pos_ind(sub,rep,:)),pc(sub,rep,sa),find(adapt_perc(sub,rep,sa) == perc(sub,rep,:)),rep) +1;
            end

            % False Alarm: answer=yes, but no change
            if (adapt_perc(sub,rep,sa) == 50) && (answ_task1(sub,rep,sa) == 1)
            er_all_f(sub,find(pos(sub,rep,sa)==pos_ind(sub,rep,:)),pc(sub,rep,sa),find(adapt_perc(sub,rep,sa) == perc(sub,rep,:)),rep) = er_all_f(sub,find(pos(sub,rep,sa)==pos_ind(sub,rep,:)),pc(sub,rep,sa),find(adapt_perc(sub,rep,sa) == perc(sub,rep,:)),rep)+1;
            end

            % Correct rejection: answer=no, and no change
            if (adapt_perc(sub,rep,sa) == 50) && (answ_task1(sub,rep,sa) == 0)
            er_all_c(sub,find(pos(sub,rep,sa)==pos_ind(sub,rep,:)),pc(sub,rep,sa),find(adapt_perc(sub,rep,sa) == perc(sub,rep,:)),rep) = er_all_c(sub,find(pos(sub,rep,sa)==pos_ind(sub,rep,:)),pc(sub,rep,sa),find(adapt_perc(sub,rep,sa) == perc(sub,rep,:)),rep)+1;
            end

            % miss / false rejection: answer=no, but change
            if (adapt_perc(sub,rep,sa) ~= 50) && (answ_task1(sub,rep,sa) == 0)
            er_all_m(sub,find(pos(sub,rep,sa)==pos_ind(sub,rep,:)),pc(sub,rep,sa),find(adapt_perc(sub,rep,sa) == perc(sub,rep,:)),rep) = er_all_m(sub,find(pos(sub,rep,sa)==pos_ind(sub,rep,:)),pc(sub,rep,sa),find(adapt_perc(sub,rep,sa) == perc(sub,rep,:)),rep) +1; 
            end   
                 
        end
    end    
end

% Test Ttime
time1 = reshape(time,1,[]);
time1 = time1(find(time1>0));

figure(13)
title('Test Time (min)')
boxplot(time1/60)


Y= Y/total_samples*100;
Z = mean(Y,5);

% HIT RATE: 200;1/2, 
% FALSE ALARM: 40;

% Min Max Limits
%of1 = 0.05/2;
% of1 = 0.01;
% of2 = 0.97;
of1 = 1/(total_samples*2);
of2 = ((total_samples*2)-1)/(total_samples*2);

% % Adjust Min
% er_all_h(er_all_h==0)=1/2;
% er_all_f(er_all_f==0)=1/40;
% er_all_c(er_all_c==0)=1/20;
% er_all_m(er_all_m==0)=1/2;
% 
% % Adjust Max
% er_all_h(er_all_h==1)=of2;
% er_all_f(er_all_f==1)=of2;
% er_all_c(er_all_c==1)=of2;
% er_all_m(er_all_m==1)=of2;

er_all_h1 = permute(er_all_h,[1,5,2,4,3]);
er_all_h1 = reshape(er_all_h1,[22,4,5,7]);
er_all_f1 = permute(er_all_f,[1,5,2,4,3]);
er_all_f1 = reshape(er_all_f1,[22,4,5,7]);
er_all_f1 = reshape(er_all_f1,[110,7,4]);

% Correction for Pooled Data
h_of1 = 1/20;
h_of2 =(20-1)/20;



% Sensitivity per subject
e1 = squeeze(mean(mean(mean(mean(er_all_h,5),4),3),2));
e2 = squeeze(mean(mean(mean(mean(er_all_f,5),4),3),2));
d_sub = norminv(e1) - norminv(e2);

% Sensitivity per subject and rep
e1 = squeeze(mean(mean(mean(er_all_h,4),3),2));
e2 = squeeze(mean(mean(mean(er_all_f,4),3),2));
d_subrep = norminv(e1) - norminv(e2);

% Sensitivity per sub and adapt
e1 = squeeze(mean(mean(mean(er_all_h,5),3),2));
e2 = squeeze(mean(mean(mean(er_all_f,5),3),2));
d_subadapt = norminv(e1) - norminv(e2);

for pos=1:4
    % Sensitivity per sub and pc for each pos
    e1 = squeeze(mean(mean(er_all_h,5),4));
    e2 = squeeze(mean(mean(er_all_f,5),4));
    d_subpcpos = norminv(e1) - norminv(e2);
end


% Sensitivity per position and pc
e1 = squeeze(mean(mean(mean(er_all_h,5),4),1));
e2 = squeeze(mean(mean(mean(er_all_f,5),4),1));
d_pospc = norminv(e1) - norminv(e2);


% Sensitivity per pc and adapt
e1 = squeeze(mean(mean(mean(er_all_h,5),2),1));
e2 = squeeze(mean(mean(mean(er_all_f,5),2),1));
d_pcadapt = norminv(e1) - norminv(e2);

cc = hsv(length(subjects_ids));
lw1 = 1.3;


for pos=1:4
   
    figure(pos) 
    clf;
    plot(adapt_vals,squeeze(mean(Z(pos,:,:,:)*100,4))','o--','LineWidth',1.4)
    legend({'PC1','PC2','PC3','PC4','PC5'},'Location','SouthEast')
    grid on
    ylabel('detected difference (percent)')
    xlabel('percentiles')
    title('Psychometric Function')


    for pc=1:5
    %hold on
    %boxplot(squeeze(Z(pos,pc,:,:))'*100,'plotstyle','compact','labelorientation','horizontal','color',clr(pc,:),'orientation','vertical')
    
    end
    
    %set(gca,'XTickLabelMode','manual')
    %set(gca,'XTickMode','manual')
    xtix = {'1st','12.5th','25th','50th','75th','87.5th','99th'};   % Your labels
    xtixloc = [1 12.5 25 50 75 87.5 99];
    set(gca,'XTickMode','auto','XTickLabel',xtix,'XTick',xtixloc);                        
                        
                            
    set(pos,'paperunits','centimeters','paperposition',[1 1 18 10])
    saveas(pos,sprintf('../thesis/images/exp/task1_pcw/pf_pos%i',pos),'epsc');
    
    squeeze(mean(Z(pos,1,:,:)*100,4))
    
end


Z1 = squeeze(mean(mean(mean(Z,1),2),4));
% Psychometric Function
figure(4)
clf;
set(4,'DefaultAxesColorOrder',cc)
%plot(adapt_vals,[squeeze(mean(mean(Z(:,:,:,:),2),1))*100, Z1*100])
plot(adapt_vals,squeeze(mean(mean(Z(:,:,:,:),2),1))*100,'o--','LineWidth',1.4)
title('Psychometric Function')
cell_sub = cellstr(num2str(subjects_ids', 'Sub %-d'));
%cell_sub{end+1} = 'Mean';
legend(cell_sub,'Location','SouthEast')
grid on
xlabel('percentiles')
ylabel('detected difference (percent)')
set(4,'paperunits','centimeters','paperposition',[1 1 18 10])
saveas(4,'../thesis/images/exp/task1_pcw/pf_sub','epsc');

figure(5)
clf;
%plot(adapt_vals,[squeeze(mean(mean(Z(:,:,:,:),4),1))*100; Z1'*100])
plot(adapt_vals,squeeze(mean(mean(Z(:,:,:,:),4),1))*100,'o--','LineWidth',1.4)
title('Psychometric Function')
legend({'PC1','PC2','PC3','PC4','PC5'},'Location','SouthEast')
grid on
xlabel('percentiles')
ylabel('detected difference (percent)')
set(5,'paperunits','centimeters','paperposition',[1 1 18 10])
saveas(5,'../thesis/images/exp/task1_pcw/pf_pc','epsc');

figure(6)
clf;
%plot(adapt_vals,Z1*100,'Linewidth',1)
title('Psychometric Function')
grid on
xlabel('percentiles')
ylabel('detected difference (percent)')
hold on
plot(adapt_vals,squeeze(mean(mean(Z(:,:,:,:),4),2))*100,'o--','LineWidth',1.4)
legend({'-30/0','0/0','30/0','60/0'},'Location','SouthEast')
set(6,'paperunits','centimeters','paperposition',[1 1 18 10])
saveas(6,'../thesis/images/exp/task1_pcw/pf_pos','epsc');

figure(7)
clf;
Z11 = permute(Z,[1 2 4 3]);
boxplot(squeeze(reshape(Z11,[size(Z11,1)*size(Z11,2)*size(Z11,3),size(Z11,4)]))*100,adapt_vals)
title('Psychometric Function')
grid on
xlabel('percentiles')
ylabel('detected difference (percent)')
set(7,'paperunits','centimeters','paperposition',[1 1 18 10])
saveas(7,'../thesis/images/exp/task1_pcw/pf_box','epsc');

% Sensitivity

figure(14)
clf;
set(14,'DefaultAxesColorOrder',cc)
hold on
plot(squeeze(d_sub),'LineWidth',lw1)
title('Sensitivity')
ylabel('sensitivity')
xlabel('subjects')
grid on
set(14,'paperunits','centimeters','paperposition',[1 1 12 7])
saveas(14,'../thesis/images/exp/task1_pcw/sub','epsc');


figure(15)
clf;
hold on
plot(squeeze(d_pospc),'LineWidth',lw1)
title('Sensitivity')
ylabel('sensitivity')
xlabel('Position')
set(gca,'xtick', [1:4])
set(gca,'xticklabel',{'-30/0','0/0','30/0','60/0'})
grid on
legend({'PC1','PC2','PC3','PC4','PC5'},'Location','SouthEast')
set(15,'paperunits','centimeters','paperposition',[1 1 12 7])
saveas(15,'../thesis/images/exp/task1_pcw/s_pospc','epsc');

figure(16)
clf;
hold on
plot(adapt_vals,squeeze(d_pcadapt'),'LineWidth',lw1)
title('Sensitivity')
ylabel('sensitivity')
xlabel('Percentiles')
grid on
legend({'PC1','PC2','PC3','PC4','PC5'},'Location','SouthEast')
set(16,'paperunits','centimeters','paperposition',[1 1 12 7])
saveas(16,'../thesis/images/exp/task1_pcw/s_pcadapt','epsc');

figure(17)
clf;
set(17,'DefaultAxesColorOrder',cc)
hold on
plot(adapt_vals,squeeze(d_subadapt'),'LineWidth',lw1)
title('Sensitivity')
ylabel('sensitivity')
xlabel('Percentiles')
grid on
legend(cellstr(num2str(subjects_ids', 'Sub %-d')),'Location','SouthEast')
set(17,'paperunits','centimeters','paperposition',[1 1 12 7])
saveas(17,'../thesis/images/exp/task1_pcw/s_subdapt','epsc');

figure(18)
clf;
set(18,'DefaultAxesColorOrder',cc)
hold on
plot(squeeze(d_subrep'),'LineWidth',lw1)
title('Sensitivity')
ylabel('sensitivity')
xlabel('Repetition')
set(gca,'xtick', [1:2])
grid on
legend(cellstr(num2str(subjects_ids', 'Sub %-d')),'Location','SouthEast')
set(18,'paperunits','centimeters','paperposition',[1 1 12 7])
saveas(18,'../thesis/images/exp/task1_pcw/s_subrep','epsc');


for pos=1:4
figure(20+pos)
set(20+pos,'DefaultAxesColorOrder',cc)
clf;
hold on
plot(squeeze(d_subpcpos(:,pos,:))','o--','LineWidth',lw1)
title(sprintf('Sensitivity Pos %s',pos_abs{pos}))
ylabel('sensitivity')
xlabel('PC')
set(gca,'xtick', [1:5])
ylim([0 max(max(squeeze(d_subpcpos(:,pos,:))))])
grid on
legend(cellstr(num2str(subjects_ids', 'Sub %-d')),'Location','SouthEast')
set(20+pos,'paperunits','centimeters','paperposition',[1 1 20 12])
saveas(20+pos,sprintf('../thesis/images/exp/task1_pcw/s_subpc_pos%i',pos),'epsc');
end

for pc=1:5
figure(30+pc)
set(30+pc,'DefaultAxesColorOrder',cc)
clf;
hold on
plot(squeeze(d_subpcpos(:,:,pc))','o--','LineWidth',lw1)
title(sprintf('Sensitivity PC %i',pc))
ylabel('sensitivity')
xlabel('Position')
set(gca,'xtick', [1:4])
set(gca,'xticklabel',pos_abs)
ylim([0 max(max(squeeze(d_subpcpos(:,:,pc))))])
grid on
legend(cellstr(num2str(subjects_ids', 'Sub %-d')),'Location','SouthEast')
set(30+pc,'paperunits','centimeters','paperposition',[1 1 20 12])
saveas(30+pc,sprintf('../thesis/images/exp/task1_pcw/s_subpos_pc%i',pc),'epsc');
end