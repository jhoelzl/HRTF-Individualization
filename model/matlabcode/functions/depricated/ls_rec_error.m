function [e_l,e_r] = ls_rec_error(dtf,angles,su_train,su_test,dens,pc_numbers,ears,mode)
% dtf: 
% angles: Indexes of angles so that different densities can be accomodated
% su_train: training set for te calculation of PCs
% su_test : test set for the reconstruction of HRTFs
% dens: density of the angles
% pc_numbers: numbers of PCs used in the reconstruction
% ears: both, left oder right for the creation of the associated PCA input matrix
% mode: log oder lin


%count = length(dens)*length(su_train);
%c =0;
%h = waitbar(0,'Calculating...');

for d = 1:length(dens) % Density
    % Training         
    angles_ind = prepare_angles(angles,dens(d));
%     for s = 1:length(su_train)        
        % Principal Components
        % Create Principal Component Basis for different subject numbers
        [pcs,~,~] = calc_pcs(dtf(su_train,angles_ind,:,:),ears);      
           
        % Make Test Predictions for the Base we are examining                                

                
        % Calc for different PC numbers
        for N = 1:length(pc_numbers)
            
            % For each subject in the test set
            for s = 1:length(su_test)
                % Principal Component Weights in the Least Square Sense
                wg_l = (inv(pcs'*pcs)*pcs') * squeeze(dtf(su_test(s),:,1,:))';
                wg_r = (inv(pcs'*pcs)*pcs') * squeeze(dtf(su_test(s),:,2,:))';
                % Reconstructed HRTFs based on Estimated PCWs
                rcnstr_l = (pcs(:,1:pc_numbers(N)) * wg_l(1:pc_numbers(N),:))';
                rcnstr_r = (pcs(:,1:pc_numbers(N)) * wg_r(1:pc_numbers(N),:))';
                % Original HRTFs
                or_l = squeeze(dtf(su_test(s),:,1,:));
                or_r = squeeze(dtf(su_test(s),:,2,:));            

                % MSError for Left and Right Ear
                if strcmp(mode,'log')
                    e_l(N,d,s,:) = sqrt(mean( (rcnstr_l - or_l).^2,2));
                    e_r(N,d,s,:) = sqrt(mean( (rcnstr_r - or_r).^2,2));
                elseif strcmp(mode,'lin')
                    e_l(N,d,s,:) = sqrt(mean( 20*log10( abs(rcnstr_l ./ or_l ) ).^2,2));
                    e_r(N,d,s,:) = sqrt(mean( 20*log10( abs(rcnstr_r ./ or_r ) ).^2,2));
                end
            end   

        end
        e_l = mean(e_l,3);
        e_r = mean(e_l,3);        
        %c = c+1;
        %waitbar(c / count)
              
end

%close(h)

end

function [angles_ind] = prepare_angles(angles,density)

%angles_ind = [1:density:size(angles,1);1:density:size(angles,1)]'; 
angles_ind = 1:density:size(angles,1);
    
end

function [pcs,pcws,latent] = calc_pcs(dtf,ear)


% DTF: Substract Mean
m_s = mean(dtf,2); % Mean Across Angles
dtf = dtf - repmat(m_s,[1 size(dtf,2) 1 1]);


% Only use a selection of subjects and angles
% angles_values = angles(angles_ind);
% data_dtf_pca = data_dtf(1:sub,angles_ind,:,:);

% Reshape PCA Input Matrix
if (strcmp(ear,'left')) 
    dtf = reshape(squeeze(dtf(:,:,1,:)),[],size(dtf,4)); 
elseif (strcmp(ear,'right')) 
    dtf = reshape(squeeze(dtf(:,:,2,:)),[],size(dtf,4));    
elseif (strcmp(ear,'both')) 
    dtf = reshape(dtf(:,:,:,:),[],size(dtf,4));    
end

% PCA Decomposition
[pcs, pcws,latent] = princomp(dtf);

end

function [dtf,angles] = preprocess_db(db,mode)

fft_points = 256;
% Import HRIR DATA
[hrirs,~,~,angles] = db_import(db);
[angles,I] = sortrows(angles,[1 2]);
hrirs = hrirs(:,I,:,:);

dtf = abs(fft(hrirs(:,:,:,:),fft_points,4));
dtf = dtf(:,:,:,1:fft_points/2);

% Log or Linear Spectrum
if (strcmp(mode,'log') == 1) 
    dtf = 20*log10(dtf);
end

end

