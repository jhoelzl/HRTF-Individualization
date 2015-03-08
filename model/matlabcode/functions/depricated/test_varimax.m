function test_varimax( db )
close all

pc_rec = 5;
pc_rotate = 10;

[hrirs,~,~,~,~,~,~,~,~,~,fs] = db_import(db);

if (strcmp('ircam',db) == 1)
disp('outlier removed')
hrirs = hrirs([1:27 29:50],:,:,:); 
end

freq_mode = 2;
subj = 1:size(hrirs,1);
idx = 1:size(hrirs,2);

[org_spc,pca_mean] = pca_in2(hrirs,2,3,freq_mode,subj,idx,0,0,size(hrirs,4),32,[],fs);
[pcs,pc_weights,latent] = princomp(org_spc,'econ'); % both ears

figure(1)
plot(pcs(:,1:pc_rec))
title('Original PCs')
legend(cellfun(@num2str, num2cell(1:pc_rec), 'UniformOutput', false)); 

[pcs2,T] =  rotatefactors(pcs(:,1:pc_rotate));

figure(2)
plot(pcs2(:,1:pc_rec))
title('Rotated PCs')
legend(cellfun(@num2str, num2cell(1:pc_rec), 'UniformOutput', false)); 

% Test Rec original
reconstruct1 = pc_weights(:,1:pc_rec) * pcs(:,1:pc_rec)';

% Test Rec totated
pc_weights2 = pc_weights(:,1:pc_rotate)*T;
reconstruct2 = pc_weights2(:,1:pc_rec) * pcs2(:,1:pc_rec)';

figure(3)
plot(reconstruct1(1,:),'b')
hold on
plot(reconstruct2(1,:),'r')
hold on
plot(org_spc(1,:),'g')

title('Reconstruction')
grid on
legend({'without rotation','with Rotation','Original'})
end
