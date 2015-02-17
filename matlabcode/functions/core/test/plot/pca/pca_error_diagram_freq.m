function pca_error_diagram_freq()

% outlier in ircam: sub28, ID 1034!! ( excluded in function db_import())

dbs = {'ari','ircam','cipic'};

for db=1:length(dbs)

    % Load Error File
    error_data = sprintf('../matlabdata/test_pca/variance_error_pca_%s_new.mat',dbs{db});
    load(error_data,'conf','error');
    
    % Disp conf
    conf
    clearvars Y
    
    % Go through all parameters and create/save diagrams
    %error_files = [4 5 9 10]; % only freq error files
    error_files = [4 5];
    error_files = [3];
    for e_name = 1:length(error_files)
        e_name_file = sprintf('error.%s',conf.error_type{error_files(e_name)});
        data = eval(e_name_file);    
       
        for im =1:length(conf.input_modes)
            for is = 1:length(conf.input_structures)
                for sm = 1:length(conf.smoothing)
                    for em = 1:length(conf.ear_modes)
                        for ear = 1:length(conf.ears)
                            
                            
                            for pc=1:length(conf.pc_numbers)%-1
                            X = squeeze(data(1,1,1,ear,im,is,em,sm,pc,:,:,:));
                            X = reshape(X,size(X,1)*size(X,2),size(X,3));
                            
                            fft_points = size(X,2);
                            
                            X = X(:,1:fft_points/2);
                            
                            
                            if (isempty(findstr(conf.error_type{error_files(e_name)},'sdr')) == 0)
                            % Calc DB Error for SDR
                            X = 10*log10(X);
                            end
                            
                            % Freq Axis
                            fs = conf.database.fs;
                            freq = (0 : (fft_points/2)-1) * fs / fft_points;
                            freq = freq / 1000; % in kHz
                             
                            % Boxplot
                            figure(11)
                            clf
                            boxplot(squeeze(X),freq,'plotstyle','compact','outliersize',1)
                            title(sprintf('PCA Reconstruction Error - %s',strrep(conf.error_type{error_files(e_name)},'_','-')))
                            ylabel('error [dB]')
                            xlabel('frequency [kHz]')
                            grid on
                            
                            set(gca,'XTickLabelMode','manual')
                            set(gca,'XTickMode','manual')
                            xtix = {'1','5','10','15','20'};   % Your labels
                            
                            if (strcmp('ari',dbs{db}) == 1)
                            xtixloc = [7 28 55 81 108];      % Your label locations
                            end
                            
                            if (strcmp('cipic',dbs{db}) == 1)
                            xtixloc = [6 24 47 69 92];      % Your label locations
                            end
                            
                            if (strcmp('ircam',dbs{db}) == 1)
                            xtixloc = [13 60 118 176 234];      % Your label locations
                            xlim([0 92])
                            end
                            
                            xlim([0 max(xtixloc)])
                            set(gca,'XTickMode','auto','XTickLabel',xtix,'XTick',xtixloc);                        
                            
                            % Save as EPS for Documentation   
                            set(11,'paperunits','centimeters','paperposition',[1 1 12 7])
                            saveas(11,sprintf('../thesis/images/test_pca/boxplot_freq/%s_%s_ipm%i_ips%i_em%i_sm%i_pc%i',dbs{db},conf.error_type{error_files(e_name)},conf.input_modes(im),conf.input_structures(is),conf.ear_modes(em),conf.smoothing(sm),conf.pc_numbers(pc)),'epsc');

                            end

                        end
                    end
                end
            end
        end
    end
end
