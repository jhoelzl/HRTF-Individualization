function [ maxYxy ] = cross_cor_anthro( plotdata_l,plotdata_r )

% Calculate ITD from left and right HRIR

[hrir_size1 hrir_size2] = size(plotdata_l);
    
    Rxy = xcorr(plotdata_r,plotdata_l);
    Rxx = xcorr(plotdata_l,plotdata_l);
    Ryy = xcorr(plotdata_r,plotdata_r);
    [maxRxy maxInd] = max(Rxy);
    
    
    size(Rxx)
    size(Ryy)
    size(Rxy)
    
    % Cross Correlation Function
    Yxy = Rxy / sqrt(Rxx' * Ryy);
    [maxYxy maxInd] = max(Yxy);
    
    

end

