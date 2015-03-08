function pca_compression_local(input_mode)

% Show compression effiency for PCA of single positions vs. PCA of entire
% dataset

% INPUT
% input_mode: 1-4

dbs = {'ari','cipic','ircam'};
%X = zeros(length(dbs),6,200);

% config:
ears = 3;
input_struct = 2;
ear_mode = 2;
smooth = 1;
bpmode = 1;

for db=1:length(dbs)

    % Load Error File
    error_data = sprintf('../matlabdata/test_pca/variance_pca_%s_local.mat',dbs{db});
    load(error_data,'pcs_variance','conf');
    
    % Show conf
    conf
    densities = [1 2];
    submode = length(conf.subjects);
    
    for posmode=1:length(densities)
        conf.densities_real(densities(posmode))
        X(db,posmode,:) = squeeze(pcs_variance(submode,bpmode,densities(posmode),ears,input_mode,input_struct,ear_mode,smooth,:));
    end
    

  %  X(db,:,:) = squeeze(pcs_variance(submode,bpmode,length(conf.database.densities)+1:end,ears,input_mode,input_struct,ear_mode,smooth,:));
  
end

figure(3)
clf;

mark= {'-','--','-.'};
col = {'b','r'};
figure(3)

for db=1:size(X,1)
    for posmode=1:size(X,2)
    
    plot(squeeze(X(db,posmode,:)),strcat(col{posmode},mark{db}));
    hold on

    end
    
    if(db == 1)
    legend('entire database','single position','Location','SouthEast')
    end
    
%     plot(squeeze(X(db,:,:))');
%     hold on
end

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
saveas(3,sprintf('../thesis/images/compression/positions/pca_compression_dbs_inpm%i_inps%i_em%i',input_mode,input_struct,ear_mode),'epsc');

end

