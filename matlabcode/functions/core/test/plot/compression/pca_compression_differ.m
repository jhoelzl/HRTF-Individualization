function pca_compression_differ()

% PCA compression efficiency for different parameters and databases

for inp=3:4
    for em=1:2
    
    figure(3)
    clf;

    %pca_compression_get('ari',0,'b','-',inp,em)
    %pca_compression_get('cipic',0,'b','--',inp,em)
    %pca_compression_get('ircam',0,'b','-.',inp,em)

    pca_compression_get('ari',2,'r','-',inp,em)
    pca_compression_get('cipic',2,'r','--',inp,em)
    pca_compression_get('ircam',2,'r','-.',inp,em)
    
    pca_compression_get('ari',100,'g','-',inp,em)
    pca_compression_get('cipic',100,'g','--',inp,em)
    pca_compression_get('ircam',100,'g','-.',inp,em)
    
    pca_compression_get('ari',50,'y','-',inp,em)
    pca_compression_get('cipic',50,'y','--',inp,em)
    pca_compression_get('ircam',50,'y','-.',inp,em)

    xlim([0 60])
    ylim([60 100])
    legend('ARI, entire db', 'CIPIC, entire db', 'IRCAM, entire db', 'ARI, one position', 'CIPIC, one position', 'IRCAM, one position','Location','SouthEast')
    grid on
    title('PCA compression efficiency')
    xlabel('PC number')
    ylabel('variance [%]')

    % Linie 90%
    a = ones(110,1)*90;
    hold on
    plot(a,'k-.')

    %Save
    set(3,'paperunits','centimeters','paperposition',[1 1 15 10])
    %saveas(3,sprintf('../thesis/images/compression/positions/difference_m%i_em%i_test',inp,em),'epsc');
    end
end
end


function pca_compression_get(db,pos,color,marker,inp,em)
% test only left ear
% test compression effiency of: HRIR/ DTF magnitude / log DTF magnitude
% pos: zero = all positions; >0: the angle_ID of the pos
disp(db)

m.dataset.parameter.bp_mode = 0; % bp=0 no bp, or 1: using bp
m.dataset.parameter.density = 100; % percent number of source angles;
m.dataset.parameter.calc_pos = pos; % only local PCA; indicate Angle ID
m.dataset.parameter.subjects = 100; % percent number of subjects
m.dataset.parameter.ears = {[1 2]}; % ears {1  2 [1 2]}
m.dataset.parameter.smooth_ratio = 1; % smooth ratio of Fourier coefficients
m.dataset.parameter.fft_size = []; %% FFT Size, leave blank [] for standard

m.model.parameter.input_mode = inp;% lin and log magnitude
m.model.parameter.structure = 2; % Subj or Freq or Pos as columns
m.model.parameter.ear_mode = em; % 1= ears as observations in rows, 2= ears at independent variables in columns
m.model.parameter.type = 'pca'; % pca, ica or nmf
m.model.parameter.pcs = 10; % PC Numbers %1 5 10 20

m.weight_model.parameter.type = 'local'; % local or global
m.weight_model.parameter.order = 10; % SH Order
m.weight_model.parameter.order_initial = max(m.weight_model.parameter.order); % SH Order
m.weight_model.parameter.regularize = 0; % Matrix Regularization

    
m = core_calc(db,2,0,m);

figure(3)
hold on
plot(m.model.variance(1:100),strcat(color,marker));

end

