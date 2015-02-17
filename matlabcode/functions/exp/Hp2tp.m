function tp=Hp2tp(p)
%function tp=hp2tp(p) 
% converts from hoop coordinates az -180=>0=>+180, el +/-90
% to (theta,phi) coordinates where theta 0=>2pi and phi 0=>pi
% two cols of data are assumed Az El 
% p is a matrix with [az el] being the columns and the samples as rows
% tp is a matrix with [theta phi] being the columns and the samples as rows
tp=p;
for n=1:size(p,1)
	tp(n,2) = -p(n,1);
	if tp(n,2) < 0
		tp(n,2) = 360 + tp(n,2);
	end
	tp(n,1) = 90 - p(n,2);
end
tp = tp .* pi / 180;
end