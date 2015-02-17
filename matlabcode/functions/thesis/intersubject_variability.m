function intersubject_variability(db)

% Config
subjects = [12 25 40];
ear = 2;
az = 45;
el = 45;

[m] = core_calc(db,3,0);

pos_ind = get_matrixvalue(az,el,m.dataset.angles);

for sub=1:length(subjects)
    hrtf_spec(sub,:) = squeeze(m.dataset.hrtfs(sub,pos_ind,ear,1:(size(m.dataset.hrtfs,4)/2+1)));
end

% log spectrum
hrtf_spec = 20*log10(hrtf_spec);

N = size(m.dataset.hrtfs,4);
freq = (0 : (N/2)) * m.database.fs / N;
freq = freq / 1000; % in kHz

clrs = {'b','r','g','k'};

figure(1)
clf;

for sub = 1:size(hrtf_spec,1)
    plot(freq,squeeze(hrtf_spec(sub,:)),'Color',clrs{sub},'LineWidth',1.5)
    %semilogx(freq,squeeze(hrtf_spec(sub,:)),'Color',clrs{sub})
    hold on
end

grid on
xlabel('frequency [kHz]')
ylabel('magnitude [dB]')
title('Left ear HRTFs of three different subjects')
xlim([0 20])

cell_sub = cellstr(num2str(subjects', 'Sub ID%i'));
legend(cell_sub)
saveas(1,sprintf('../thesis/images/spectrum/variability/%s_hrtfs_%i_subjects',db,length(subjects)),'epsc');
end

