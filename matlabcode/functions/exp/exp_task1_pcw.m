function exp_task1_pcw()
% IDs:

% 103_7  Josef log sm128 DTF

% 104_1   Georgios log 128 sm0 DTF

% 12_1    Dominik log sm128 DTF
% 12_2   Dominik Wiederholung lof sm128 DTF




% Subject IDs
subjects_ids = [1032 1033 1034 1038 104 1041 1042 12 121];
%subjects_ids = [103 104 1];

% Load Answer File
for sub = 1:length(subjects_ids)
    answ_file = sprintf('../matlabdata/experiment/answ/answ_exp_task1_pcw_sub%i.mat',subjects_ids(sub));

    X = load(answ_file);
    answ_task1(sub,:) = X.answ.answ_task1;
    sample_ind(sub,:) = X.answ.sample_ind;
    pos(sub,:) = X.answ.pos;
    pc(sub,:) = X.answ.pc;
    adapt(sub,:) = X.answ.adapt;
    adapt_perc(sub,:) = X.answ.adapt_perc;
    perc(sub,:) = X.answ.perc;
    perc_data(sub,:,:,:,:) = X.answ.perc_data;
    time(sub) = X.answ.time;
    pos_ind(sub,:) = X.answ.test_data.test_position_ind;
    pos_ind_text{sub,:} = X.answ.test_data.test_position_text;
    replays(sub,:) = X.answ.test_data.replays;
end

total_samples = size(answ_task1,2);

pcs = 5;
positions = 4;

er1_pos = zeros(positions,pcs,length(perc(1,:)),length(subjects_ids));
er2_pos = zeros(positions,pcs,length(perc(1,:)),length(subjects_ids));
er3_pos = zeros(positions,pcs,length(perc(1,:)),length(subjects_ids));
er4_pos = zeros(positions,pcs,length(perc(1,:)),length(subjects_ids));


er_pos = zeros(4,positions);
er_pc = zeros(4,5);
er_sub = zeros(4,length(subjects_ids));
er_adapt = zeros(4,length(perc(1,:)));
er_adapt = zeros(4,total_samples);

% go through each sample
for sub=1:length(subjects_ids)
    
    for sa=1:total_samples
        

        Y(find(pos(sub,sa)==pos_ind(sub,:)),pc(sub,sa),find(adapt_perc(sub,sa) == perc(sub,:)),sub) = answ_task1(sub,sa);
        
        % HIT: answer=yes, and change 
        if (adapt_perc(sub,sa) ~= 50) && (answ_task1(sub,sa) == 1)
        er_sub(1,sub) = er_sub(1,sub) +1;
        er_pc(1,pc(sub,sa)) = er_pc(1,pc(sub,sa)) +1;
        er_pos(1,pos(sub,sa)==pos_ind(sub,:)) = er_pos(1,pos(sub,sa)==pos_ind(sub,:)) +1;
        er_adapt(1,find(adapt_perc(sub,sa) == perc(sub,:))) = er_adapt(1,find(adapt_perc(sub,sa) == perc(sub,:))) + 1;
        er(1,find(pos(sub,sa)==pos_ind(sub,:)),pc(sub,sa),find(adapt_perc(sub,sa) == perc(sub,:)),sub) = er1_pos(find(pos(sub,sa)==pos_ind(sub,:)),pc(sub,sa),find(adapt_perc(sub,sa) == perc(sub,:)),sub) +1;
        end
        
        % False Alarm: answer=yes, but no change
        if (adapt_perc(sub,sa) == 50) && (answ_task1(sub,sa) == 1)
        er_sub(2,sub) = er_sub(2,sub) +1;
        er_pc(2,pc(sub,sa)) = er_pc(2,pc(sub,sa)) +1;
        er_pos(2,pos(sub,sa)==pos_ind(sub,:)) = er_pos(2,pos(sub,sa)==pos_ind(sub,:)) +1;
        er_adapt(2,find(adapt_perc(sub,sa) == perc(sub,:))) = er_adapt(2,find(adapt_perc(sub,sa) == perc(sub,:))) + 1;
        er(2,find(pos(sub,sa)==pos_ind(sub,:)),pc(sub,sa),find(adapt_perc(sub,sa) == perc(sub,:)),sub) = er2_pos(find(pos(sub,sa)==pos_ind(sub,:)),pc(sub,sa),find(adapt_perc(sub,sa) == perc(sub,:)),sub) +1;
        end
        
        % Correct rejection: answer=no, and no change
        if (adapt_perc(sub,sa) == 50) && (answ_task1(sub,sa) == 0)
        er_sub(3,sub) = er_sub(3,sub) +1;
        er_pc(3,pc(sub,sa)) = er_pc(3,pc(sub,sa)) +1;
        er_pos(3,pos(sub,sa)==pos_ind(sub,:)) = er_pos(3,pos(sub,sa)==pos_ind(sub,:)) +1;
        er_adapt(3,find(adapt_perc(sub,sa) == perc(sub,:))) = er_adapt(3,find(adapt_perc(sub,sa) == perc(sub,:))) + 1;
        er(3,find(pos(sub,sa)==pos_ind(sub,:)),pc(sub,sa),find(adapt_perc(sub,sa) == perc(sub,:)),sub) = er3_pos(find(pos(sub,sa)==pos_ind(sub,:)),pc(sub,sa),find(adapt_perc(sub,sa) == perc(sub,:)),sub) +1;
        end
        
        % miss / false rejection: answer=no, but change
        if (adapt_perc(sub,sa) ~= 50) && (answ_task1(sub,sa) == 0)
        er_sub(4,sub) = er_sub(4,sub) +1;
        er_pc(4,pc(sub,sa)) = er_pc(4,pc(sub,sa)) +1;
        er_pos(4,pos(sub,sa)==pos_ind(sub,:)) = er_pos(4,pos(sub,sa)==pos_ind(sub,:)) +1;
        er_adapt(4,find(adapt_perc(sub,sa) == perc(sub,:))) = er_adapt(4,find(adapt_perc(sub,sa) == perc(sub,:))) + 1;
        er(4,find(pos(sub,sa)==pos_ind(sub,:)),pc(sub,sa),find(adapt_perc(sub,sa) == perc(sub,:)),sub) = er4_pos(find(pos(sub,sa)==pos_ind(sub,:)),pc(sub,sa),find(adapt_perc(sub,sa) == perc(sub,:)),sub) +1;
        end

        
    end
end

% fprintf('Hit: %.2f\n',er1/total_samples)
% fprintf('False Alarm: %.2f\n',er2/total_samples)
% fprintf('Correct Rejection: %.2f\n',er3/total_samples)
% fprintf('Miss: %.2f\n',er4/total_samples)

% adjust values

er_pos= er_pos/sum(er_pos(1,:));
er_adapt = er_adapt/sum(er_adapt(1,:));
er_sub = er_sub/sum(er_sub(1,:));
er_pc = er_pc/sum(er_pc(1,:));

er_sub(er_sub==0)=0.001;
er_pos(er_pos==0)=0.001;
er_adapt(er_adapt==0)=0.001;
er_pc(er_pc==0)=0.001;

er_sub(er_sub==1)=0.999;
er_pos(er_pos==1)=0.999;
er_adapt(er_adapt==1)=0.999;
er_pc(er_pc==1)=0.999;


d_sub = norminv(er_sub(1,:)) - norminv(er_sub(2,:));
d_pos = norminv(er_pos(1,:)) - norminv(er_pos(2,:));
d_adapt = norminv(er_adapt(1,:)) - norminv(er_adapt(2,:));
d_pc = norminv(er_pc(1,:)) - norminv(er_pc(2,:));



%squeeze(per_adapt(2,:,1,1,1))

%Y = Y(:,1,:,:); % only PC1

Y1 = Y;
Y1 = mean(Y1,1); % pos
Y1 = mean(Y1,2); % pc

% d1 = d;
% d1 = mean(d1,1); % pos
% d1 = mean(d1,2); % pc


%Y = mean(Y,4); % sub
% only values from 0 to 3

figure(4)
clf;
%plot(squeeze(Y))

plot(perc(1,:),squeeze(mean(mean(Y(:,:,:,:),2),1))*100)
title('Psychometric Function')
legend('Mean')
legend(cellstr(num2str(subjects_ids', 'Sub %-d')),'Location','SouthEast')
hold on
plot(perc(1,:),mean(squeeze(Y1*100),2),'Linewidth',2)
grid on
xlabel('percentiles')
ylabel('detected difference (percent)')
set(4,'paperunits','centimeters','paperposition',[1 1 12 7])
saveas(4,'../thesis/images/exp/task1_pcw/pf_sub','epsc');
                          

figure(5)
clf;
plot(perc(1,:),squeeze(mean(mean(Y(:,:,:,:),4),1))*100)
hold on
plot(perc(1,:),mean(squeeze(Y1),2)*100,'Linewidth',2)
title('Psychometric Function')
legend({'PC1','PC2','PC3','PC4','PC5','Mean'},'Location','SouthEast')
grid on
xlabel('percentiles')
ylabel('detected difference (percent)')
set(5,'paperunits','centimeters','paperposition',[1 1 12 7])
saveas(5,'../thesis/images/exp/task1_pcw/pf_pc','epsc');

figure(6)
clf;
plot(perc(1,:),squeeze(mean(mean(Y(:,:,:,:),4),2))*100)
hold on
plot(perc(1,:),mean(squeeze(Y1)*100,2),'Linewidth',2)
title('Psychometric Function')
legend({'-30/0','0/0','30/0','60/0','Mean'},'Location','SouthEast')
grid on
xlabel('percentiles')
ylabel('detected difference (percent)')
set(6,'paperunits','centimeters','paperposition',[1 1 12 7])
saveas(6,'../thesis/images/exp/task1_pcw/pf_pos','epsc');

figure(7)
clf;
boxplot(squeeze(Y1)'*100,perc(1,:))
title('Psychometric Function')
grid on
xlabel('percentiles')
ylabel('detected difference (percent)')
set(7,'paperunits','centimeters','paperposition',[1 1 12 7])
saveas(7,'../thesis/images/exp/task1_pcw/pf_box','epsc');

figure(8)
plot(replays','-')
title('Replays of different subjects')
legend(cellstr(num2str(subjects_ids', 'Sub %-d')),'Location','SouthEast')
set(8,'paperunits','centimeters','paperposition',[1 1 12 7])
saveas(8,'../thesis/images/exp/task1_pcw/replays_sub','epsc');

figure(9)
clf;
plot(d_sub)
hold on
plot(d_sub,'o','LineWidth',4)
title('Sensitivity')
ylabel('sensitivity')
xlabel('subjects')
grid on
set(9,'paperunits','centimeters','paperposition',[1 1 12 7])
saveas(9,'../thesis/images/exp/task1_pcw/s_sub','epsc');

figure(10)
clf;
plot(d_pos')
hold on
plot(d_pos,'o','LineWidth',4)
title('Sensitivity')
ylabel('sensitivity')
xlabel('positions')
grid on
set(10,'paperunits','centimeters','paperposition',[1 1 12 7])
saveas(10,'../thesis/images/exp/task1_pcw/s_pos','epsc');

figure(11)
clf;
plot(perc(1,:),d_adapt')
hold on
plot(perc(1,:),d_adapt','o','LineWidth',4)
title('Sensitivity')
ylabel('sensitivity')
xlabel('percentiles')
grid on
set(11,'paperunits','centimeters','paperposition',[1 1 12 7])
saveas(11,'../thesis/images/exp/task1_pcw/s_adapt','epsc');

figure(12)
clf;
plot(d_pc')
hold on
plot(d_pc,'o','LineWidth',4)
title('Sensitivity')
ylabel('sensitivity')
xlabel('PCs')
grid on
set(12,'paperunits','centimeters','paperposition',[1 1 12 7])
saveas(12,'../thesis/images/exp/task1_pcw/s_pc','epsc');

figure(13)
title('Test Time (min)')
boxplot(time/60)


