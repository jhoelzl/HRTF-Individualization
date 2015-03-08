function explore_weights(db,sub)


% Import HRIR DATA
fft_points = 256;
[hrirs,~,~,angles] = db_import(db);

% % Adjust angles
% for i=1:size(angles,1)
% [angles(i,1),angles(i,2)]=hor2geo(angles(i,1),angles(i,2));
% end
    
hrirs = minp_db(hrirs); % calc min phase hrirs
data_dtf = (abs(fft(hrirs,fft_points,4)));

if (nargin < 2)  
sub = size(hrirs,1);
end 

data_dtf = data_dtf(1:sub,:,:,1:fft_points/2);
            
% Substract Mean
m_s = mean(data_dtf,2); % Mean Across Angles
data_dtf = data_dtf - repmat(m_s,[1 size(hrirs,2) 1 1]);
             
az = unique(angles(:,1));
el = unique(angles(:,2)); 

% Reshape
pca_in_l = reshape(squeeze(data_dtf(:,:,1,:)),[],fft_points/2);
pca_in_r = reshape(squeeze(data_dtf(:,:,2,:)),[],fft_points/2);


    
    % reshape matrix
    % pca_in has index all angles for each subject for left ear and then all angles for each subject for right ear
    % Subj 1 Angles 1 L/
    % Subj 2 Angles 1 L/ 
    % ................
    % Subj N Angles 1 L/
    % Subj 1 Angles 2 L/ 
    % Subj 2 Angles 2 L/
    % ..................
    % Subj N Angles 2 L/
    % ..................
    % ..................
    % Subj N Angles N L/
    % Subj 1 Angles 1 R/
    % ..................
    % ..................
    % ..................
    % Subj N Angles N R/
    
% PCA
[c_l, w_l, l_l, tsq_l] = princomp(pca_in_l,'econ'); % left ears
[c_r, w_r, l_r, tsq_r] = princomp(pca_in_r,'econ'); % right ears

% Weights for Left and Right Ear
w_l = reshape(w_l,size(squeeze(data_dtf(:,:,1,:))));
w_r = reshape(w_r,size(squeeze(data_dtf(:,:,2,:))));
    

% Score Plots 
figure(6)
%plot_scores(angles,3,1,w_l,w_r);

spherical_plot(angles,1,1,w_l);
 
% save figure as eps
% set(6,'paperunits','centimeters','paperposition',[1 1 12 8])
% saveas(6,sprintf('../report/images/pcws/%s_pcw1_across_all',db),'epsc');



% Fit PCA to the weights
% for n = 1:10 % PC Number
%     % Fit a PCA Model to the PCA Weights
%     [ac_l(n,:,:), aw_l(n,:,:), al_l(n,:), atsq_l(n,:)] = princomp(squeeze(w_l(:,:,n)),'econ');
%     [ac_r(n,:,:), aw_r(n,:,:), al_r(n,:), atsq_r(n,:)] = princomp(squeeze(w_r(:,:,n)),'econ');
% 
% end


%addpath ./at3/sh_functions;
%addpath /Volumes/Projects/common_functions/SHtools/;

% Spherical Harmonics Representationp of the PCA weights
% Define better the Sampling points! Normally you would want nicely spaced points on the sphere 
% We have this gap below, but since we do not want to reconstruct over
% there this might not be so much of the problem. In any case tests should
% be made with different sampling of the sphere to look for minimal error

M = 1; % The Spherical Harmonics Order, what is the optimal number, a compromise needs to be made 
%as the number of the controls for the user increases quickly with Order
for a = 1:size(angles,1)
    % sha is N x angles matrix containing the spherical expansion order M
    % for the angles included in the angle matrix
    sha(:,a) = SHCreateYVec(M,angles(a,1),90-angles(a,2),'deg'); % Convert Elevation to Zenith (Inclination or Colatitude)
    shb(:,a) = sh_matrix_real(M,angles(a,1),90-angles(a,2)); % Convert Elevation to Zenith (Inclination or Collatidude)    
end



N = 5; % Analyze the first N Principal Components, How is the error changing for each principal component are some better represented than the others?

for n = 1:size(w_l,1) % For each participant
    % Analysis into Spherical Harmonics of the first N principal components
    % weights = spherical harmoncis weight
    sw_l(n,:,1:N) = inv(sha*sha')*sha*squeeze(w_l(n,:,1:N)); 
    sw_r(n,:,1:N) = inv(sha*sha')*sha*squeeze(w_r(n,:,1:N)); 
    % Reconstruction of the principal components weights based on the spherical
    % harmonics weights
    w_rc_l(n,:,1:N) = sha'*squeeze(sw_l(n,:,1:N));
    w_rc_r(n,:,1:N) = sha'*squeeze(sw_r(n,:,1:N));
    % Correlation Coefficent between left and right ear
    for c = 1:N
        cc_lr(n,c) = diag(corrcoef(w_rc_l(n,:,c),w_rc_r(n,:,c)),1);
    end
    % Reconstruction Error for PCA Weights based on originals and the ones
    % reconstructed based on the spherical harmonics model simplification
    e(n,:,1:N) = sqrt(w_l(n,:,1:N) - w_rc_l(n,:,1:N)).^2;
    e_r(n,:,1:N) = sqrt(w_r(n,:,1:N) - w_rc_r(n,:,1:N)).^2;
    % Reconstruction error in the HRTF space; How is the PCA weight error
    % reconstuction error affecting the HRTF reconstruction
end

size(w_l)
size(sw_l)
size(w_rc_l)

% Percent of people with weights for all combonents correlated above x %
% length(find(abs(cc_lr)>0.7))/prod(size(cc_lr))

% sha is N x angles matrix containing the spherical expansion order N
% for the angles included in the angle matrix
% weights = spherical harmonics weight, N is the number of PCs to use
% This should be done only for the area of the sphere where data points
% exist

%rmpath /Volumes/Projects/common_functions/SHtools/;
%rmpath ./at3/sh_functions;

end

function e = fit_poly(angles,w)
    % Fit a polynomial for the weights for each elevation trajectory, 
    % this is just a simple example,
    % we need to extend this to make for a two dimensional function 
    
    for s = 1:size(data_dtf,1)
        for a = 1:length(el)
            o = 3; % Third Order seems to work well % Need a plot for all orders to justify
            idx = find(angles(:,2) == el(a));
            az = angles(find(angles(:,2) == el(a)),1);
            p = polyfit(az',squeeze(w_l(s,idx,n)),o);
            f = polyval(p,az);
            e(n,s,a,o) = sqrt(sum((w_l(s,idx,n) - f').^2));                            
        end
    end
end

function spherical_plot(angles,subj,pc,w)
    % This works in principle but we need to show less angles and resample the grid so
    % that the plot becomes more beautiful. It is not very nice right  now
    [Thetas,Phis] = meshgrid(angles(:,1),angles(:,2));
    % ZI = griddata(angles(:,1),angles(:,2),w_l(1,:,1),Thetas,Phis);
    
%     size(squeeze(w(subj,:,pc)'))
%     size(angles(:,1))
%     size(angles(:,2))
    
    F = TriScatteredInterp(angles(:,1),angles(:,2),squeeze(w(subj,:,pc)'));
    ZI = F(Thetas,Phis);
    [ccx,ccy,ccz] = sph2cart(Thetas/180*pi,Phis/180*pi,ones(size(Thetas)));
    figure,surf(ccx,ccy,ccz,ZI);view(120,22);
end

function plot_scores(angles,subj,pc,w_l,w_r)
    figure;
    hold on;        
    if nargin == 5
        plot3(angles(:,1),angles(:,2),w_r(subj,:,pc),'r.');
        plot3(angles(:,1),angles(:,2),w_l(subj,:,pc),'b.');
    elseif nargin == 4
        plot3(angles(:,1),angles(:,2),w_l(subj,:,pc),'b.');
    end
    grid on;
    xlabel('Azimuth')
    ylabel('Elevation')
    title(sprintf('PCW:%d',pc));
end