function test_mean(db)
% Test lin/log method to calculate DTF by: DTF = HRTF-CTF

% dtf1 = average with linear spectrum
% dtf2 = average in ceptral domain

m = core_calc(db,'local');

%Substract ear canal, dependent of each subject, average over angles
m.dataset.dtfs1 = m.dataset.hrtfs - repmat(mean(m.dataset.hrtfs,2),[1,size(m.dataset.hrtfs,2)]);
m.dataset.dtfs2 = 20*log10(m.dataset.hrtfs) - repmat(mean(20*log10(m.dataset.hrtfs),2),[1,size(m.dataset.hrtfs,2)]);
m.dataset.dtfs3 = m.dataset.hrtfs ./ repmat(mean(m.dataset.hrtfs,2),[1,size(m.dataset.hrtfs,2)]);

%Go back to linear magnitude spectrum
m.dataset.dtfs2 = 10.^(m.dataset.dtfs2/20);

figure(1)
clf;
plot(squeeze(m.dataset.dtfs1(1,2,1,:)),'b')
hold on
plot(squeeze(m.dataset.dtfs2(1,2,1,:)),'r')
hold on
plot(squeeze(m.dataset.dtfs3(1,2,1,:)),'y')
hold on
plot(squeeze(m.dataset.hrtfs(1,2,1,:)),'g')

end

