function m = compute_weight_model(m)

% Compute Weight Model

M = (m.weight_model.parameter.order+1)^2;
if m.model.parameter.ear_mode == 1
    pcws = ireshape_model(m.model.weights,m.model.parameter.structure,m.model.parameter.sz,m.model.parameter.ear_mode);
elseif m.model.parameter.ear_mode == 2
    sz_temp = m.model.parameter.sz; sz_temp(3) = 1;sz_temp(4) = size(m.model.weights,2);
    pcws = ireshape_model(m.model.weights,m.model.parameter.structure,sz_temp,m.model.parameter.ear_mode);
end

if (m.model.parameter.pcs > size(m.model.weights,2))
    m.model.parameter.pcs = size(m.model.weights,2);
end

m.weight_model.sh_weights = zeros(size(pcws,1),M,size(pcws,3),size(pcws,4));
%m.weight_model.sh_weights = zeros(size(pcws,1),M,size(pcws,3),m.model.parameter.pcs);
m.weight_model.weights = zeros(size(pcws));
%m.weight_model.weights = zeros(size(pcws,1),size(pcws,2),size(pcws,3),m.model.parameter.pcs);

co = zeros(size(pcws,1),size(pcws,2),size(pcws,3),3);
cr = zeros(size(pcws,1),size(pcws,2),size(pcws,3),3);
m.weight_model.sh_cond = cond(m.dataset.sha(:,1:M));

% Calculate Inverse / Regularization
m.weight_model.sh_cond = cond(m.dataset.sha(:,1:M));
if (m.weight_model.parameter.regularize == 1)
    [m.weight_model.sh_inv] = reg_matrix(m.dataset.sha(:,1:M));
else
    m.weight_model.sh_inv = pinv(m.dataset.sha(:,1:M));
end

    switch m.weight_model.parameter.type    
        case 'global'
            if m.model.parameter.structure == 2 || m.model.parameter.structure == 4
            % Calculate PCA Base Functions                            
                
                if m.model.parameter.structure == 2
                    for n = 1:size(pcws,1)
                    % Calculate weights for the spherical harmonics coefficients
                    % for all principal component weights for each participant                        
                        for e = 1:size(pcws,3)
                            m.weight_model.sh_weights(n,:,e,:) = m.weight_model.sh_inv*squeeze(pcws(n,:,e,:));
                            m.weight_model.weights(n,:,e,:) = m.dataset.sha(:,1:M)*squeeze(m.weight_model.sh_weights(n,:,e,:));
%                             for sp = 1:size(pcws,4)
%                             [co(n,:,e,sp,1),co(n,:,e,sp,2),co(n,:,e,sp,3)] = sph2cart(m.dataset.angles(:,1)/180*pi,m.dataset.angles(:,2)/180*pi,squeeze(pcws(n,:,e,sp))');
%                             [cr(n,:,e,sp,1),cr(n,:,e,sp,2),cr(n,:,e,sp,3)] = sph2cart(m.dataset.angles(:,1)/180*pi,m.dataset.angles(:,2)/180*pi,squeeze(m.weight_model.weights(n,:,e,sp))');
%                             end
                        end
                        
                    end
                    
                    %m.weight_model.error.shape_error = sqrt(sum((co-cr).^2,5))./sqrt(sum((co).^2,5));
                    %m.weight_model.error.shape_error = sqrt(sum((co-cr).^2,5));
                    
                    %m.weight_model.error.weight_error = abs(((abs(pcws) - abs(m.weight_model.weights)) ./ abs(pcws)));                                      
                    %m.weight_model.error.weight_error = squeeze(sqrt(mean(abs(20*log10(m.weight_model.weights./pcws)).^2,4))); % SD measure  
                    m.weight_model.error.weight_error = pcws - m.weight_model.weights; 
                    
                    m.weight_model.weights = reshape_model(m.weight_model.weights,m.model.parameter.structure,m.model.parameter.ear_mode);                     
                end
                
%                 if model.structure == 4
%                     pcws = ireshape_model(model.pcws,model.structure,model.sz,model.ear_mode);
%                     for n = 1:size(model.pcws,4)
%                     % Calculate weights for the spherical harmonics coefficients
%                     % for all principal component weights for each participant
%                         model.sh_weights(:,:,n) = m.dataset.sh_inv*squeeze(pcws(:,:,:,n));
%                         m.weight_model.pcws(n,:,:) = sha*squeeze(m.weight_model.sh_weights(n,:,:));
%                     end
%                 end            
            end
    end

end
                  
                 
