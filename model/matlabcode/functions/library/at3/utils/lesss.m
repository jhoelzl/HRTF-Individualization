function Xn = lesss(X,points)

% input:
%   X = matrix to be reduced in size
%   points = to how many points
%
% output:
%   Xn = new reduced matrix


Xn=zeros(points,size(X,2));

for n=1:points 
    Xn(n,:)=X(((points/5)*(n-1))+1,:);
end
end