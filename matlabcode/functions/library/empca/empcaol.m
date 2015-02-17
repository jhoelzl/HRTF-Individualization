function [evec,eval] = empcaol(k,iter,Cinit)
%[evec,eval] = empcaol(k,iter,Cinit)
%
% EMPCAOL (ONLINE VERSION OF EMPCA)
%
% finds the first k principal components of a dataset 
% and their associated eigenvales using the EM-PCA algorithm
%
% Inputs:  k    is # of principal components to find
%
% optional:
%          iters is the number of iterations of EM to run (default 20)
%          Cinit is the initial (current) guess for C (default random)
%
% the data is provided by the function nextpoint
% nextpoint(1) re-initializes the data providing function
% nextpoint(0) to get successive datavectors
% nextpoint(0) should return 0 when it is out of data
% NB: nextpoint should return data with the mean already subtracted out
%
% Outputs:  evec holds the eigenvectors (one per column)
%           eval holds the eigenvalues
%


if(nargin<3) Cinit=[]; end
if(nargin<2) iter=20; end

[evec,eval] = empcaol_orth(empcaol_iter(Cinit,k,iter));



function [C] = empcaol_iter(Cinit,k,iter)
%[C] = empcaol_iter(Cinit,k,iter)
%
% EMPCA ONLINE ITERATIONS
%
% (re)fits the model 
%
%    data = Cx + gaussian noise 
%
% with EM using x of dimension k 
% Gets points one at a time ONLINE. Uses the function nextpoint.m.
%
% Inputs:  k    is dimension of latent variable space 
%               (# of principal components)
%          Cinit is the initial (current) guess for C
%          iters is the number of iterations of EM to run
%
% Outputs: C is a (re)estimate of the matrix C 
%             whose columns span the principal subspace 
%
% uses nextpoint(1); to reinitialize nextpoint each pass through the data
% uses nextpoint(0) to get successive datavectors
% NB: nextpoint should return data with the mean already subtracted out
%

% check sizes and stuff


p = nextpoint(1);

if(isempty(Cinit)) 
  C = rand(p,k); 
else
  assert(k==size(Cinit,2));
  assert(p==size(Cinit,1));
  C = Cinit;
end

% loop for iterations
for ii=1:iter
  nextpoint(1);       % reset nextpoint
  C = empcaol1(C);    % let's do it
end

function [Cnew] = empcaol1(C)
%[Cnew] = empcaol1(C)
%
%does one complete E AND M step of empca by calling nextpoint(0)
%to get successive datapoints
%
% NB: nextpoint should return data with the mean already subtracted out

[p,k] = size(C);
CC = inv(C'*C)*C';
W = zeros(k,k);
Q = zeros(p,k);

[yi,status] = nextpoint(0);

while(status>0)
%  fprintf(1,'Now processing datapoint %d\r',status);
  xi = CC*yi;
  wi = xi*xi'; W = W+wi;
  qi = yi*xi'; Q = Q+qi;
  [yi,status] = nextpoint(0);
end

Cnew = Q*inv(W);




function [evec,eval] = empcaol_orth(C)
%[evec,eval] = empcaol_orth(Cfinal)
%
% finds ordered orthogonal basis for subspace identified in Cfinal
%
% online method
% uses nextpoint(1) to initialize data generator 
% uses nextpoint(0) to provide successive data vectors
% NB: nextpoint should return data with the mean already subtracted out


[p,k] = size(C);
W = zeros(k,k);

C = orth(C);
  
nextpoint(1);
[yi,status] = nextpoint(0);
while(status>0)
%    fprintf(1,'Now processing datapoint %d\r',status);
  nf = status;
  xi = C'*yi;
  W = W+xi*xi';
  [yi,status] = nextpoint(0);
end

[cvv,cdd] = eig(W/nf);
[zz,ii] = sort(diag(cdd));
ii = flipud(ii);
xevec = cvv(:,ii);
cdd = diag(cdd);
eval = cdd(ii);

evec = C*xevec;
  