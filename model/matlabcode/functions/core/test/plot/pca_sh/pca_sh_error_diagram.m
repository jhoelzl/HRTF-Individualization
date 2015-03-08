function pca_sh_error_diagram()

dbs = {'ircam','ari','cipic'};
dbs = {'ari'};

for db=1:length(dbs)

    % Load Error File
    error_data = sprintf('../matlabdata/test_pca_sh/variance_error_pca_sh_%s_new.mat',dbs{db});
    load(error_data,'conf','error');
    
    % Disp conf
    conf
    clearvars Y
    
    % Go through all parameters and create/save diagrams
    error_files = [2 3];
    for e_name = 1:length(error_files)
        e_name_file = sprintf('error.%s',conf.error_type{error_files(e_name)})
        data = eval(e_name_file);    
       for sh = 1:length(conf.sh_orders)
           for reg = 1:1%length(conf.regularize)
            for im = 1:length(conf.input_modes)
            for is = 1:length(conf.input_structures)
                for sm = 1:length(conf.smoothing)
                    for em = 1:length(conf.ear_modes)
                        for ear = 1:length(conf.ears)
                            
                            if (conf.ears{ear} == [1 2])
                                name_ear = 'both';
                            elseif (conf.ears{ear} == [1])
                                name_ear = 'left';
                            elseif (conf.ears{ear} == [2])
                                name_ear = 'right';    
                            end
                            
                            
                            for pc=1:length(conf.pc_numbers)-1
                                X = squeeze(data(1,1,1,ear,im,is,em,sm,pc,sh,reg,:,:,:));
                                Y(pc,:) = reshape(X,1,[]);

                                if (isempty(findstr(conf.error_type{error_files(e_name)},'sdr')) == 0)
                                % Calc DB Error for SDR

                                %X = squeeze(mean(X,3));  % mean over ears
                                %X = squeeze(mean(X,2)); % mean over positions
                                %X = squeeze(mean(X,1)); % mean over subjects

                                Y(pc,:) = 10*log10(Y(pc,:));
                                end

                                % 
                                
                                dn = Y(pc,:);
                                
                                ND = length(dn);

                                %dn = TM + TS*randn(ND,1);

                                figure(9)
                                clf;
                                hold on;
                                M = mean(dn); s = std(dn);
                                [N,n] = hist(dn,(M-3*s):(3.5*s/ND^(1/3)):(M+3*s));
                                bar(n,N/trapz(n,N),'b');
                                %plot((M-3*s):0.01:(M+3*s),normpdf((M-3*s):0.01:(M+3*s),M,s),'r','LineWidth',1.5);
                                
                                h1 = plot(M,0.8,'sk');
                                %h2 = plot(TM,0.7,'sr');
                                %legend([h1 h2],{'Observed Mean','True Mean'});
                                %herrorbar(M,0.8,s,'k');
                                %herrorbar(TM,0.7,TS,'r');
                                ylim([0 max(N/trapz(n,N))]+0.05); grid on;
                                %xlabel('Observed Value','FontSize',16);ylabel('PDF-Value','FontSize',16);
                                %title(sprintf('Normal PDF sampled %d times',ND),'FontSize',16);
                                % path = '/Volumes/Projects/teaching/Interactive Audio Systems/slides/04-design&analysis/images/n_';
                                % saveas(gcf,sprintf('%s%d.eps',path,ND),'eps');

                                
                                
                                % Histogram for each PC
                                % Histogram
                               % figure(9)
%                                 clf
%                                 hist(squeeze(Y(pc,:)))
%                                 title(sprintf('PCA Reconstruction Error - %s',strrep(conf.error_type{error_files(e_name)},'_','-')))
%                                 xlabel('error [dB]')
%                                 ylabel('distribution')
%                                 grid on

                                % Save as EPS for Documentation                            
                               set(9,'paperunits','centimeters','paperposition',[1 1 12 7])
                               saveas(9,sprintf('../thesis/images/test_pca_sh/hist_pcs/pc%i/%s_%s_ipm%i_ips%i_em%i_ear%s_sm%i_sh%i_pd',conf.pc_numbers(pc),dbs{db},conf.error_type{error_files(e_name)},conf.input_modes(im),conf.input_structures(is),conf.ear_modes(em),name_ear,conf.smoothing(sm),conf.sh_orders(sh)),'epsc');

                            end
                            
                            % Boxplot
                            figure(11)
                            clf
                            boxplot(squeeze(Y'),conf.pc_numbers(1:end-1))
                            title(sprintf('PCA-SH Reconstruction Error - %s',strrep(conf.error_type{error_files(e_name)},'_','-')))
                            xlabel('PCs')
                            ylabel('error [dB]')
                            grid on
                            
                           % Save as EPS for Documentation   
                           set(11,'paperunits','centimeters','paperposition',[1 1 12 7])
                           saveas(11,sprintf('../thesis/images/test_pca_sh/boxplot/%s_%s_ipm%i_ips%i_em%i_ear%s_sm%i_sh%i',dbs{db},conf.error_type{error_files(e_name)},conf.input_modes(im),conf.input_structures(is),conf.ear_modes(em),name_ear,conf.smoothing(sm),conf.sh_orders(sh)),'epsc');
                          
                            
%                             % Histogram
%                             figure(12)
%                             clf
%                             hist(squeeze(Y'),conf.pc_numbers(1:end-1))
%                             title(sprintf('PCA Reconstruction Error - %s',strrep(conf.error_type{e_name},'_','-')))
%                             xlabel('PCs')
%                             ylabel('')
%                             grid on
%                             
%                             
%                             set(12,'paperunits','centimeters','paperposition',[1 1 12 7])
%                             saveas(12,sprintf('../thesis/images/test_pca/hist/%s_%s_ipm%i_ips%i_em%i_ear%s_sm%i',dbs{db},conf.error_type{error_files(e_name)},conf.input_modes(im),conf.input_structures(is),conf.ear_modes(em),name_ear,conf.smoothing(sm)),'epsc');
%                             
                        end
                    end
                        end
                    end
                end
            end
        end
    end
end