function pca_sh_error_pcws_reg()

% Test Regularization

dbs = {'ircam','cipic','ari'};
for db=1:length(dbs)

 	% Load Error File
    error_data = sprintf('../matlabdata/test_pca_sh/variance_error_pca_sh_%s_new_reg_pcs.mat',dbs{db});
    load(error_data,'conf','error');
    
    % Disp conf
    conf
    clearvars Z
    

   
    data_error = error.weight_model.weight_error;
    %data_error = error.weight_model.shape_error;
    %data_error = error.sd_hrtf_bin;
    angles = conf.database.angles;
    
    % Load Angles from database  
    az_unique = unique(angles(:,1));
    el_unique = unique(angles(:,2));
    
    
        % do through all parameters and create/save diagrams
        for im = 1:length(conf.input_modes)
            for is = 1:length(conf.input_structures)
                for sm = 1:length(conf.smoothing)
                    for em = 1:length(conf.ear_modes)
                        for ear = 1:length(conf.ears)
                            for sh = 1:length(conf.sh_orders)
                                for reg = 1:length(conf.regularize)
                                    
                                    %X = squeeze(data_error(1,1,1,ear,im,is,em,sm,1,sh,reg,:,:));    
                                    X = squeeze(data_error(1,1,1,ear,im,is,em,sm,1,sh,reg,:,:,:));
                                    pcs = [1 2 3 4 5 6 7];
                                    for pc=1:length(pcs)
                                   
                                    Y = X(:,:,pc);
                                    Y = sqrt(mean(Y.^2,2)); % mean across positions
                                    
                                    Z(sh,reg,pc) = squeeze(mean(Y)); % mean across subjects
                                  

                                    end

                                end
                            end
                            
                           % for pc=1:length(conf.pc_numbers)
                            figure(11)
                            clf;
                            plot(conf.sh_orders,squeeze(Z(:,1,:)),'o-')
                            legendCell = cellstr(num2str(pcs', 'PC%i'));
                            legend(legendCell);
                            %legend({'Pseudo-Inverse','Matrix Regularization'})
                            %legend
                            hold on                            
                            plot(conf.sh_orders,squeeze(Z(:,2,:)),'o--')
                                                                                
                            annotation('textbox',[0.4 0.71 0.1 0.1],'String','Pseudo-Inverse (solid)','BackgroundColor','w','FontSize',11, 'Color','k','LineWidth',1,'LineStyle','-')
                            annotation('textbox',[0.4 0.65 0.1 0.1],'String','Matrix-Reg. (dashed)','BackgroundColor','w','FontSize',11, 'Color','k','LineWidth',1,'LineStyle','-')

                            %char()
                            %plot(conf.sh_orders,squeeze(Z(:,1,pc))+squeeze(S(:,1,pc)),'b.--')
                            %plot(conf.sh_orders,squeeze(Z(:,1,pc))-squeeze(S(:,1,pc)),'b.--')
                            %plot(conf.sh_orders,squeeze(Z(:,2,pc))+squeeze(S(:,2,pc)),'r.--')
                            %plot(conf.sh_orders,squeeze(Z(:,2,pc))-squeeze(S(:,2,pc)),'r.--')
                            grid on
                            xlabel('SH Order')
                            ylabel('RMSE')
                            xlim([1 8])
                            % Save as EPS
                            set(11,'paperunits','centimeters','paperposition',[1 1 17 12])
                            saveas(11,sprintf('../thesis/images/test_pca_sh/weight_error_reg/%s_rmse',dbs{db}),'epsc');
                           % end
                                 
                        end
                    end
                end
            end
        end
  
end
end


function [Y,answ] = SearchNextPos(Y,Z,conf,az,el,az_unique,el_unique,offset)

pos_ind = find(conf.database.angles(:,2) == el_unique(el) & (conf.database.angles(:,1) >= az_unique(az)-offset)  &  (conf.database.angles(:,1) <= az_unique(az)+offset) );


if (isempty(pos_ind)) 
   Y(az,el) = 0;
   answ = 0;
else
   Y(az,el) = squeeze(Z(:,pos_ind(1)));
   answ = 1;
end

end
