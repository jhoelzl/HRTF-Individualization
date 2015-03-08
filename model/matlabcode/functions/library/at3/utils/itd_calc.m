function [ itd ] = itd_calc(phi,theta)
%UNTITLED2 Summary of this function goes here
% output:
%   itd = itd in samples  

%head radius
r = 0.085;
c = 343;
itd = (r/c)*(asin(cos(theta)*sin(phi)) + cos(theta)*sin(phi));
% itd = (r/c)*(phi+sin(phi));
itd = round(itd*44100);
end



