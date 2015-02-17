function r=rmse(data,estimate)

% Function to calculate root mean square error from a data vector or matrix 
% and the corresponding estimates.
% Usage: r=rmse(data,estimate)
% Note: data and estimates have to be of same size
% Example: r=rmse(randn(100,100),randn(100,100));

r =  sqrt(mean((data(:)-estimate(:)).^2));