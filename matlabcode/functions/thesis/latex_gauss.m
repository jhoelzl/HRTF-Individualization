
a = -100; b = 100;
x = a + (b-a) * rand(1, 500);
mu = (a + b)/2;
s = 30; 


p1 = -.5 * ((x - mu)/s) .^ 2;
p2 = (s * sqrt(2*pi));
f = exp(p1) ./ p2; 

plot(x,f,'.r')
%grid on
title('Normal distribution')
xlabel('+- 3x standard deviation')
%ylabel('Gauss Distribution') 

