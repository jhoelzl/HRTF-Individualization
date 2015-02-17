function bir = band_limit(ir,N,offset)

fir_s = fft(ir,offset);
fir_a = abs(fir_s);
fir_e = angle(fir_s);
rtf = [fir_a(1:N);1e-5*ones(1,length((N+1):(offset-N)))';fir_a((offset-N+1):1:offset)];
% bir = real(ifft(rtf.*(cos(fir_e)+1i*sin(fir_e))));
bir = real(ifft(rtf.*exp(1i*fir_e)));

if ~isempty(find(bir<0))
    1;
end
end