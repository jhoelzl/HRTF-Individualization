function pca_compression_pos(db,input_mode,input_struct)

% Show PCA compression efficiency when inlcuding number of positions

% config:
ears = 3;
ear_mode = 2;
submode =1;
bpmode = 1;
smooth = 1;

% Load Error File
error_data = sprintf('../matlabdata/test_pca/variance_pca_%s_pos.mat',db);
load(error_data,'pcs_variance','conf');

% Show conf
conf
X(:,:) = squeeze(pcs_variance(submode,bpmode,:,ears,input_mode,input_struct,ear_mode,smooth,:));

figure(3)
clf;
plot(squeeze(X'));

legend(cellstr(num2str(conf.densities_real', '%-d')),'Location','SouthEast')
xlim([0 40])
%ylim([50 100])
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
saveas(3,sprintf('../thesis/images/compression/positions/%s_pca_compression_inpm%i_inps%i_em%i_pos',db,input_mode,input_struct,ear_mode),'epsc');
end