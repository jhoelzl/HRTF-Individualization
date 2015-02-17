function var_shws_pcs(db)

% Diagramm: Variance of PCs of SHWs vs SH Order

close all;

% Setup
pcs = 1:5;
sh_orders = [1:9,10:2:20];
pcshs = 1:10;

% PCA Input Matrix
[hrirs,~,~,angles,~,~,~,~,~,~,fs] = db_import(db);
freq_mode = 2;
smooth_val = 0;
sub_id_excl = 0;
[pca_in,pca_mean] = pca_in2(hrirs,2,3,freq_mode,1:size(hrirs,1),1:size(hrirs,2),0,0,size(hrirs,4),smooth_val,sub_id_excl,fs);

% PCA
[~,pc_weights,latent] = princomp(pca_in,'econ'); % both ears

% Weights for Left and Right Ear
pc_weights = reshape(pc_weights,[size(hrirs,1),size(hrirs,2),size(hrirs,4)]);

% Spherical Harmonics from PCWs
data = zeros(1,1,1);

for sh_order = 1:length(sh_orders)

    [sh_weights,sha] = pca2sh(pc_weights,angles,max(pcs),sh_orders(sh_order));
        
    for pc =1:length(pcs)    
        
        % PCA
        pca_in = squeeze(sh_weights(:,:,pc));

        % Substract Mean
        mean_sub = mean(pca_in,2);
        mean_sub = repmat(mean_sub,1,size(pca_in,2));
        pca_in = pca_in - mean_sub;

        [~,~,cur_sh_latent] = princomp(pca_in,'econ');
        var = cur_sh_latent/sum(cur_sh_latent)*100;

        total_var = 0;
        
        for pcsh = 1:length(pcshs)
            
            if (pcsh > length(var))
            total_var = total_var + 0; 
            else
            total_var = total_var + var(pcsh);
            end
            data(pc,sh_order,pcsh) = total_var;
        end
    end
end

for pc = 1:size(data,1)
    figure(pc)
    clf;
    plot(squeeze(data(pc,:,:))')
    grid on
    xlabel('PC Numbers of SHWs')
    ylabel('Variance of PCs of SHWs')
    title(sprintf('PC%i',pcs(pc)))
    legend(cellfun(@num2str, num2cell(sh_orders), 'UniformOutput', false));    
    ylim([min(min(squeeze(data(pc,:,:)))) 100])
    
    %Save
    set(pc,'paperunits','centimeters','paperposition',[1 1 15 10])
    saveas(pc,sprintf('../thesis/images/compression/sh_order/%s_pc%i_var_v1',db,pcs(pc)),'epsc');
    
end


for pc = 1:size(data,1)
    figure(pc+10)
    clf;
    plot(squeeze(data(pc,:,:)))
    grid on
    xlabel('SH Order')
    ylabel('Variance of PCs of SHWs')
    title(sprintf('PC%i',pcs(pc)))
    legend(cellfun(@num2str, num2cell(pcshs), 'UniformOutput', false));  
    ylim([min(min(squeeze(data(pc,:,:)))) 100])
    %Save
    set(pc+10,'paperunits','centimeters','paperposition',[1 1 15 10])
    saveas(pc+10,sprintf('../thesis/images/compression/sh_order/%s_pc%i_var_v2',db,pcs(pc)),'epsc');
       
end


end