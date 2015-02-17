function test_regu(db)
    
% Model Config
m.dataset.parameter.bp_mode = 0; % bp=0 no bp, or 1: using bp
m.dataset.parameter.density = 100; % percent number of source angles;
m.dataset.parameter.subjects = 100; % percent number of subjects
m.dataset.parameter.ears = {[1 2]}; % ears {1  2 [1 2]}
m.dataset.parameter.smooth_ratio = 1; % smooth ratio of Fourier coefficients
m.dataset.parameter.fft_size = []; % FFT Size, leave blank [] for standard
m.dataset.parameter.calc_pos = 0; % local PCA

m.model.parameter.input_mode = 4;% lin and log magnitude
m.model.parameter.structure = 2; % Subj or Freq or Pos as columns
m.model.parameter.ear_mode = 2; % 1= ears as observations in rows, 2= ears at independent variables in columns
m.model.parameter.type = 'pca'; % pca, ica or nmf
m.model.parameter.pcs = 10; % PC Numbers %1 5 10 20
m.weight_model.parameter.type = 'global'; % local or global

% Plot Config
plot_sub = [1];
plot_sub_mn = 0; % plot mean PCWs over subjects or plot_sub id
test_sh=[1 2 5 6]; 
plot_orig = 0; % 0= plot modelled PCWs; 1=plot original PCWs 
plot_mode = [0]; % 0=3d sphere;; 1=3d radial 2=3d point_plot
mesh_mode = [1]; % 0=use linespace; 1=use database points
max_pc = 5; % plot each pc until max_pc
 
if (plot_sub_mn == 1)
    plot_sub = 999;
end

for sh=1:length(test_sh)   
    fprintf('SH%i\n',test_sh(sh))
    for reg=0%:1%0:1         
        fprintf('-REG%i\n',reg)
        
        m.weight_model.parameter.order = test_sh(sh); % SH Order
        m.weight_model.parameter.order_initial = test_sh(sh); % Intial SH Order            
        m.weight_model.parameter.regularize = reg; % Matrix Regularization

        % Calc Model
        m = core_calc(db,1,0,m);

        % Reshape PCWs
        sz_temp = m.model.parameter.sz; sz_temp(3) = 1;sz_temp(4) = size(m.model.weights,2);
        pcws = ireshape_model(m.weight_model.weights,m.model.parameter.structure,sz_temp,m.model.parameter.ear_mode);

        for sub=1:length(plot_sub)  
            
            % Plot Modeled PCWs
            if (plot_orig == 0)
                for plotm = 1:length(plot_mode)
                    
                    for meshm = 1:length(mesh_mode) 
                    % Mean across subjects
                    if (plot_sub_mn == 1) 
                    pcws = squeeze(mean(pcws,1));
                    else
                    pcws = squeeze(pcws(plot_sub(sub),:,:,:));    
                    end                

                    pcw_plot(m.dataset.angles,pcws,plot_mode(plotm),max_pc,m.weight_model.parameter.order,m.weight_model.parameter.regularize,m.database.name,plot_sub(sub),mesh_mode(meshm),'modeled')
                    end
               end
            end
            
            % Plot Original PCWs
            if (sh ==1) && (reg == 0) && (plot_orig == 1)           
            pcws_orig = ireshape_model(m.model.weights,m.model.parameter.structure,sz_temp,m.model.parameter.ear_mode);           
            
                for plotm = 1:length(plot_mode)
                    
                    for meshm = 1:length(mesh_mode) 
                    if (plot_sub_mn == 1)
                     % Mean across subjects
                    pcws = squeeze(mean(pcws_orig,1));
                    else
                    pcws = squeeze(pcws_orig(plot_sub(sub),:,:,:));    
                    end

                    pcw_plot(m.dataset.angles,pcws,plot_mode(plotm),max_pc,m.weight_model.parameter.order,m.weight_model.parameter.regularize,m.database.name,plot_sub(sub),mesh_mode(meshm),'original') 
                    end
                end
            end            
        end
    end
end
end