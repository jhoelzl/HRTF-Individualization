function [left,right] = conv_hptf(left,right,eq_id)

% Convolute binaural sound samples with Headphone equalization

switch (eq_id)
    case 2 % josef k271
    load('sounds/hptf/josef_k271.mat','iir');  
    left = filter(iir,1,left);
    right = filter(iir,1,right);

    case 3 % georgios k272
    load('sounds/hptf/georgios_k272.mat','iir');
    left = filter(iir,1,left);
    right = filter(iir,1,right);
end
   

end