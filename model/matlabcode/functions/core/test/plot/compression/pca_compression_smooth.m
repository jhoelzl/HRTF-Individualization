function pca_compression_smooth(db,input_mode)

% PCA compression effiency for different smoothing ratios

% config:
ears = 3;
input_struct = 2;
ear_mode = 2;
posmode =1;
bpmode = 1;

% Load Error File
error_data = sprintf('../matlabdata/test_pca/variance_pca_%s.mat',db);
load(error_data,'pcs_variance','conf');

% Show conf
conf
X(:,:) = squeeze(pcs_variance(bpmode,posmode,ears,input_mode,input_struct,ear_mode,:,:));

figure(3)
clf;
plot(squeeze(X'));

legend(cellstr(num2str(conf.frequency_smoothing', '%-d')),'Location','SouthEast')
xlim([0 30])
ylim([75 100])
title('PCA compression efficiency')
xlabel('PC number')
ylabel('percent variance')
grid on

% Linie 90%
a = ones(110,1)*90;
hold on
plot(a,'k-.')

%Save
set(3,'paperunits','centimeters','paperposition',[1 2 15 10])
saveas(3,sprintf('../thesis/images/compression/smoothing/%s_pca_compression_inpm%i_inps%i_em%i',db,input_mode,input_struct,ear_mode),'epsc');
end