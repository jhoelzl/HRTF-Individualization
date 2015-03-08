function [ hrir_left,hrir_right ] = itd_alignment_old( hrir_left, hrir_right,itd_samples )

if (itd_samples > 0)
    % right ear later
    hrir_right = circshift(hrir_right,abs(itd_samples));
    hrir_right(1:abs(itd_samples)) = 0; 
else
    % left ear later
    hrir_left = circshift(hrir_left,abs(itd_samples));
    hrir_left(1:abs(itd_samples)) = 0;
end


end

