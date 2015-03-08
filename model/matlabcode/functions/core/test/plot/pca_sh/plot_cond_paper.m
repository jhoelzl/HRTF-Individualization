function plot_cond_paper( )

dbs = {'ARI','CIPIC','IRCAM'};
cls = {'b','g','r'};
mark= {'^','o','*','+'};
figure(9)
clf

for db=1:length(dbs)

 	% Load Error File
    error_data = sprintf('../matlabdata/test_pca_sh/variance_error_pca_sh_%s_cond.mat',dbs{db});
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
                            bpmode =1;
                            submode=1;
                            posmode =1;
                            X(sh) = squeeze(conf.sh_cond(bpmode,submode,posmode,ear,im,is,em,sm,1,sh));
                            %end

                        end

                       % Plot
                        figure(9)
                        hold on
                        plot(X,'Color','k','Marker',mark{db},'LineStyle','--')
                        
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
    
xlim([1 6])
ylim([0 20])
set(9,'paperunits','centimeters','paperposition',[1 1 12 7])
%saveas(9,sprintf('../thesis/images/test_pca_sh/cond/ipm%i_ips%i_em%_sm%i',conf.input_modes(im),conf.input_structures(is),conf.ear_modes(em),conf.smoothing(sm)),'epsc');
saveas(9,sprintf('../paper/dafx14/v1/images/cond_ipm%i_ips%i_em%_sm%i',conf.input_modes(im),conf.input_structures(is),conf.ear_modes(em),conf.smoothing(sm)),'epsc');


end

