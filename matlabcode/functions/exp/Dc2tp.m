function p = Dc2tp(d)
% converts between direction cosines and theta phi coords

p = [acos(d(:,3)) atan2(d(:,2), d(:,1))];   % mean direction
% convert atan2 fn to between 0 and 2*pi
if (p(2) < 0)
        p(2) = p(2) + 2 * pi;
end
