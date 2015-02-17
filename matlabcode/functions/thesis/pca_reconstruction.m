function pca_reconstruction(db)

% Config
m.dataset.parameter.bp_mode = 0; % bp=0 no bp, or 1: using bp
m.dataset.parameter.density = 100; % percent number of source angles;
m.dataset.parameter.calc_pos = 0; % only local PCA; indicate Angle ID
m.dataset.parameter.subjects = 100; % percent number of subjects
m.dataset.parameter.ears = {[1 2]}; % ears {1  2 [1 2]}
m.dataset.parameter.smooth_ratio = 1; % smooth ratio of Fourier coefficients
m.dataset.parameter.fft_size = []; %% FFT Size, leave blank [] for standard

m.model.parameter.input_mode = 4;% lin and log magnitude
m.model.parameter.structure = 2; % Subj or Freq or Pos as columns
m.model.parameter.ear_mode = 2; % 1= ears as observations in rows, 2= ears at independent variables in columns
m.model.parameter.type = 'pca'; % pca, ica or nmf

m.weight_model.parameter.type = 'local'; % local or global
m.weight_model.parameter.order = 10; % SH Order
m.weight_model.parameter.order_initial = max(m.weight_model.parameter.order); % SH Order

dim = [1 5 10 20 50];
colorvec =  {[1 0 0], [0.7 0.7 0.7], [0 1 1],[1 0 1], [0 1 0], [0.8 0.7 0.6]};
plot_pos = 12;
plot_sub = 35;
plot_ear = 1;

figure(1)
clf;

m.model.parameter.pcs = 10;
m = core_calc(db,2,0,m); 
    
for pc = 1:length(dim)         
    
    m.set.subjects = 1:size(m.dataset.hrirs,1);
    m.model.parameter.pcs = dim(pc);
    m = evaluate_model(m);
            
    fft_points = size(m.dataset.hrtfs,4);
    freq = (0 : (fft_points/2)-1) * m.database.fs / fft_points;
    freq = freq / 1000; % in kHz

    figure(1)
    hold on
    plot(freq,20*log10(squeeze(m.set.hrtfs(plot_sub,plot_pos,plot_ear,1:length(freq)))),'color',colorvec{pc})

end

figure(1)
hold on
plot(freq,20*log10(squeeze(m.dataset.hrtfs(plot_sub,plot_pos,plot_ear,1:length(freq)))),'b')

ylabel('amplitude [dB]')
xlabel('frequency [kHz]')
xlim([0 20]) 
grid on
legend('1 PC','5 PCs','10 PCs','20 PCs','50 PCs','Original','Location','SouthWest') 

%title('PCA Reconstruction accuracy')    
az = m.dataset.angles(plot_pos,1);
el = m.dataset.angles(plot_pos,2);
    
set(1,'paperunits','centimeters','paperposition',[1 1 12 7])
saveas(1,sprintf('../thesis/images/pca_reconstr/%s_1-50pcs_pos%i_sub%i_ear%i_az%i_el%i',db,plot_pos,plot_sub,plot_ear,round(az),round(el)),'epsc');

% Variance PLot
dim2 = [1:10];
for p=1:length(dim2)
    pc_var_tot(p) = m.model.variance(p);  
    pc_var_rel(p) = m.model.latent(p)/sum(m.model.latent)*100;
      
end

figure(2)
clf
bar([pc_var_tot;pc_var_rel]','hist')

colormap summer
grid on
ylabel('variance [%]')
xlabel('principal component')
legend('absolute','relative','Location','SouthEast')
set(2,'paperunits','centimeters','paperposition',[1 1 12 7])
saveas(2,sprintf('../thesis/images/pca_reconstr/%s_var_pcs',db),'epsc');

% % PC Plots
% figure(3)
% clf;
% group = 1:128;
% %gplotmatrix(pcs(:,3),pcs(:,2),group)
% scatter(pcs(:,1),pcs(:,2))
end

