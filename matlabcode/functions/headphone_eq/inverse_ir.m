function iir = inverse_ir(ir,mode)
% function iir = inverse_ir(ir,mode)    
% iir: inverse impulse response
% ir : impulse response to invert
% mode: 1 -> minimum phase inversion
% mode: 2 -> reverse phase inversion

    i_l = length(ir);
    mg = abs(fft(ir,i_l));
    mg = mg/max(mg);
    mg = mg + 0.12;
    s_f = length(mg);
    if mod(s_f,2) == 0
        s_fi = length(mg)/2;
    else
        s_fi = (length(mg)-1)/2;
    end
%   mg(find(mg<0.1)) = 0.01;
    if mode == 1 % Minimum Phase Inverse 
        phase = imag(-hilbert(log(1./mg(1:s_fi))));
        if mod(s_f,2) == 0
            phase(s_fi:s_f) = conj(phase(s_fi:-1:1));
        else
            phase(s_fi+1) = 0;
            phase((s_fi+2):s_f) = conj(phase(s_fi:-1:1));
        end
    end

    if mode == 2 % Inverse Phase Inverse 
        phase = -angle(fft(ir,i_l));
    end
    iir = real(ifft((1./mg).*exp(j*phase),length(ir)));
%     iir = iir/max(abs(iir));
       
end