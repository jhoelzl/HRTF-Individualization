function cipic_anthro_cor()

% first calc PCA including all positions and subjects
% then calc correlation between cipic subjects weights (left/right seperate) and anthro
% data (67 dimensions)

% Import HRIR DATA
fft_points = 256;
hrirs = db_import('cipic');

data_dtf = (abs(fft(hrirs,fft_points,4)));
data_dtf = data_dtf(:,:,:,1:fft_points/2);
            
% Substract Mean
m_s = mean(data_dtf,2); % Mean Across Angles
data_dtf = data_dtf - repmat(m_s,[1 size(hrirs,2) 1 1]);
             
% Reshape
pca_in_l = reshape(squeeze(data_dtf(:,:,1,:)),[],fft_points/2);
pca_in_r = reshape(squeeze(data_dtf(:,:,2,:)),[],fft_points/2);
    
% PCA
[~, w_l] = princomp(pca_in_l,'econ'); % left ears
[~, w_r] = princomp(pca_in_r,'econ'); % right ears

% Weights for Left and Right Ear
w_l = reshape(w_l,size(squeeze(data_dtf(:,:,1,:))));
w_r = reshape(w_r,size(squeeze(data_dtf(:,:,2,:))));
       
CIPIC_WEIGHT_ANTHRO_L = zeros(size(hrirs,2),10,67);
CIPIC_WEIGHT_ANTHRO_R = zeros(size(hrirs,2),10,67);


    % Anthro Dimensions
anthro_data = zeros(size(hrirs,1),67);
        
for i=1:size(hrirs,1)
    anthro_data(i,1) = anthro_cipic(i,'head width','cipic');
    anthro_data(i,2) = anthro_cipic(i,'head height','cipic');
    anthro_data(i,3) = anthro_cipic(i,'head depth','cipic');
    anthro_data(i,4) = anthro_cipic(i,'pinna offset down','cipic');
    anthro_data(i,5) = anthro_cipic(i,'pinna offset back','cipic');
    anthro_data(i,6) = anthro_cipic(i,'neck width','cipic');
    anthro_data(i,7) = anthro_cipic(i,'neck height','cipic');
    anthro_data(i,8) = anthro_cipic(i,'neck depth','cipic');
    anthro_data(i,9) = anthro_cipic(i,'torso top width','cipic');
    anthro_data(i,10) = anthro_cipic(i,'torso top height','cipic');
    anthro_data(i,11) = anthro_cipic(i,'torso top depth','cipic');
    anthro_data(i,12) = anthro_cipic(i,'shoulder width','cipic');
    anthro_data(i,13) = anthro_cipic(i,'head offset forward','cipic');
    anthro_data(i,14) = anthro_cipic(i,'height','cipic');
    anthro_data(i,15) = anthro_cipic(i,'seated height','cipic');
    anthro_data(i,16) = anthro_cipic(i,'head circumference','cipic');
    anthro_data(i,17) = anthro_cipic(i,'shoulder circumference','cipic');
    anthro_data(i,18) = anthro_cipic(i,'cavum concha height left','cipic');
    anthro_data(i,19) = anthro_cipic(i,'cavum concha height right','cipic');
    anthro_data(i,20) = anthro_cipic(i,'cymba concha height left','cipic');
    anthro_data(i,21) = anthro_cipic(i,'cymba concha height right','cipic');
    anthro_data(i,22) = anthro_cipic(i,'cavum concha width left','cipic');
    anthro_data(i,23) = anthro_cipic(i,'cavum concha width right','cipic');
    anthro_data(i,24) = anthro_cipic(i,'fossa height left','cipic');
    anthro_data(i,25) = anthro_cipic(i,'fossa height right','cipic');
    anthro_data(i,26) = anthro_cipic(i,'pinna height left','cipic');
    anthro_data(i,27) = anthro_cipic(i,'pinna height right','cipic');
    anthro_data(i,28) = anthro_cipic(i,'pinna width left','cipic');
    anthro_data(i,29) = anthro_cipic(i,'pinna width right','cipic');
    anthro_data(i,30) = anthro_cipic(i,'intertragal incisure width left','cipic');
    anthro_data(i,31) = anthro_cipic(i,'intertragal incisure width right','cipic');
    anthro_data(i,32) = anthro_cipic(i,'cavum concha depth left','cipic');
    anthro_data(i,33) = anthro_cipic(i,'cavum concha depth right','cipic');
    anthro_data(i,34) = anthro_cipic(i,'pinna rotation angle left','cipic');
    anthro_data(i,35) = anthro_cipic(i,'pinna rotation angle right','cipic');
    anthro_data(i,36) = anthro_cipic(i,'pinna flare angle left','cipic');
    anthro_data(i,37) = anthro_cipic(i,'pinna flare angle right','cipic');
    anthro_data(i,38) = anthro_cipic(i,'pinna-cavity height left','cipic');
    anthro_data(i,39) = anthro_cipic(i,'pinna-cavity height right','cipic');
    anthro_data(i,40) = anthro_cipic(i,'age','cipic');
    anthro_data(i,41) = anthro_cipic(i,'gender_number','cipic');
    anthro_data(i,42) = anthro_cipic(i,'weight','cipic');

    % ITD
    %plotdata_l = squeeze(hrirs(i,pos,1,:));
    %plotdata_r = squeeze(hrirs(i,pos,2,:));
    %anthro_data(i,43) = calculate_itd(plotdata_l,plotdata_r);

    % Linear Regression (from Paper ICAD05)
    % New extra paramteters from existing dimensions

    % d11 left ear (d1+d2)
    anthro_data(i,44)= anthro_data(18) + anthro_data(20);

    % d11 right ear (d1+d2)
    anthro_data(i,45) = anthro_data(19) + anthro_data(21);

    % d12 left ear (d1 + d2 + d4)
    anthro_data(i,46) = anthro_data(18) + anthro_data(20) + anthro_data(24);

    % d12  right ear (d1 + d2 + d4)
    anthro_data(i,47) = anthro_data(19) + anthro_data(21) + anthro_data(25);

    % d13 left ear (d1 + d2)*d3
    anthro_data(i,48) = (anthro_data(18) + anthro_data(20)) * anthro_data(22);

    % d13 right ear (d1 + d2)*d3
    anthro_data(i,49) = (anthro_data(19) + anthro_data(21)) * anthro_data(23);

    % d14 left ear (d1+d2)*d3*d8
    anthro_data(i,50) = (anthro_data(18) + anthro_data(20)) * anthro_data(22) * anthro_data(32);

    % d14 right ear (d1+d2)*d3*d8
    anthro_data(i,51) = (anthro_data(19) + anthro_data(21)) * anthro_data(23) * anthro_data(33);

    % d15 left ear (d1+d2)*d3*d10
    anthro_data(i,52) = (anthro_data(18) + anthro_data(20)) * anthro_data(22) * anthro_data(36);

    % d15 right ear (d1+d2)*d3*d10
    anthro_data(i,53) = (anthro_data(19) + anthro_data(21)) * anthro_data(23) * anthro_data(37);

    % d16 left ear (d1+d2)*d7*d8
    anthro_data(i,54) = (anthro_data(18) + anthro_data(20)) * anthro_data(30) * anthro_data(32);

    % d16 right ear (d1+d2)*d7*d8
    anthro_data(i,55) = (anthro_data(19) + anthro_data(21)) * anthro_data(31) * anthro_data(33);

    % d17 left ear (d1+d2)*d7*d10
    anthro_data(i,56) = (anthro_data(18) + anthro_data(20)) * anthro_data(30) * anthro_data(36);

    % d17 right ear (d1+d2)*d7*d10
    anthro_data(i,57) = (anthro_data(19) + anthro_data(21)) * anthro_data(31) * anthro_data(37);

    % d18 left ear (d1*d3)
    anthro_data(i,58)= anthro_data(18) + anthro_data(22);

    % d18 right ear (d1*d3)
    anthro_data(i,59)= anthro_data(19) + anthro_data(23);

    % d19 left ear (d5*d6)
    anthro_data(i,60)= anthro_data(26) + anthro_data(28);

    % d19 right ear (d5*d6)
    anthro_data(i,61)= anthro_data(27) + anthro_data(29);

    % d20 left ear (d5*d6*d8)
    anthro_data(i,62)= anthro_data(26) + anthro_data(28) * anthro_data(32);

    % d20 right ear (d5*d6*d8)
    anthro_data(i,63)= anthro_data(27) + anthro_data(29) * anthro_data(33);

    % d21 left ear (d5*d6*d10)
    anthro_data(i,64)= anthro_data(26) + anthro_data(28) * anthro_data(36);

    % d21 right ear (d5*d6*d10)
    anthro_data(i,65)= anthro_data(27) + anthro_data(29) * anthro_data(37);

    % d22 left ear (d4*d6)
    anthro_data(i,66)= anthro_data(24) + anthro_data(28);

    % d22 right ear (d4*d6)
    anthro_data(i,67)= anthro_data(25) + anthro_data(29);

end


% Calculate Correlations between first 10 weights and 67 anthro dimensions
il = waitbar(0,'Perform Correlation on Position');
for pos=1:size(w_l,2)   

    % Add ITD as Anthro Dimension
    plotdata_l = squeeze(hrirs(i,pos,1,:));
    plotdata_r = squeeze(hrirs(i,pos,2,:));
    anthro_data(i,43) = calculate_itd(plotdata_l,plotdata_r);
    
    for i=1:10
        for j=1:length(anthro_data)

        % LEFT EAR    
        R = corrcoef(squeeze(w_l(:,pos,i)),anthro_data(:,j));
        CIPIC_WEIGHT_ANTHRO_L(pos,i,j) = sign(R(2,1))*sqrt(abs(R(2,1)));

        % RIGHT EAR
        R = corrcoef(squeeze(w_r(:,pos,i)),anthro_data(:,j));
        CIPIC_WEIGHT_ANTHRO_R(pos,i,j) = sign(R(2,1))*sqrt(abs(R(2,1)));

        end    
    end
   waitbar(pos / size(w_l,2),il)
end
     
save('../matlabdata/cipic_cor_anthro/cor_weights_anthro.mat','CIPIC_WEIGHT_ANTHRO_L','CIPIC_WEIGHT_ANTHRO_R');

close(il)


