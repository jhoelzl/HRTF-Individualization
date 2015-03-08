function pca_compression_subs(db,input_mode,input_struct)

% PCA compression effiency for different number of subjects

% config:
ears = 3;
ear_mode = 2;
posmode =1;
bpmode = 1;
smooth = 1;

% Load Error File
error_data = sprintf('../matlabdata/test_pca/variance_pca_%s_sub.mat',db);
load(error_data,'pcs_variance','conf');

% Show conf
conf
X(:,:) = squeeze(pcs_variance(:,bpmode,posmode,ears,input_mode,input_struct,ear_mode,smooth,:));

figure(3)
clf;
plot(squeeze(X'));

legend(cellstr(num2str(conf.subjects', '%-d')),'Location','SouthEast')
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
saveas(3,sprintf('../thesis/images/compression/subjects/%s_pca_compression_inpm%i_inps%i_em%i',db,input_mode,input_struct,ear_mode),'epsc');
end