function s = stimulus2(fm,T,fs)

if nargin < 2,
   fprintf('Format: s = stimulus(T [,fs])\n');
   return;
end;

T = fix(fm*(T/1000)+0.9999)/fm;

L = round(fs*T);   

r = randn(1,L);

s = r';