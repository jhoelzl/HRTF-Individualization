function Xn = reduce_m(X,r,c)

% input:
%   X = input matrix
%   r = desired rows, vector
%   c = desired columns, vector

n = length(r);
m = length(c);
Xn = zeros(n,m);

for k=1:n
    for i=1:m
        Xn(k,i) = X(r(k),c(i));
    end
end
end

