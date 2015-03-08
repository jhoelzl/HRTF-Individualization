function pca_compression_local_diff(db,input_mode)

% Show PCA compression efficiency of each local PCA

% INPUT
% db
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
submode = length(conf.subjects);

X = squeeze(pcs_variance(submode,bpmode,length(conf.database.densities)+1:end,ears,input_mode,input_struct,ear_mode,smooth,:));

figure(3)
clf;
plot(X');
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
saveas(3,sprintf('../thesis/images/compression/local/%s_pca_compression_dbs_inpm%i_inps%i_em%i',db,input_mode,input_struct,ear_mode),'epsc');

% 2D Plot
% Load Angles from database  
az_unique = unique(conf.database.angles(:,1));
el_unique = unique(conf.database.angles(:,2));

for pos=1:size(X,1)
   var= find(X(pos,:)>90);
   var90(pos) = var(1);
end

max(var90)
min(var90)

for el=1:length(el_unique)
    for az=1:length(az_unique)
        
    Y(az,el) = 0; 

    answ = 0;
    offset = 0;
    while true 

        [Y,answ] = SearchNextPos(Y,var90,conf,az,el,az_unique,el_unique,offset);
        if (answ == 1)
        break
        end
        offset = offset +2.5;
    end  

end
end                            

figure(4)
clf;
surface(el_unique,az_unique,abs(Y),'EdgeColor', 'none');
ylabel('Azimuth')
xlabel('Elevation')
xlim([min(el_unique) max(el_unique)])
ylim([min(az_unique) max(az_unique)])    
colorbar
%caxis([13 32]);
%caxis([0 7]);
title('Number of PCs for 90 percent variance')
grid on


%Save
set(4,'paperunits','centimeters','paperposition',[1 2 15 10])
saveas(4,sprintf('../thesis/images/compression/local/%s_pca_compression_dbs_inpm%i_inps%i_em%i_2d',db,input_mode,input_struct,ear_mode),'epsc');


end


function [Y,answ] = SearchNextPos(Y,X,conf,az,el,az_unique,el_unique,offset)

pos_ind = find(conf.database.angles(:,2) == el_unique(el) & (conf.database.angles(:,1) >= az_unique(az)-offset)  &  (conf.database.angles(:,1) <= az_unique(az)+offset) );


if (isempty(pos_ind)) 
   Y(az,el) = 0;
   answ = 0;
else
   Y(az,el) = X(pos_ind(1));
   answ = 1;
end

end