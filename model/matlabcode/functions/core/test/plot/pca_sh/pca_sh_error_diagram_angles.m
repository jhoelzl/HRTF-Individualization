function pca_sh_error_diagram_angles

dbs = {'ircam','ari','cipic'};
dbs = {'ari'};
for db=1:length(dbs)

    % Load Error File
    error_data = sprintf('../matlabdata/test_pca_sh/variance_error_pca_sh_%s_new.mat',dbs{db});
    load(error_data,'conf','error');
    
    % Disp conf
    conf
    clearvars Y
    
    % Load Angles from database  
    az_unique = unique(conf.database.angles(:,1));
    el_unique = unique(conf.database.angles(:,2));
    
    % Go through all parameters and create/save diagrams
    error_files = [5 6];
    error_files = [5];
    for e_name = 1:length(error_files)
        e_name_file = sprintf('error.%s',conf.error_type{error_files(e_name)});
        data = eval(e_name_file); 
        
        for sh = 1:9
            for im = 1:length(conf.input_modes)
                for is = 1:length(conf.input_structures) 
                    for sm = 1:length(conf.smoothing)  
                        for em = 1:length(conf.ear_modes)   
                            for ear = 1:length(conf.ears)

                                for pc=1:length(conf.pc_numbers)
                                X = squeeze(data(1,1,1,ear,im,is,em,sm,pc,sh,:,:,:));

                                %X = 10*log10(X);
                                X = squeeze(mean(X,3));% mean over ears
                                X = squeeze(mean(X,1)); % mean over subjects

                                if (isempty(findstr(conf.error_type{error_files(e_name)},'sdr')) == 0)
                                   % Calc DB Error for SDR
                                    X = 10*log10(X);
                                end


                                for el=1:length(el_unique)
                                    for az=1:length(az_unique)
                                    Y(az,el) = 0; 

                                    answ = 0;
                                    offset = 0;
                                    while true 

                                        [Y,answ] = SearchNextPos(Y,X,conf,az,el,az_unique,el_unique,offset);
                                        if (answ == 1)
                                        break
                                        end
                                        offset = offset +2.5;
                                    end  

                                    end
                                end                            

                                figure(11)
                                clf;


                                surface(el_unique,az_unique,abs(Y),'EdgeColor', 'none');
                                ylabel('Azimuth')
                                xlabel('Elevation')
                                xlim([min(el_unique) max(el_unique)])
                                ylim([min(az_unique) max(az_unique)])    
                                colorbar
                                %caxis([0 7]);
                                title(sprintf('PCA Reconstruction Error - %s',strrep(conf.error_type{error_files(e_name)},'_','-')))
                                grid on


                                % Save as EPS for Documentation
                                if (conf.ears{ear} == [1 2])
                                    name_ear = 'both';
                                else
                                    name_ear = conf.ears{ear};
                                end

                                set(11,'paperunits','centimeters','paperposition',[1 1 12 7])
                                saveas(11,sprintf('../thesis/images/test_pca_sh/angle/%s_%s_ipm%i_ips%i_em%i_ear%s_sm%i_pc%i_sh%i',dbs{db},conf.error_type{error_files(e_name)},conf.input_modes(im),conf.input_structures(is),conf.ear_modes(em),name_ear,conf.smoothing(sm),conf.pc_numbers(pc),conf.sh_orders(sh)),'epsc');

                                end
                            end
                        end
                    end
                end
            end
        end
    end   
end

end

function [Y,answ] = SearchNextPos(Y,X,conf,az,el,az_unique,el_unique,offset)

pos_ind = find(conf.database.angles(:,2) == el_unique(el) & (conf.database.angles(:,1) >= az_unique(az)-offset)  &  (conf.database.angles(:,1) <= az_unique(az)+offset) );


if (isempty(pos_ind)) 
   Y(az,el) = 0;
   answ = 0;
else
   Y(az,el) = X(pos_ind(1));
   answ = 1;
end

end