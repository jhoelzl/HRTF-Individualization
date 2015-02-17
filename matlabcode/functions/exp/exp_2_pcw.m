function exp_2_pcw()
% IDs:

% 103 Josef, log 32 DTF
% 104 Georgios log 32 DTF
% 1   Dominik Hollerweger log 32 DTF
% 3   Wolfgang Hrauda log 32 DTF
% 4   Nico Seddiki log 32 DTF
% 5   Benedikt Brands log 32 DTF
% 6   Thomas Kumar log 32 DTF
% 7   Julia log 32 DTF


% Subject IDs
subjects_ids = [103 104 1 3 4 5 6 7];
%subjects_ids = [4];

% Load Answer File
for sub = 1:length(subjects_ids)
    answ_file = sprintf('../matlabdata/experiment/answ/answ_exp_task2_pcw_sub%i_1.mat',subjects_ids(sub));
    X = load(answ_file);
    az(sub,:) = X.answ.az;
    el(sub,:) = X.answ.el;
    sample_ind(sub,:) = X.answ.sample_ind;
    pos(sub,:) = X.answ.pos;
    pc(sub,:) = X.answ.pc;
    adapt(sub,:) = X.answ.adapt;
    adapt_perc(sub,:) = X.answ.adapt_perc;
    perc(sub,:) = X.answ.perc;
    perc_data(sub,:,:,:,:) = X.answ.perc_data;
    time(sub) = X.answ.time;
    pos_ind(sub,:) = X.answ.test_data.test_position_ind;
    pos_ind_text = X.answ.test_data.test_position_text;
    replays(sub,:) = X.answ.test_data.replays;
end

total_samples = size(sample_ind,2);
ref_pos_az = [0 0 0 0];
ref_pos_el = [-30 0 30 60];
ref_adapt = {'1*1.5','1','12.5','50','87.5','99','99*1.5'};
ref_pos = {'-30/0','0/0','30/0','60/0'};
ref_pos2 = {'60/0','30/0','0/0','-30/0'};

%go through each sample
for sub=1:length(subjects_ids)
    
    for sa=1:total_samples
        J_az(sub,find(pos(sub,sa)==pos_ind(sub,:)),pc(sub,sa),find(adapt_perc(sub,sa) == perc(sub,:))) = az(sub,sa);
        J_el(sub,find(pos(sub,sa)==pos_ind(sub,:)),pc(sub,sa),find(adapt_perc(sub,sa) == perc(sub,:))) = el(sub,sa);
    end
end


CalcDistance2(J_az,J_el,ref_pos_az,ref_pos_el,pos_ind_text,ref_pos2)

%CalcJudgements(J_az,J_el,ref_pos_az,ref_pos_el,pos_ind_text)
%CalcDistance(J_az,J_el,ref_pos_az,ref_pos_el,pos_ind_text)
%PlotEachSubject(J_az,J_el,ref_pos_az,ref_pos_el,pos_ind_text,subjects_ids);
%PlotAllSubjects(J_az,J_el,ref_pos_az,ref_pos_el,pos_ind_text,subjects_ids);

% figure(1)
% title('Test Time (min)')
% boxplot(time/60)

function CalcDistance2(J_az,J_el,ref_pos_az,ref_pos_el,pos_ind_text,ref_pos2)

% Convert to
J_az_c = J_az;
J_az_c(J_az_c<180) = -J_az_c(J_az_c<180);
J_az_c(J_az_c>180) = -(J_az_c(J_az_c>180) - 360);

for pc=1:5
    for ad=1:size(J_az,4)

        for sub=1:length(subjects_ids)
            
            az= J_az_c(sub,:,pc,ad);
            el= J_el(sub,:,pc,ad);
        
            jdg(pc,ad,1:4,sub,:) = [az;el]';
            loc(pc,ad,1:4,sub,:) = [ref_pos_az;ref_pos_el]';
        end

        crc = 1;
        tol1 = 0;
        tol2 = 0;
        tol3 = 0;

        [cjdg(pc,ad,:,:,:),fb_conf(pc,ad,:,:,:),ud_conf(pc,ad,:,:,:),fb_conf_full(pc,ad,:,:),ud_conf_full(pc,ad,:,:)] = confussions_gm(squeeze(jdg(pc,ad,:,:,:)),squeeze(loc(pc,ad,:,:,:)),tol1,tol2,tol3,crc);

    end
end
    

for pc=1:5    
    for ad=1:size(J_az,4)

        for pos = 1:4
        
        % Front/back
        cf = squeeze(fb_conf(pc,ad,1,pos,:));
        %cf = squeeze(fb_conf_full(pc,ad,pos,:));
        idc = find(cf == 0);
        idcf = find(cf == 1);
        
        % Up/down
        %cfu = squeeze(ud_conf(pc,ad,1,pos,:));
        cfu = squeeze(ud_conf_full(pc,ad,pos,:));
        idcu = find(cfu == 0);
        idcfu = find(cfu == 1);
        
        % Down/up
        cfu2 = squeeze(ud_conf(pc,ad,2,pos,:));
        idcu2 = find(cfu2 == 0);
        idcfu2 = find(cfu2 == 1);
        
        az = squeeze(J_az_c(:,pos,pc,ad));
        el = squeeze(J_el(:,pos,pc,ad));        
        az_corr = squeeze(cjdg(pc,ad,pos,:,1));
        el_corr = squeeze(cjdg(pc,ad,pos,:,2));
       
        [sdca(pc,pos,ad,:),eea(pc,pos,ad,:),Ra(pc,pos,ad)] = spherical_analysis(az_corr,el,ref_pos_az(pos),ref_pos_el(pos));
        
        % Front / back
        [sdc(pc,pos,ad,:),eec(pc,pos,ad,:),Rc(pc,pos,ad)] = spherical_analysis(az(idc),el(idc),ref_pos_az(pos),ref_pos_el(pos));
        [sdcf(pc,pos,ad,:),eef(pc,pos,ad,:),Rf(pc,pos,ad)] = spherical_analysis(az_corr(idcf),el(idcf),ref_pos_az(pos),ref_pos_el(pos));        
        
        % Standard error
        eeeee(pc,pos,ad,:) = [std(az_corr)/sqrt(length(az_corr)) std(el)/sqrt(length(el))];
        
%         % Up / down 
%         [sdcu(pc,pos,ad,:),eeu(pc,pos,ad,:),Ru(pc,pos,ad)] = spherical_analysis(az(idcu),el(idcu),ref_pos_az(pos),ref_pos_el(pos));
%         [sdcfu(pc,pos,ad,:),eefu(pc,pos,ad,:),Rfu(pc,pos,ad)] = spherical_analysis(az(idcfu),el(idcfu),ref_pos_az(pos),ref_pos_el(pos));
%         
        % ODER Up / down 
        [sdcu(pc,pos,ad,:),eeu(pc,pos,ad,:),Ru(pc,pos,ad)] = spherical_analysis(az_corr(idcu),el(idcu),ref_pos_az(pos),ref_pos_el(pos));
        [sdcfu(pc,pos,ad,:),eefu(pc,pos,ad,:),Rfu(pc,pos,ad)] = spherical_analysis(az_corr(idcfu),el(idcfu),ref_pos_az(pos),ref_pos_el(pos));
        
         % Down / Up
%         [sdcu2(pc,pos,ad,:),eeu2(pc,pos,ad,:),Ru2(pc,pos,ad)] = spherical_analysis(az_corr(idcu2),el_corr(idcu2),ref_pos_az(pos),ref_pos_el(pos));
%         [sdcfu2(pc,pos,ad,:),eefu2(pc,pos,ad,:),Rfu2(pc,pos,ad)] = spherical_analysis(az_corr(idcfu2),el_corr(idcfu2),ref_pos_az(pos),ref_pos_el(pos));
     
        end

    end
end

% fb_prop = mean(fb_conf_full,4);
ud_prop = mean(ud_conf_full,4);
fb_prop = mean(squeeze(fb_conf(:,:,1,:,:)),4);
%ud_prop = mean(ud_conf(:,:,1,:,:),4);
%ud_prop2 = mean(ud_conf(:,:,2,:,:),4);

clr = {'b',[0 0.6 0],'r',[0 0.8 0.8]};

idx = repmat(1:7,4,1) +repmat([-0.1 -0.07 0.07 0.1]',1,7);
for pc=1:5    
    
    % Azimuth Plots
    figure(30+pc) 
    clf;
    hold on
%     errorbar(idx',squeeze(sdc(pc,4:-1:1,:,1))',20*squeeze(Rc(pc,4:-1:1,:))','o-','Markersize',6,'LineWidth',1);
%     errorbar(idx',squeeze(sdcf(pc,4:-1:1,:,1))',20*squeeze(Rf(pc,4:-1:1,:))','x');
      errorbar(idx',squeeze(sdc(pc,4:-1:1,:,1))',squeeze(eeeee(pc,4:-1:1,:,1))','o-','Markersize',6,'LineWidth',1);
      errorbar(idx',squeeze(sdcf(pc,4:-1:1,:,1))',20*squeeze(Rf(pc,4:-1:1,:))','x');
    
    yll = ylim;
    ylim([yll(1) yll(2)*1.6]);
    yll = ylim;
    
     
    grid on
    
    if (pc ==5)
    legend(ref_pos2,'position',[0.2 0.29 0.01 0.01])
    annotation('rectangle',[0.2 0.74 0.65 0.175]); 
    end
    
    if (pc ==4)
    ylim([-80 70]) 
    legend(ref_pos2,'position',[0.2 0.27 0.01 0.01])
    annotation('rectangle',[0.2 0.756 0.65 0.175]); 
    end
    
    if (pc ==3)
    legend(ref_pos2,'position',[0.2 0.29 0.01 0.01])
    annotation('rectangle',[0.2 0.756 0.65 0.175]); 
    end
    
    if (pc == 2)
    legend(ref_pos2,'Location','SouthEast')
    annotation('rectangle',[0.2 0.756 0.65 0.175]); 
    end
    
    if (pc ==1)
    legend(ref_pos2,'position',[0.2 0.55 0.01 0.01])
    annotation('rectangle',[0.2 0.756 0.65 0.175]); 
    end
    
    
    %ylim([-90 150]) 
    
    % Text
    for p = 1:4       
        yl = yll(2)-yll(2)*p*0.075;
        text(1:7,yl*ones(7,1),(num2cell(100*squeeze(fb_prop(pc,:,p)))),'Color',clr{p},'FontSize',9);
    end
    
    xlabel('percentiles')
    ylabel('azimuth');
    %title('Lateral Judgments') 
    
    xtix = {'','1st','12.5th','50th','87.5th','99th',''};   % Your labels
    xtixloc = 1:7;
    set(gca,'XTickMode','auto','XTickLabel',xtix,'XTick',xtixloc);                        
    
    set(30+pc,'paperunits','centimeters','paperposition',[1 1 20 7.9])
    saveas(30+pc,sprintf('../thesis/images/exp/task2_pcw/azimuth_pc%i',pc),'epsc');   
    
    % Elevation Plots
    figure(10+pc) 
    clf;
    
    hold on
    %errorbar(idx',squeeze(sdcu(pc,4:-1:1,:,2))',20*squeeze(Ra(pc,4:-1:1,:))','o-','LineWidth',1);
    errorbar(idx',squeeze(sdca(pc,4:-1:1,:,2))',squeeze(eeeee(pc,4:-1:1,:,2))','o-','LineWidth',1);
%     errorbar(idx',squeeze(sdcfu(pc,:,:,2))',20*squeeze(Rfu(pc,:,:))','x')
    
%     yll = ylim;
%     ylim([yll(1) yll(2)*1.5]);
%     yll = ylim;
%     
%     % Text
%     for p = 1:4       
%         yl = yll(2)-yll(2)*p*0.07;
%         text(1:7,yl*ones(7,1),(num2cell(100*squeeze(ud_prop(pc,:,p)))),'Color',clr{p},'FontSize',9);
%     end    
    
%     if (pc ==4)
%     annotation('rectangle',[0.2 0.736 0.65 0.175]); 
%     else
%     annotation('rectangle',[0.2 0.75 0.65 0.175]);    
%     end
    grid on
    
    if (pc ==1)
    legend(ref_pos2,'position',[0.2 0.775 0.01 0.01])    
    elseif (pc ==2) 
    legend(ref_pos2,'position',[0.2 0.75 0.01 0.01])    
    elseif (pc ==3)
    legend(ref_pos2,'position',[0.62 0.75 0.01 0.01])
    elseif (pc==4)
    legend(ref_pos2,'position',[0.2 0.75 0.01 0.01])    
    elseif (pc ==5)
    ylim([-15 30])   
    legend(ref_pos2,'position',[0.33 0.27 0.01 0.01])   
    
    end
    
    %ylim([-90 150]) 
    
    xlabel('percentiles')
    ylabel('elevation');
    %title('Vertical Judgments') 
    
    xtix = {'','1st','12.5th','50th','87.5th','99th',''};
    xtixloc = [1:7];
    set(gca,'XTickMode','auto','XTickLabel',xtix,'XTick',xtixloc);                        
  
    
    set(10+pc,'paperunits','centimeters','paperposition',[1 1 20 7.9])
    saveas(10+pc,sprintf('../thesis/images/exp/task2_pcw/elevation_pc%i',pc),'epsc');       
    
    end
    
end

function CalcJudgements(J_az,J_el,ref_pos_az,ref_pos_el,pos_ind_text)

for pos =1:length(ref_pos_az)
    
    for pc=1:5
    
    figure(20)
    clf
    boxplot(squeeze(J_az(:,pos,pc,:)),ref_adapt)
    grid on
    xlabel('percentiles')
    ylabel('azimuth error [degree]')
    
    % Line with Reference
    a = ones(110,1)*ref_pos_az(pos);
    hold on
    plot(a,'g--')

    set(20,'paperunits','centimeters','paperposition',[1 1 12 4])
    saveas(20,sprintf('../thesis/images/exp/task2_pcw/boxplot2/az_pos%i_pc%i',pos,pc),'epsc');

  
    figure(21)
    clf
    boxplot(squeeze(J_el(:,pos,pc,:)),ref_adapt)
    grid on
    
     % Line with Reference
    a = ones(1,1)*ref_pos_el(pos);
    hold on
    plot(a,'g--')
    
    xlabel('percentiles')
    ylabel('elevation error [degree]')
    set(21,'paperunits','centimeters','paperposition',[1 1 12 4])
    saveas(21,sprintf('../thesis/images/exp/task2_pcw/boxplot2/el_pos%i_pc%i',pos,pc),'epsc');

    end
    
  
end

end


function CalcDistance(J_az,J_el,ref_pos_az,ref_pos_el,pos_ind_text)

confusions= zeros(length(subjects_ids),4,5);

for sub=1:length(subjects_ids)
    
    for pc=1:5
        for pos =1:length(ref_pos_az)
            for ad=1:size(J_az,4)
            [sdc,ee,R] = spherical_analysis(squeeze(J_az(sub,pos,pc,ad)),squeeze(J_el(sub,pos,pc,ad)),ref_pos_az(pos),ref_pos_el(pos));
            
            % Solve front/back confusions
            if (ee(1) > 90)                
                ee(1) = 90 - (ee(1) - 90);
                confusions(sub,pos,pc) = confusions(sub,pos,pc)+1;
            end
            
            if (ee(1) < -90)                
                ee(1) = -90 - (ee(1) + 90);
                confusions(sub,pos,pc) = confusions(sub,pos,pc)+1;
            end
            
            dist_az(sub,pc,pos,ad) = ee(1);
            dist_el(sub,pc,pos,ad) = ee(2);
            end
        end
    end
    
end



for pos =1:length(ref_pos_az)
    
    for pc=1:5
    
    figure(20)
    clf
    boxplot(squeeze(dist_az(:,pc,pos,:)),ref_adapt)
    grid on
    xlabel('percentiles')
    ylabel('azimuth error [degree]')
    set(20,'paperunits','centimeters','paperposition',[1 1 12 4])
    saveas(20,sprintf('../thesis/images/exp/task2_pcw/boxplot/az_pos%i_pc%i_cf',pos,pc),'epsc');

    

    figure(21)
    clf
    boxplot(squeeze(dist_el(:,pc,pos,:)),ref_adapt)
    grid on
    xlabel('percentiles')
    ylabel('elevation error [degree]')
    set(21,'paperunits','centimeters','paperposition',[1 1 12 4])
    saveas(21,sprintf('../thesis/images/exp/task2_pcw/boxplot/el_pos%i_pc%i_cf',pos,pc),'epsc');

    
    % Plot Front/back confusions of PCs
    figure(23)
    clf
    boxplot(squeeze(confusions(:,:,pc)))
    grid on
    xlabel('Positions')
    set(23,'paperunits','centimeters','paperposition',[1 1 12 4])
    saveas(23,sprintf('../thesis/images/exp/task2_pcw/confusions/fb_pc%i',pos),'epsc');

    
    end
    
    % Plot Front/back confusions of PCs
    figure(22)
    clf
    boxplot(squeeze(confusions(:,pos,:)))
    grid on
    xlabel('PCs')
    set(22,'paperunits','centimeters','paperposition',[1 1 12 4])
    saveas(22,sprintf('../thesis/images/exp/task2_pcw/confusions/fb_pos%i',pos),'epsc');

end

end



function PlotAllSubjects(J_az,J_el,ref_pos_az,ref_pos_el,pos_ind_text,subjects_ids)

    sub_colors = {'r.','b.','g.','y.','m.','k.'};

fig = 0;
for test_pc=1:5
    for test_pos =1:length(ref_pos_az)
        fig = fig+1;
        figure(fig)
        clf;
        % Sphere
        [x y z] = sphere(24); 
        h = surf(x,y,z);
        set(h,'FaceAlpha',0.05); 
        axis equal; 
        %alpha(0.2)
        %colormap(gray)a
        
        % Reference
        hold on
        [x,y,z] = sph2cart(deg2rad(ref_pos_az(test_pos)),deg2rad(ref_pos_el(test_pos)),1);
        plot3(x,y,z,'g+','MarkerSize',30,'LineWidth',2) 
        

        view(-230,20)
        rotate3d on
        
        for test_sub = 1:size(J_az,1)
        
            
            % Draw Point
            [xt,yt,zt]=sph2cart(deg2rad(squeeze(J_az(test_sub,test_pos,test_pc,:))),deg2rad(squeeze(J_el(test_sub,test_pos,test_pc,:))),1);
            hold on
            plot3(xt,yt,zt,sub_colors{test_sub},'MarkerSize',30,'LineWidth',2) 

        end

    title(sprintf('%s - PC%i',pos_ind_text{1}{test_pos},test_pc))
    set(fig,'paperunits','centimeters','paperposition',[1 1 20 11])
    saveas(fig,sprintf('../thesis/images/exp/task2_pcw/pos%i_pc%i_pc_fig1',test_pos,test_pc),'epsc');
    end
end

end


end

function PlotEachSubject(J_az,J_el,ref_pos_az,ref_pos_el,pos_ind_text,subjects_ids)

fig = 0;
for test_pc=1:5
    for test_pos =1:length(ref_pos_az)
        fig = fig+1;
        figure(fig)
        clf;
        % Sphere
        [x y z] = sphere(24);
        h = mesh(x,y,z,'CDataMapping','direct','EdgeAlpha',0.07);
        %h = surf(x,y,z);
        set(h,'FaceAlpha',0.05); 
        %set(h,'EdgeAlpha',0.07);
        alpha(0.2)
        colormap(gray)
        
        % Reference
        hold on
        [x,y,z] = sph2cart(deg2rad(ref_pos_az(test_pos)),deg2rad(ref_pos_el(test_pos)),1);
        plot3(x,y,z,'g+','MarkerSize',30,'LineWidth',2) 
        

        colors = {'r.', 'm.', 'y.', 'g.', 'y.', 'm.','r.'};
        % Plot lines between points
        
        for test_sub = 1:size(J_az,1)
        
            for ad=1:size(J_az,4)

                % Draw Point
                [xt,yt,zt]=sph2cart(deg2rad(squeeze(J_az(test_sub,test_pos,test_pc,ad))),deg2rad(squeeze(J_el(test_sub,test_pos,test_pc,ad))),1);
                hold on
                plot3(xt,yt,zt,colors{ad},'MarkerSize',30,'LineWidth',2) 

                if (ad < size(J_az,4))
                % First point
                [x1,y1,z1]=sph2cart(deg2rad(squeeze(J_az(test_sub,test_pos,test_pc,ad))),deg2rad(squeeze(J_el(test_sub,test_pos,test_pc,ad))),1);
                % Second point
                [x2,y2,z2]=sph2cart(deg2rad(squeeze(J_az(test_sub,test_pos,test_pc,ad+1))),deg2rad(squeeze(J_el(test_sub,test_pos,test_pc,ad+1))),1);

                hold on
                plot3([x1 x2],[y1 y2],[z1 z2],'r','LineWidth',2);
                end



            end
            
            
            %Axis 
        xlim([-1 1])
        ylim([-1 1])
        zlim([-1 1])
        set(gca,'XTick', []);
        set(gca, 'YTick', []);
        set(gca, 'ZTick', []);
        set(gca,'color','none')
        %set(gca,'box','off');
        axis(gca,'equal')
        axis(gca,'square')
        view(100,20)
        rotate3d on
%         set(gca,'visible','off')

        %title(sprintf('%s - PC%i',pos_ind_text{1}{test_pos},test_pc))
        set(fig,'paperunits','centimeters','paperposition',[1 1 20 11])
        saveas(fig,sprintf('../thesis/images/exp/task2_pcw/pos%i_pc%i_pc_sub%i',test_pos,test_pc,subjects_ids(test_sub)),'epsc');

        
        end
       
        
        
        
    end
end


end
