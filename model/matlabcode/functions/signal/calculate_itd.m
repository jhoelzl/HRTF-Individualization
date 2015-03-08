function [ itd_ms,idtpos1,idtpos2, itd_samples] = calculate_itd( plotdata_l,plotdata_r,fs )

% Calculate ITD from left and right HRIR

if (nargin < 3)
fs = 44100;
end

[hrir_size1 hrir_size2] = size(plotdata_l);
    
    Rxy = xcorr(plotdata_r,plotdata_l);
    Rxx = xcorr(plotdata_l,plotdata_l);
    Ryy = xcorr(plotdata_r,plotdata_r);
    [maxRxy maxInd] = max(Rxy);
    
    % Cross Correlation Function
    Yxy = Rxy / sqrt(Rxx' * Ryy);
    [maxYxy maxInd] = max(Yxy);
    
    % Text Position in HRIR Plot
    itd_samples = mod(maxInd,hrir_size1);    
    if (itd_samples < hrir_size1) && (itd_samples > (hrir_size1/2))
        itd_samples = itd_samples -hrir_size1;
    end
    
    itd_ms = itd_samples/fs*1000;
    idtpos1 = hrir_size1 * 0.5;
    idtpos2 = max(plotdata_l) * 0.5;

end