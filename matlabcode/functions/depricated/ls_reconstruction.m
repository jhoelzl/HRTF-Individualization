function ls_reconstruction()

% Test several effects on PCWs or Reconstruction
% Hint: IEM database: PCA has to be calculated without 'econ'!!
close all

% CONFIG
dbs = {'cipic','ircam','ari','universal'};
%dbs = {'universal'};
max_people = [45,50,66,116]; 

pc_numbers = [1 5 10 20 50 128];
dens = [1 3 5 8 10 20 30]; % Density 0 this controls the angle density of the grid, there could be a better implementation for this
ears = 'both'; 
modes = {'lin'};

% Perform test conditions
for db = 1:length(dbs)            
    for mod = 1:length(modes)
        [dtf,angles] = preprocess_db(dbs{db},modes{mod});    
        su_train(db,:) = round(linspace(5,max_people(db)-4,10));
        su_test(db,:)  = [1:4 (max_people(db)-3):max_people(db)];
        [e_l{db},e_r{db}] = start_testing(dtf,angles,su_train(db,:),su_test(db,:),dens,pc_numbers,ears,modes{mod});
    end
end

% Plotting Options
% plot_density(e_l,e_r,pc_numbers,dens,dbs);
% plot_pcs(e_l,e_r,pc_numbers,su_train,dens,dbs);
%plot_var(lat,su_train);

end

% Plot Error of different PC numbers
function plot_pcs(e_l,e_r,pc_numbers,su_train,dens,dbs)


for db = 1:length(dbs)
    for d = 1:length(dens)
        for N=1:length(pc_numbers)

            % Plot
            figure(1);clf;
            plot(su_train(db,:),squeeze(mean(e_l{db}(N,d,:,1:4),4)),'b','LineWidth',2);
            hold on
            plot(su_train(db,:),squeeze(mean(e_l{db}(N,d,:,5:8),4)),'r','LineWidth',2);
            legend({'Train','Test'});
            grid on
            xlabel('# People in the Training Set')
            ylabel('error [db]')
            title(sprintf('Reconstruction Error, %i PCs',pc_numbers(N)));
            %Save
            set(1,'paperunits','centimeters','paperposition',[1 1 12 7])
            saveas(1,sprintf('../report/images/least_squares/%s_error_pcw%i_dens%i_versuch2',dbs{db},pc_numbers(N),dens(d)),'epsc');

        end
    end
end
end

% Plot Variance
function plot_var(lat,su_train)

figure(6);
plot(su_train(d,:),squeeze(cumsum(lat(d,:,1:5),3))./repmat(squeeze(sum(lat(d,:,:),3))',1,5));
plot((sum(squeeze(cumsum(lat(d,:,:),3)),3)./repmat(squeeze(sum(lat(d,:,:),3))',1,128))');
var = (sum(squeeze(cumsum(lat(d,:,:),3)),3)./repmat(squeeze(sum(lat(d,:,:),3))',1,128));


var1 =  mean(var(:,pc))* 100;
grid on;
xlabel('People in the Set');
ylabel('Explained Variance');
title(sprintf('Explained Variance, %i PCs, Density: %i, Mode: %s',pc,dens(d),modes{mod}));

            
end

%Error Plotting Density
function plot_density(e_l,e_r,pc_numbers,dens,dbs)

for db = 1:length(dbs)   
    for N=1:length(pc_numbers)
        figure(5)
        clf;

        %Plot
        plot(dens,mean(mean(mean(e_l{db}(N,:,:,1:4,:),5),4),3),'b','LineWidth',2);
        hold on
        plot(dens,mean(mean(mean(e_l{db}(N,:,:,5:8,:),5),4),3),'r','LineWidth',2);
        legend('Train','Test');
        xlabel('density')
        ylabel('error [dB]')
        grid on
        title(sprintf('Mean Reconstruction Error, %i PCs',pc_numbers(N)))

        %Save
        set(5,'paperunits','centimeters','paperposition',[1 1 12 8])
        saveas(5,sprintf('../report/images/least_squares/%s_error_pcw%i_mean_density',dbs{db},pc_numbers(N)),'epsc');        
    end
end

end



function [e_l,e_r] = start_testing(dtf,angles,su_train,su_test,dens,pc_numbers,ears,mode)

count = length(dens)*length(su_train);
c =0;
h = waitbar(0,'Calculating...');

for d = 1:length(dens) % Density
    % Training         
    [angles_ind] = prepare_angles(angles,dens(d));
    for s = 1:length(su_train)        
        % Principal Components
        
        % Create Principal Component Basis for different subject numbers
        [pcs,~,~] = calc_pcs(dtf(1:su_train(s),angles_ind,:,:),ears);      
           
        % Make Test Predictions for the Base we are examining                                
        for i = 1:length(su_test)   
                
            % Calc for different PC numbers
            for N = 1:length(pc_numbers)
                % Principal Component Weights in the Least Square Sense
                wg_l = (inv(pcs'*pcs)*pcs') * squeeze(dtf(su_test(i),:,1,:))';
                wg_r = (inv(pcs'*pcs)*pcs') * squeeze(dtf(su_test(i),:,2,:))';
                % Reconstructed HRTFs based on Estimated PCWs
                rcnstr_l = (pcs(:,1:pc_numbers(N)) * wg_l(1:pc_numbers(N),:))';
                rcnstr_r = (pcs(:,1:pc_numbers(N)) * wg_r(1:pc_numbers(N),:))';
                % Original HRTFs
                or_l = squeeze(dtf(su_test(i),:,1,:));
                or_r = squeeze(dtf(su_test(i),:,2,:));            

                % MSError for Left and Right Ear
                if strcmp(mode,'log')
                    e_l(N,d,s,i,:) = sqrt(mean( (rcnstr_l - or_l).^2,1));
                    e_r(N,d,s,i,:) = sqrt(mean( (rcnstr_r - or_r).^2,1));
                elseif strcmp(mode,'lin')
                    e_l(N,d,s,i,:) = sqrt(mean( 20*log10( abs(rcnstr_l ./ or_l ) ).^2,1));
                    e_r(N,d,s,i,:) = sqrt(mean( 20*log10( abs(rcnstr_r ./ or_r ) ).^2,1));
                end
               
            end
            
             
        end
        
        c = c+1;
        waitbar(c / count)
        
    end
    
    
end

close(h)
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


