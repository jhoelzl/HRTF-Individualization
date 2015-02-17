function ir = dcvl(r,s,n1,n2)

    N = 2^nextpow2(size(s,1));
    swf = fft(s,N);

    ir = real(ifft(fft(r,N)./swf));
    figure(2)
    
    ir = ir(n1:n2);
    
    plot(ir)
    
    win = hanning(81);
    win1 = win(1:40);
    win2 = win(41:81);
    ir(1:40) = ir(1:40).*win1;
    ir((length(ir)-40):length(ir)) = ir((length(ir)-40):length(ir)).*win2;
    
end