function pcws_variation(db,pcw_mode)

% Plot Variations of the PCWs across angles in horizontal and median plane

% Input
% db: hrtf database name
% pcw_mode: 1='database pcws; 2 = modeled pcws though SH model

m.dataset.parameter.bp_mode = [0]; % bp=0 no bp, or 1: using bp
m.dataset.parameter.density = [100]; % percent number of source angles;
m.dataset.parameter.subjects = [100]; % percent number of subjects
m.dataset.parameter.ears = {[1 2]}; % ears {1  2 [1 2]}
m.dataset.parameter.smooth_ratio = [1]; % smooth ratio of Fourier coefficients
m.dataset.parameter.fft_size = []; %% FFT Size, leave blank [] for standard
m.dataset.parameter.calc_pos = 0; %

m.model.parameter.input_mode = [4];% lin and log magnitude
m.model.parameter.structure = [2]; % Subj or Freq or Pos as columns
m.model.parameter.ear_mode = [2];
m.model.parameter.type = 'pca'; % pca, ica or nmf
m.model.parameter.pcs = [10]; % PC Numbers %1 5 10 20

if (pcw_mode ==1)
    m.weight_model.parameter.type = 'local';
elseif (pcw_mode ==2)
    m.weight_model.parameter.type = 'global';
end

m.weight_model.parameter.order = 3; % SH Order
m.weight_model.parameter.order_initial = max(m.weight_model.parameter.order); % SH Order
m.weight_model.parameter.regularize = 0; % Matrix Regularization

force_calc = 1;
calc_mode = 1;
m = core_calc(db,calc_mode,force_calc,m);

% Reshape
sz_temp = m.model.parameter.sz; sz_temp(3) = 1;sz_temp(4) = size(m.model.weights,2);

if (pcw_mode ==1)
pcws_res = ireshape_model(m.model.weights,m.model.parameter.structure,sz_temp,m.model.parameter.ear_mode);
elseif pcw_mode ==2
pcws_res = ireshape_model(m.weight_model.weights,m.model.parameter.structure,sz_temp,m.model.parameter.ear_mode);
end

for mode=1:2
    
    % Only PCWs of angles in median or hozitontal plane
    if (mode == 1)
        [angle_ids_median,angles_values] = angles_median(m.dataset.angles);
    elseif(mode == 2)
        [angle_ids_median,angles_values] = angles_horizontal(m);
    end

    % PLOTTING   
    for pc=1:5%:1
% 
%             figure(2)
%             clf;

%             % Plot
%             figure(2)
%             plot(angles_values,squeeze(pcws_res(:,angle_ids_median,:,pc))',strcat('b','.'));
%             grid on;
%             title(sprintf('Distribution of PCW%i',pc))
% 
%             if (mode == 1)
%                 xlabel('elevation') 
%             elseif(mode == 2)
%                 xlabel('azimuth')
%             end
%             %xlim([-50 180])
%             ylabel('magnitude')
% 
%             hold on
%             plot(angles_values,median(squeeze(pcws_res(:,angle_ids_median,:,pc)))','r','LineWidth',2);

            % Save as EPS
    %         set(2,'paperunits','centimeters','paperposition',[1 1 12 8])
    %         if (mode == 1)
    %         saveas(2,sprintf('../thesis/images/pcws/median/pcw%i_%s',pc,db),'epsc');
    %         elseif(mode == 2)
    %         saveas(2,sprintf('../thesis/images/pcws/horizontal/pcw%i_%s',pc,db),'epsc');   
    %         end


            % Boxplot
            figure(3)
            clf;
            boxplot(squeeze(pcws_res(:,angle_ids_median,:,pc)),angles_values,'plotstyle','compact')

            % Tick Positionen setzen 
            
            if (mode == 1) && (strcmp(db,'ari') == 1)
            set(gca,'XTickLabelMode','manual')
            set(gca,'XTickMode','manual')
            set(gca,'xtick',[find(angles_values == -30) find(angles_values == 0) find(angles_values == 30) find(angles_values == 60) find(angles_values == 80) find(angles_values == 120) find(angles_values == 150) find(angles_values == 180) find(angles_values == 210)], 'xticklabel',{'-30','0','30','60','80','120','150','180','210'})
            end
            
            if (mode == 2) && (strcmp(db,'ari') == 1)
            set(gca,'XTickLabelMode','manual')
            set(gca,'XTickMode','manual')
            set(gca,'xtick',[find(angles_values == 0) find(angles_values == 22.5) find(angles_values == 45) find(angles_values == 90) find(angles_values == 135) find(angles_values == 180) find(angles_values == 225) find(angles_values == 270) find(angles_values == 315) find(angles_values == 337.5)], 'xticklabel',{'0','22.5','45','90','135','180','225','270','315','337.5'})
            end
            
            if (mode == 2) && (strcmp(db,'cipic') == 1)
            set(gca,'XTickLabelMode','manual')
            set(gca,'XTickMode','manual')
            set(gca,'xtick',[find(angles_values == 0) find(angles_values == 40) find(angles_values == 80) find(angles_values == 125) find(angles_values == 160) find(angles_values == 200) find(angles_values == 235) find(angles_values == 280) find(angles_values == 320)], 'xticklabel',{'0','40','80','125','160','200','235','280','320'})
            end
            
            
            
            grid on
            title(sprintf('Distribution of PCW%i',pc))

            if (mode == 1)
                xlabel('elevation') 
                %set(gca,'XTickLabelMode','manual','XTickMode','manual','XTickLabel',[-30 0 45 90 180 250])
            elseif(mode == 2)
                xlabel('azimuth')
            end
            %xlim([-50 180])
            ylabel('magnitude')

            %set(findobj(gca,'Type','text'),'FontSize',5)


            % Save as EPS
            set(3,'paperunits','centimeters','paperposition',[1 1 18 10])
            if (mode == 1)
                if (pcw_mode == 1)
                saveas(3,sprintf('../thesis/images/pcws/median/pcw%i_%s_box',pc,db),'epsc');
                elseif (pcw_mode ==2)
                saveas(3,sprintf('../thesis/images/pcws_sh/median/pcw%i_sh%i_%s_box',pc,m.weight_model.parameter.order,db),'epsc');    
                end
            elseif(mode == 2)
                if (pcw_mode == 1)
                saveas(3,sprintf('../thesis/images/pcws/horizontal/pcw%i_%s_box',pc,db),'epsc');   
                elseif (pcw_mode ==2)
                saveas(3,sprintf('../thesis/images/pcws_sh/horizontal/pcw%i_sh%i_%s_box',pc,m.weight_model.parameter.order,db),'epsc');
                end
            end

%             figure(4)
%             clf;
%     %         boxplot(squeeze(pcws_res(:,angle_ids_median,:,pc)),angles_values,'plotstyle','compact')
%     %         hold on
%     %         plot(mean(squeeze(pcws_res(:,angle_ids_median,:,pc)))','r','LineWidth',2);
%     %        
% 
%             grid on;
%             title(sprintf('Distribution of PCW%i',pc))
% 
%             if (mode == 1)
%                 xlabel('elevation') 
%                % set(gca,'XTickMode','manual','XTickLabel',[-30 0 90 180 250])
%             elseif(mode == 2)
%                 xlabel('azimuth')
%             end
%             %xlim([-50 180])
%             ylabel('magnitude')


            % Save as EPS
    %         set(4,'paperunits','centimeters','paperposition',[1 1 18 10])
    %         if (mode == 1)
    %         saveas(4,sprintf('../thesis/images/pcws/median/pcw%i_%s_box2',pc,db),'epsc');
    %         elseif(mode == 2)
    %         saveas(4,sprintf('../thesis/images/pcws/horizontal/pcw%i_%s_box2',pc,db),'epsc');   
    %         end
    %         
            % PCs
            figure(5)
            clf;
            N = size(m.dataset.hrirs,4);
%             freq = (0 : (N/2)) * model.database.fs / N;
            
            % Freq Axis
            freq = (0 : (N/2)-0) * m.database.fs / N;
            freq = freq; % in kHz
            
            plot(freq,m.model.basis(1:length(freq),pc),'b')
            hold on
            plot(freq,m.model.basis(length(freq)+1:end,pc),'r')
            legend({'left ear','right ear'},'Location','NorthWest')
            grid on
            ylabel('magnitude')
            xlabel('frequency [kHz]')

%             min(freq)
%             max(freq)
            set(gca,'XTick',freq)
            set(gca,'XTickLabel',sprintf('%i|',freq))

            set(gca,'XTickLabelMode','manual')
            set(gca,'XTickMode','manual')
            set(gca,'xtick',[1000 5000 10000 15000 20000], 'xticklabel',{'1','5','10','15','20'})
            xlim([0 20000])
            
                                        
%             set(gca,'XTickLabelMode','manual')
%             set(gca,'XTickMode','manual')
%             xtix = {'1','5','10','15','20'};   % Your labels
% 
%             if (strcmp('ari',db) == 1)
%             xtixloc = [7 28 55 81 108];      % Your label locations
%             end
% 
%             if (strcmp('cipic',db) == 1)
%             xtixloc = [6 24 47 69 92];      % Your label locations
%             end
% 
%             if (strcmp('ircam',db) == 1)
%             xtixloc = [13 60 118 176 234];      % Your label locations
%             xlim([0 92])
%             end
% 
%             %xlim([0 max(xtixloc)])
%             xlim([0 20])
%             set(gca,'XTickMode','auto','XTickLabel',xtix,'XTick',xtixloc);                        

                            
            title(sprintf('Variation of PC%i',pc))
            % Save as EPS
            set(5,'paperunits','centimeters','paperposition',[1 1 18 10])
            saveas(5,sprintf('../thesis/images/pcws/median/pc%i_%s',pc,db),'epsc');


    end
end
end
