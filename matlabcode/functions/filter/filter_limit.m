function nir = filter_limit(ir,Wn)
N = 7;
B = fir1(8,Wn);
nir = filter(B,1,ir);
nir = circshift(nir,-(N+1)/2);
end