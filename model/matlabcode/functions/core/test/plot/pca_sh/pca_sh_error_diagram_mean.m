function pca_sh_error_diagram_mean(mode)

% mode 1 = SHS in legend, PCs in x-axis
% mode 2 = PCs in legend, SHs in x-acis

dbs = {'ari'};

for db=1:length(dbs)

 	% Load Error File
    error_data = sprintf('../matlabdata/test_pca_sh/pca_sh_%s_exam.mat',dbs{db});
    load(error_data,'conf','error');
    
    % Disp conf
    conf
    clearvars Y1 
    
    % Go through all parameters and create/save diagrams
    error_files = [2 3];
    error_files = [1];
    for e_name = 1:length(error_files)
        e_name_file = sprintf('error.%s',conf.error_type{error_files(e_name)});
        data = eval(e_name_file);    
   
        % do through all parameters and create/save diagrams
        for im = 1:length(conf.input_modes)
            for is = 1:length(conf.input_structures)
                for sm = 1:length(conf.smoothing)
                    for em = 1:length(conf.ear_modes)
                        for ear =1;% 1:length(conf.ears)
                            for sh = 1:length(conf.sh_orders)
                                
                            for pc=1:length(conf.pc_numbers)-1
                            X = squeeze(data(1,1,1,ear,im,is,em,sm,pc,sh,:,:,:));
                            X = squeeze(mean(X,3)); % mean over ears
                            X = squeeze(mean(X,2)); % mean over positions
                            X = squeeze(mean(X,1)); % mean over subjects
                            Y1(sh,pc,:) = X;
                            
                            C1(sh,pc,:) = squeeze(conf.sh_cond(1,1,1,ear,im,is,em,sm,pc,sh));
                           
                            end
                            
                            end
                            
                            
                            figure(11)
                            clf
                            
                            if (mode==1) % PCs in x-axis
                                
                            % add PCA model as reference
                            data2 = openPCAdata(im,sm,dbs{db},e_name_file);
                            
                            Y2 = [Y1;data2'];
                            
%                             cc = hsv(9);
%                             for it=1:9
%                             hold on
                            %set(11,'DefaultAxesColorOrder',jet(9))
                            plot(conf.pc_numbers(1:end-1),Y2)
%                             end
                            
                            
                            title(sprintf('PCA-SH Reconstruction Error - %s',strrep(conf.error_type{error_files(e_name)},'_','-')))
                            xlabel('PCs')
                            ylabel('error [dB]')
                            grid on
                            file_name = 'shs';
                            xlim([0 50])
                            
                            legend('SH1','SH2','SH3','SH4','SH8','Ref','Location','NorthEast')
                           
                            end
                            
                            if (mode==2) % SHs in x-axis
                                
                            % add PCA model as reference    
                            data2 = openPCAdata(im,sm,dbs{db},e_name_file);
                            Y2 = [Y1' data2];
                                
                            %plot(conf.sh_orders(1:8),Y2)                   
                            plot(Y2')
                            set(gca,'XTickLabelMode','manual')
                            set(gca,'XTickMode','manual')
                            set(gca,'XTickLabel',{'1','2','3','4','5','6','7','8','Ref'})
%           
                            title(sprintf('PCA-SH Reconstruction Error - %s',strrep(conf.error_type{error_files(e_name)},'_','-')))
                            xlabel('SH order')
                            ylabel('error [dB]')
                            legend('PC1','PC5','PC10','PC20','PC50','Location','NorthWest')
                            grid on
                            file_name = 'pcs';
                            %xlim([1 9])
                            end
                            
%                             figure(12)
%                             xlabel('SH order')
%                             ylabel('Cond Number')
%                             plot(conf.sh_orders,C1')
%                             

                            % Save as EPS for Documentation

                            if (conf.ears{ear} == [1 2])
                                name_ear = 'both';
                            else
                                name_ear = conf.ears{ear};
                            end

                            set(11,'paperunits','centimeters','paperposition',[1 1 15 8.75])% 1 1 12 7

                            saveas(11,sprintf('../thesis/images/test_pca_sh/mean_overview/%s_%s_ipm%i_ips%i_em%i_ear%s_sm%i_%s',dbs{db},conf.error_type{error_files(e_name)},conf.input_modes(im),conf.input_structures(is),conf.ear_modes(em),name_ear,conf.smoothing(sm),file_name),'epsc');

                    
                end
            end
        end
    end
end

end
end


end

function [Y1] = openPCAdata(im,sm,db,e_name_file)


error_data = sprintf('../matlabdata/test_pca/pca_%s.mat',db);
load(error_data,'conf','error');
conf

%e_name_file = sprintf('error.%s',conf.error_type{6});
data = eval(e_name_file); 
        
im = 2;
    for pc=1:length(conf.pc_numbers)-1
    X = squeeze(data(1,1,1,2,4,1,2,sm,pc,:,:,:));
    X = squeeze(mean(X,3));% mean over ears
    X = squeeze(mean(X,2)); % mean over positions
    X = squeeze(mean(X,1)); % mean over subjects
    Y1(pc,:) = X;

    end
                            
end