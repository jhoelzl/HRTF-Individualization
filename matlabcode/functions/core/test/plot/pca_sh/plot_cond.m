function plot_cond( )

dbs = {'ARI','CIPIC','IRCAM'};
cls = {'b','g','r'};
figure(9)
clf

for db=1:length(dbs)

 	% Load Error File
    error_data = sprintf('../matlabdata/test_pca_sh/variance_error_pca_sh_%s.mat',dbs{db});
    load(error_data,'conf');
    
    % Disp conf
    conf
    clearvars Y
    

    % go through all parameters and create/save diagrams
    for im = 1:length(conf.input_modes)
        for is = 1:length(conf.input_structures)
            for sm = 1%1:length(conf.smoothing)
                for em = 1:length(conf.ear_modes)
                    for ear = 1:length(conf.ears)

                        for sh = 1:length(conf.sh_orders)

                            %for pc=1:length(conf.pc_numbers)-1
                            X(sh) = squeeze(conf.sh_cond(ear,im,is,em,sm,1,sh));
                            %end

                        end

                       % Plot
                        figure(9)
                        hold on
                        plot(X,cls{db})
                        
                        title('Condition Number')
                        xlabel('SH order')
                        ylabel('Condition number')
                        grid on
                        


                       
                    end
                end
            end
        end
    end
end

legend(dbs,'Location','NorthWest')
set(gca,'xtick', [1:10])
%set(gca,'xticklabel',string_with_valuses_you_want)
    
xlim([1 7])
ylim([0 20])
set(9,'paperunits','centimeters','paperposition',[1 1 12 7])
saveas(9,sprintf('../thesis/images/test_pca_sh/cond/ipm%i_ips%i_em%_sm%i',conf.input_modes(im),conf.input_structures(is),conf.ear_modes(em),conf.smoothing(sm)),'epsc');


end

