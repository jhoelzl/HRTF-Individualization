function test_smooth(db,smooths)
% Input: smooths , for example [1 2 4 8 16 32];

m.database.name = db;
m.dataset.parameter.bp_mode = 0; % bp=0 no bp, or 1: using bp
m.dataset.parameter.density = 100; % percent number of source angles;
m.dataset.parameter.calc_pos = 0; % only local PCA; indicate Angle ID
m.dataset.parameter.subjects = 100; % percent number of subjects
m.dataset.parameter.ears = {[1 2]}; % ears {1  2 [1 2]}
m.dataset.parameter.fft_size = []; %% FFT Size, leave blank [] for standard

m.model.parameter.input_mode = 4;% lin and log magnitude
m.model.parameter.structure = 2; % Subj or Freq or Pos as columns
m.model.parameter.ear_mode = 2; % 1= ears as observations in rows, 2= ears at independent variables in columns
m.model.parameter.type = 'pca'; % pca, ica or nmf
m.model.parameter.pcs = 10; % PC Numbers %1 5 10 20

m.weight_model.parameter.type = 'local'; % local or global
m.weight_model.parameter.order = 10; % SH Order
m.weight_model.parameter.order_initial = max(m.weight_model.parameter.order); % SH Order
m.weight_model.parameter.regularize = 0; % Matrix Regularization

clr = {'k','b','g','r','m',[.7 .5 0],'c','y'};
sub = 28;
pos = 6;
ear = 1;

figure(1)
clf;
    
for sm=1:length(smooths)

    m.dataset.parameter.smooth_ratio = smooths(sm);
    m = core_calc(db,3,0,m);
    smooth_real(sm) = m.dataset.parameter.frequency_smooth;
    
    N = size(m.dataset.hrtfs,4)/2+1;
    freq = (0 : N-1) * m.database.fs / size(m.dataset.hrtfs,4);
    freq = freq / 1000; % in kHz
    figure(1)
    
    % Plot Smooth
    hold on
    plot(freq,20*log10(squeeze(m.dataset.hrtfs(sub,pos,ear,1:N))),'Color',clr{sm})

    
end

grid on
xlabel('frequency [kHz]')
ylabel('magnitude [dB]')    
%legendstr = {'Original'};
%legendstr2 = cellstr(num2str(smooths', '%i'));
%legendstr3 = cat(1,legendstr,legendstr2);

legendstr3 = cellstr(num2str(smooth_real', '%i'));
legend(legendstr3,'Location','SouthWest')
xlim([0 20])

%Save
set(1,'paperunits','centimeters','paperposition',[1 2 15 10])
saveas(1,sprintf('../thesis/images/spectrum/smoothing/db_%s_smooth',db),'epsc');
saveas(1,sprintf('../thesis/images/spectrum/smoothing/db_%s_smooth',db),'fig');

end