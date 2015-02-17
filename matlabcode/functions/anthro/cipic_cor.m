function [DATA_COR] = cipic_cor(data,mode,az_val,el_val,pc_val1,pc_val2)

% Calc Cor from PC or Weights
% data = 1: pcs
% data = 2: pcs (incorrect record, only for testing)
% data = 3: weights

DATA_COR = zeros(25,50);

switch data
    
    case 1
    load('../matlabdata/cipic_cor/weights.mat','WEIGHTS');
    DATA = WEIGHTS;
    
    case 2
    load('../matlabdata/cipic_cor/weights.mat','WEIGHTS_LEFT');
    DATA = WEIGHTS_LEFT;
    
    case 3
    load('../matlabdata/cipic_cor/weights.mat','WEIGHTS_RIGHT');
    DATA = WEIGHTS_RIGHT;
    
    
    case 4
    load('../matlabdata/cipic_cor/pcs.mat','PCS');
    DATA = PCS;
    
    case 5
    load('../matlabdata/cipic_cor/pcs.mat','PCS_LEFT');
    DATA = PCS_LEFT;
    
    case 6
    load('../matlabdata/cipic_cor/pcs.mat','PCS_RIGHT');
    DATA = PCS_RIGHT;
end


plots = 10;

if (mode == 'pca')
% Perform PCA
[project,pc,mn,v] = pca3(DATA);

% Plot
figure
for n=1:plots   
subplot(plots,1,n), plot(project(:,n))
str_title = sprintf('PC %i',n);
title(str_title);
str=sprintf('%2.2f ' ,v(n)/sum(v)*100); 
legend(str)
end

end

if (mode == 'cor')

h = waitbar(0,'Calc Cor ...');

% or calculate cor


for az =1:25
    
    
    for el = 1:50

                
        if size(DATA,3) ~= 1024
            % Weights
            R = corrcoef(squeeze(DATA(az_val,el_val,:,pc_val1)),squeeze(DATA(az,el,:,pc_val2)));
        else
            % PCs
            R = corrcoef(squeeze(DATA(az_val,el_val,pc_val1,:)),squeeze(DATA(az,el,pc_val2,:)));
        end
%       R = sign(R)*sqrt(abs(R));

        DATA_COR(az,el) = sign(R(2,1))*sqrt(abs(R(2,1)));
        
    end

    waitbar(az / 25)    
end

close (h)

end



end



