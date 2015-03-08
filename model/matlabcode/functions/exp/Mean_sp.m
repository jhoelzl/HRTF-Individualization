function p = mean_sp(v)
% computes the mean direction of d which are in hp coords
% calculated using drcos_sp()
% p is the mean vector in hp coords and

[r,c]=size(v);
if r==1 
  p = v;
else
  % get average
  d = Drcos_sp(v);			% direction cosines
  s = sum(d);
  r = sqrt(sum(s .* s));
  s = s / r;                              % mean direction cosines
  p = Tp2hp(Dc2tp(s));
end
