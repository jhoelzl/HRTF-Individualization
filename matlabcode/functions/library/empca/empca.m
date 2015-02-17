function [evec,weights,eval] = empca(data,k,iter,Cinit)
%[evec,eval] = empca(data,k,iter,Cinit)
%
% EMPCA
%
% finds the first k principal components of a dataset 
% and their associated eigenvales using the EM-PCA algorithm
%
% Inputs:  data is a matrix holding the input data
%               each COLUMN of data is one data vector
%               NB: mean will be subtracted and discarded
%          k    is # of principal components to find
%
% optional:
%          iters is the number of iterations of EM to run (default 20)
%          Cinit is the initial (current) guess for C (default random)
%
% Outputs:  evec holds the eigenvectors (one per column)
%           eval holds the eigenvalues
%


[d,N]  = size(data);
data = data - mean(data,2)*ones(1,N);

if(nargin<4) Cinit=[]; end
if(nargin<3) iter=20; end

[evec,eval] = empca_orth(data,empca_iter(data,Cinit,k,iter));

weights = data' * evec;



function [C] = empca_iter(data,Cinit,k,iter)
%[C] = empca_iter(data,Cinit,k,iter)
%
% EMPCA_ITER
%
% (re)fits the model 
%
%    data = Cx + gaussian noise 
%
% with EM using x of dimension k
%
% Inputs:  data is a matrix holding the input data
%               each COLUMN of data is one data vector
%               NB: DATA SHOULD BE ZERO MEAN!
%          k    is dimension of latent variable space 
%               (# of principal components)
%          Cinit is the initial (current) guess for C
%          iters is the number of iterations of EM to run
%
% Outputs: C is a (re)estimate of the matrix C 
%             whose columns span the principal subspace 
%

% check sizes and stuff
[p,N] = size(data);
assert(k<=p);
if(isempty(Cinit)) 
  C = rand(p,k); 
else
  assert(k==size(Cinit,2));
  assert(p==size(Cinit,1));
  C = Cinit;
end

% business part of the code -- looks just like the math!
for i=1:iter
       % e step -- estimate unknown x by random projection
  x = inv(C'*C)*C'*data;
       % m step -- maximize likelihood wrt C given these x values
  C = data*x'*inv(x*x');
  

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [evec,eval] = empca_orth(data,C)
%[evec,eval] = empca_orth(data,Cfinal)
%
% EMPCA_ORTH
%
% Finds eigenvectors and eigenvalues given a matrix C whose columns span the
% principal subspace.
%
% Inputs:  data is a matrix holding the input data
%               each COLUMN of data is one data vector
%               NB: DATA SHOULD BE ZERO MEAN!
%          Cfinal is the final C matrix from empca.m
%
% Outputs: evec,eval are the eigenvectors and eigenvalues found
%          by projecting the data into C's column space and finding and
%          ordered orthogonal basis using a vanilla pca method
%

  C = orth(C);
  [xevec,eval] = truepca(C'*data);
  evec = C*xevec;