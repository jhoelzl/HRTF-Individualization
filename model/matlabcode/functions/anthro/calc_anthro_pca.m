function [DATA_N,DATA] = calc_anthro_pca(modus)
% Calc PCA of CIPIC Anthro DATA
% modus = 1: all dimensions
% modus = 2: only pinna dimensions
% modus = 3: only D
% modus = 4: only theta

DATA = [];
load('../../db/CIPIC/anthropometry/anthro.mat');
%close all;

if (modus ==1)
% all dimensions
DATA = [D WeightKilograms X theta];   
DATA_N = DATA([1,4,9,11,13:41,43,44],:);
plots = 5;
end

if (modus == 2)
% only pinna related dimensions (D and theta)
DATA = [D theta];
DATA_N = DATA([1,4,9,11:41,43:45],:);
plots = 5;
end

if (modus == 3)
% only pinna related dimensions (D)
DATA = [D];
DATA_N = DATA([1,4,9,11:41,43:45],:);
plots = 5;
end

if (modus == 4)
% only pinna related dimensions (theta)
DATA = [theta];
DATA_N = DATA([1,4,9,11:41,43:45],:);
plots = 4;
end

% Perform PCA
[project,pc,mn,v] = pca3(DATA_N);

% Plot
figure
for n=1:plots   
subplot(plots,1,n), plot(project(:,n))
str_title = sprintf('PC %i',n);
title(str_title);
str=sprintf('%2.2f ' ,v(n)/sum(v)*100); 
legend(str)
end
end

