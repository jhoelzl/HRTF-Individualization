function test_ica(db)


[hrirs,subject_ids,a,angles,b,hrir_db_length,c,d,e,f,fs,exp_sub] = db_import(db);

pc_order = size(hrirs,4);sh_order = 4;


freq_mode = 2;%1=lin,2 = log;

% May be it makes sense to use directly the Minimum Phase HRIRs here
% instead of the normal HRIRs, I have not tried it
eaz = unique(angles(:,1));
idx = find(angles(:,1) == eaz(6));
subj = 1:size(hrirs,1);
idx = 1:size(hrirs,2);
[org_spc,pca_mean] = pca_in(hrirs,1,2,freq_mode,1,[],32,fs);
[ics,A,W] = fastica(org_spc, 'numOfIC', 5) %'verbose','off','interactivePCA','off');

% Reconstruction
reconstruct = A * ics;

end


% Get Min Phase HRIRS and ITDs, it might be a good idea after min phase
% calculation to envelope the Hrirs to avoid early reflections from the
% floor etc, what would be the time after which Hrir is zero? 
% hrirs = hrirs([1:27 29:50],:,:,:);
% for u = 1:size(hrirs,1)
%     for a = 1:size(hrirs,2)
%         [k,mphrirs(u,a,1,:)] = rceps(squeeze(hrirs(u,a,1,:)));
%         [k,mphrirs(u,a,2,:)] = rceps(squeeze(hrirs(u,a,2,:)));
%         [xx,xx,xx,itd_samples(u,a)] = calculate_itd(squeeze(hrirs(u,a,1,:)),squeeze(hrirs(u,a,2,:)),fs);
%     end
% end