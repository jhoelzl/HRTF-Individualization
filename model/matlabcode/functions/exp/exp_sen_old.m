function [d_p,d_sub] = exp_sen_old(hr,fa,subjects_ids)
% Compute Sensitivity d_pooled and d_subject


% Pooled Data
hr_1 = permute(hr,[1,5,2,3,4]);
hr_1 = reshape(hr_1,[length(subjects_ids)*2,4,5,7]);

fa_1 = permute(fa,[1,5,2,3,4]);
fa_1 = reshape(fa_1,[length(subjects_ids)*2,4,5,7]);
fa_1 = squeeze(mean(mean(mean(fa_1,1),3),4));

fa_1_sub = permute(fa,[3,4,1,2,5]);
fa_1_sub = reshape(fa_1_sub,[5*7,length(subjects_ids),4,2]); % only dependent on subject and position and rep


% Correction Values for Pooled Data
h_min = 1/(size(hr_1,1)*2); % 1/(20*2)
h_max = (size(hr_1,1)-0.5) / (size(hr_1,1));
f_min = 1/(size(fa_1,1)*2);% 1/(1*2)
f_max = (size(fa_1,1)-0.5) / (size(fa_1,1));


% Correction Values for subjects
h_min_sub = 1/(size(hr,5)*2);% 1/(2*2)
h_max_sub = ( (size(hr,5)-0.5))/ ((size(hr,5)));
f_min_sub = 1/(size(fa_1_sub,1)*2); % 1/(35*2)
f_max_sub = ( (size(fa_1_sub,1)-0.5))/ ((size(fa_1_sub,1)));

% Correct Min
hr_1(hr_1==0)=h_min;
fa_1(fa_1==0)=f_min;
hr(hr==0)=h_min_sub;
fa_1_sub(fa_1_sub==0)=f_min_sub;


% Correct Max
hr_1(hr_1==1)=h_max;
fa_1(fa_1==1)=f_max;
hr(hr==1)=h_max_sub;
fa_1_sub(fa_1_sub==1)=f_max_sub;


% Sensitivity per Subject
hr_sub = squeeze(mean(hr,5));
fa_sub = squeeze(mean(mean(fa_1_sub,1),4));
fa_sub = repmat(fa_sub,[1,1,5,7]);
d_sub = norminv(hr_sub) - norminv(fa_sub);

% Pooled Sensitivity
hr_p = squeeze(mean(hr_1,1));
fa_p = fa_1;
fa_p = fa_p';
fa_p = repmat(fa_p,[1,5,7]);
d_p = norminv(hr_p) - norminv(fa_p);

end

