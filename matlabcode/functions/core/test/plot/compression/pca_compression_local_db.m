function pca_compression_local_db(db,input_mode)

% Show compression effiency for PCA of single positions vs. PCA of entire
% dataset

% INPUT
% input_mode: 1-4

% Load Error File
error_data = sprintf('../matlabdata/test_pca/variance_pca_%s_local.mat',db);
load(error_data,'pcs_variance','conf');

% Show conf
conf

% config:
ears = 3;
input_struct = 2;
ear_mode = 2;
smooth = 1;
bpmode = 1;
submode = 1;


X = squeeze(pcs_variance(submode,bpmode,:,ears,input_mode,input_struct,ear_mode,smooth,:));


figure(3)
clf;

for posmode=1:size(X,1)

    if(posmode == 1)    
    plot(X(posmode,:),'r');
    else
    plot(X(posmode,:),'b'); 
        if(posmode == 2)
        legend('entire database','single position','Location','SouthEast')    
        end
    end
    
    hold on

end

plot(X(1,:),'r','LineWidth',2);

xlim([0 50])
ylim([60 100])
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
saveas(3,sprintf('../thesis/images/compression/positions/%s_pca_compression_dbs_inpm%i_inps%i_em%i',db,input_mode,input_struct,ear_mode),'epsc');

end

