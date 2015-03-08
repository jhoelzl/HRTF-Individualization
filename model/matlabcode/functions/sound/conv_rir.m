function [left,right] = conv_rir(left,right,rir)

% RIR

if (~isempty(rir))
    rir = sum(rir,2);
    left = filter(rir,1,left);
    right = filter(rir,1,right);
end    

end