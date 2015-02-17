function d = Drcos_sp(v)
% function d=drcos_sp(v)
% returns the direction cosines of vector v (v is in hp coords)

raddata = Hp2tp(v);
% calculate direction cosines
d = [sin(raddata(:,1)) .* cos(raddata(:,2)) ...
	sin(raddata(:,1)) .* sin(raddata(:,2)) ...
	cos(raddata(:,1))];
end