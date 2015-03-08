function exp_1_anova()

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


[d_p,d_sub] = exp_sen(hr,fa,subjects_ids);


exp_1_table(d_sub);


headstring = '';
% 2D Matrix of Sensitivity

    for pos = 1:size(d_sub,2)
        for pc = 1:size(d_sub,3)
            for adapt = 1:size(d_sub,4)
              % cc= cc+1; 
               %D(sub,cc) = d_sub(sub,pos,pc,adapt);  
               %saveas(['sen_txt' num2str(D(sub,cc)) '.txt'],'-ascii','a');
               
               headstring = sprintf('%s,D%iP%iA%i',headstring,pos,pc,adapt);
               
            end
        end
    end
    

%headstring


% 2D Matrix of Sensitivity
for sub = 1:size(d_sub,1)
    cc = 0;
    for pos = 1:size(d_sub,2)
        for pc = 1:size(d_sub,3)
            for adapt = 1:size(d_sub,4)
               cc= cc+1; 
               D(sub,cc) = d_sub(sub,pos,pc,adapt);  
               %saveas(['sen_txt' num2str(D(sub,cc)) '.txt'],'-ascii','a');
               
               headstring = sprintf('%s,D%iP%iA%i',headstring,pos,pc,adapt);
               
            end
        end
    end
    
end


% N-way ANOVA

% % Version 1 - subjects as factors
% Y_mn = mean(Y,5);
% pcs=5;
% pos = 4;
% adapts = 7;
% subs = length(subjects_ids);
% rep = 2;
% g = fullfact([pos,pcs,adapts,subs]);
% 
% for i=1:size(g,1)
%    y(i) =  squeeze(Y_mn(g(i,1),g(i,2),g(i,3),g(i,4)));
% end
% 
% p = anovan(y,{g(:,1),g(:,2),g(:,3),g(:,4)},'model','interaction','varnames',{'Pos','PC','Adapt','Sub'})
% 
% 
% % Version 2 - subjects mean
% Y_mn2 = mean(mean(Y,5),4);
% g = fullfact([pos,pcs,adapts]);
% 
% % Get answers
% for i=1:size(g,1)
%    z(i) =  squeeze(Y_mn2(g(i,1),g(i,2),g(i,3)));
% end
% 
% p = anovan(z,{g(:,1),g(:,2),g(:,3)},'model','interaction','varnames',{'Pos','PC','Adapt'})
% 



end