function [res_left, res_right] = cipic_anthro_cor_max()

% Search for max correlation value in saved mat-files

% ouput
% RES   3D matrix containg max. correlation value, No. of PCW and No. of
% anthro_data (anthro dimensions in cipic_anthro_cor.m)
% RES2  2D matrix of RES (reshape source positions)
    
load('../matlabdata/cipic_cor_anthro/cor_weights_anthro.mat')
      
res_left = zeros(1250,3);
res_right = zeros(1250,3);

for pos=1:1250

    POS_COR_LEFT = squeeze(CIPIC_WEIGHT_ANTHRO_L(pos,:,:));
    POS_COR_RIGHT = squeeze(CIPIC_WEIGHT_ANTHRO_R(pos,:,:));

    %exclude gender correlation, Dimension =41
    POS_COR_LEFT(:,41) = 0;
    POS_COR_RIGHT(:,41) = 0;

    
    [val_max_l, ind_max_l] = max(abs(POS_COR_LEFT),[],2);
    [val_max_r, ind_max_r] = max(abs(POS_COR_RIGHT),[],2);

    [pos_val_max_l, pos_ind_max_l] = max(val_max_l); 
    [pos_val_max_r, pos_ind_max_r] = max(val_max_r); 

    res_left(pos,1) = pos_val_max_l;
    res_left(pos,2) = ind_max_l(pos_ind_max_l);
    res_left(pos,3) = pos_ind_max_l;
    
    res_right(pos,1) = pos_val_max_r;
    res_right(pos,2) = ind_max_r(pos_ind_max_r);
    res_right(pos,3) = pos_ind_max_r; 
end

% max. value global
%[max1 ind1] = max(COR_MAX(1,:));

end

