function [V, A] = empca_old(X,p)
% EM like algorithm for principal component analysis (by Sam Roweis)
% reference:
% Pattern Recognition and Machine Learning by Christopher M. Bishop 
[d,n] = size(X); 
X = bsxfun(@minus,X,mean(X,2));
W = rand(d,p); 

tol = 1e-8;
error = inf;
last = inf;
iter = 0;

disp('Start Iteration')
 
while ~(abs(last-error)<error*tol)
    iter = iter+1;
    disp(iter)
    
    Z = (W'*W)\(W'*X);
    W = (X*Z')/(Z*Z');

    last = error;
    E = X-W*Z;
    error = E(:)'*E(:)/n;
    
end

disp('End Iteration')

% fprintf('converged in %d steps.\n',iter);
W = normalize(orth(W));  % the liner subspace spanned by W does not change after orthonormalization
% % use QR to orthnormalize W. qr() is faster that orth().
% [W,R] = qr(W,0); %#ok<NASGU>
Z = W'*X;
Z = bsxfun(@minus,Z,mean(Z,2));  % for numerical purpose, not really necessary
[V,A] = eig(Z*Z');
[A,idx] = sort(diag(A),'descend');
V = V(:,idx);
V = W*V;
