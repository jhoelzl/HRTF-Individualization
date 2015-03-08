
function [a1 a2 b1 b2]=random_stable_initial_points

b=randn(1,2);
r=roots([1 b(2) b(1)]);
index=1;

while abs(r(1))>1 | abs(r(2))>1
    b=randn(1,2);
    r=roots([1 b(2) b(1)]);
    index=index+1;
end

a=randn(1,2);


a1=a(1);
a2=a(2);
b1=b(1);
b2=b(2);

