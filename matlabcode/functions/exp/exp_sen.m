function [d_p,d_sub,hr_sub,fa_sub] = exp_sen(hr,fa,subjects_ids)
% Compute Sensitivity d_pooled and d_subject

% Pooled Data
hr_p = permute(hr,[1,5,2,3,4]);
hr_p = reshape(hr_p,[length(subjects_ids)*2,4,5,7]);

fa = squeeze(fa(:,:,:,4,:));
fa_p = permute(fa,[1,4,2,3]);
fa_p = reshape(fa_p,[length(subjects_ids)*2,4,5]);

fa_p_sub = permute(fa,[4,3,1,2]);
fa_p_sub = reshape(fa_p_sub,[10,length(subjects_ids),4]); % only dependent on subject and position and rep

% Correction Values for Pooled Data
h_min = 1/(size(hr_p,1)*2); % 1/(20*2)
h_max = (size(hr_p,1)-0.5) / (size(hr_p,1));
f_min = 1/(size(fa_p,1)*2);% 1/(1*2)
f_max = (size(fa_p,1)-0.5) / (size(fa_p,1));

h_max = f_max;
h_min = f_min;

% Correction Values for subjects
h_min_sub = 1/(size(hr,5)*2);% 1/(2*2)
h_max_sub = ( (size(hr,5)-0.5))/ ((size(hr,5)));
f_min_sub = 1/(size(fa_p_sub,1)*2); % 1/(35*2)
f_max_sub = ( (size(fa_p_sub,1)-0.5))/ (size(fa_p_sub,1));

% Correction
h_max_sub = f_max_sub;
h_min_sub = f_min_sub;

% Correct Min
hr_p(hr_p==0)=f_min;
fa_p(fa_p==0)=f_min;
hr(hr==0)=h_min_sub;
fa_p_sub(fa_p_sub==0)=f_min_sub;

% Correct Max
hr_p(hr_p==1)=h_max;
fa_p(fa_p==1)=f_max;
hr(hr==1)=h_max_sub;
fa_p_sub(fa_p_sub==1)=f_max_sub;

% Sensitivity per Subject
hr_sub = squeeze(mean(hr,5));
fa_sub = squeeze(mean(fa_p_sub,1));
fa_sub = repmat(fa_sub,[1,1,5,7]);
d_sub = norminv(hr_sub) - norminv(fa_sub);

% Pooled Sensitivity

%fa_p = mean(fa_p,1);
%fa_p = fa_p';

fa_p = repmat(fa_p,[1 1 1 7]);
d_p = squeeze(norminv(mean(hr_p,1))) - squeeze(norminv(mean(fa_p,1)));

% for i=1:7
%     d_p(:,:,:,i) = squeeze(norminv(mean(hr_p(:,:,:,i),1))) - squeeze(norminv(mean(fa_p,1)));
% end

% Criterion
c = (- squeeze(norminv(mean(hr_p,1))) + squeeze(norminv(mean(fa_p,1))))/2;


end

