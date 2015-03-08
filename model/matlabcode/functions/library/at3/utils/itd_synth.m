function [YL,YR] = itd_synth(XL,XR,phi)

% synthesize calculate horizontal itd
% Input:
%   X = minimumphase HRIRs
%   phi = azimuth 

len = length(phi);

itd = zeros(len,1);
for k=1:len
    itd(k) = itd_calc(phi(k),0);
end

YL = zeros(size(XL));
YR = zeros(size(XR));

for j=1:floor(len/2+1)
    YR(j,:) = circshift(XR(j,:),[0,abs(itd(j))]);
    YR(j,1:itd(j)) = 0; 
end
YR(floor(len/2+1)+1:len,:) = XR(floor(len/2+1)+1:len,:);

for j=floor(len/2+1)+1:len
    YL(j,:) = circshift(XL(j,:),[0,abs(itd(j))]);
    YL(j,1:abs(itd(j))) = 0;
end
YL(1:floor(len/2+1)-1,:) = XR(1:floor(len/2+1)-1,:);
end