function m = smooth_hrtfs(m)
    
% Smooth HRTF Spectrum by Reducing the Fourier Coefficients

if m.dataset.parameter.smooth_ratio~=1    
    hrtfs = log10(m.dataset.hrtfs);        
    % N = Fourier Coefficients
    % dataset.smooth = smoothing ratio
    % N = round(dataset.smooth/512 * (size(hrtfs,4)/2+1));
    N = round((size(hrtfs,4)/2)/m.dataset.parameter.smooth_ratio);
    m.dataset.parameter.frequency_smooth = N;

    fft_length = size(hrtfs,4);
    fft_hrtf = fft(hrtfs,fft_length,4);
    fir_a = abs(fft_hrtf);
    fir_e = angle(fft_hrtf);

    rtf = cat(4,fir_a(:,:,:,1:N),zeros(size(fir_a,1),size(fir_a,2),size(fir_a,3),length((N+1):(fft_length-N))),fir_a(:,:,:,(fft_length-N+1):1:fft_length));
    bir = real(ifft(rtf.*exp(1i*fir_e),[],4));
    m.dataset.hrtfs = 10.^(bir);
    I = m.dataset.hrtfs(:)<0;
    if sum(I)>0
        fprintf('Negative Values while Smoothing\n');
    end
    %fprintf('Smoothed at factor %i/%i=%.2f',N,size(hrtfs,4)/2,N/(size(hrtfs,4)/2+1));
else
    m.dataset.parameter.frequency_smooth = (size(m.dataset.hrtfs,4)/2);
end
    
end