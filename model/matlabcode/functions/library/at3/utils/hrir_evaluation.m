function [e,E_log,sd] = hrir_evaluation(X,H)
% hrtf_evaluation ... evaluates hrtfs in differents ways

% Input:
%   X = Input matrix containing the HRIRs (rows = positions , coloums = samples)
%   H = Reference HRIRs, matrix of same size
%

%% Init
if isequal(size(X),size(H)) == 0
    disp('The size iof the input vector/matrix and the reference has to be same')
    return
end
[n,m] = size(X);
m = 256; 

% L2-Norm
Xf = fft(X,m,2);
Hf = fft(H,m,2);

a = (abs(Xf) - abs(Hf)).^2;
b = abs(Xf).^2;
e = sqrt(a./b);


% log magnitude error function computation
X_log = 20*log10(abs(Xf));
H_log = 20*log10(abs(Hf));
E_log = abs(X_log(:,1:m/2+1)-H_log(:,1:m/2+1));
sd   = mean(E_log,2);


% same but ERB filtering before
% fcoefs = MakeERBFilters(44100,10,80);
% for k = 1:n
%     ERB_m = ERBFilterBank(X(k,:),fcoefs);
%     X_erb(k,:) = sum(ERB_m);
% end
% for k = 1:n
%     ERB_m = ERBFilterBank(Ref(k,:),fcoefs);
%     Ref_erb(k,:) = sum(ERB_m);
% end
% 
% X_erb_log = 20*log10(abs(fft(X_erb,m,2)));
% Ref_erb_log = 20*log10(abs(fft(Ref_erb,m,2)));
% E_erb_log = abs(X_erb_log(:,1:m/2+1)-Ref_erb_log(:,1:m/2+1));
% sd_erb   = mean(E_erb_log,2);

end

