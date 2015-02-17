function y = mirror(X)
R=length(X(1,:));
L=length(X(:,1));
if isreal(X(1,:))
    X=X;
else
    X(1,:)=zeros(1,R);
end
    newvec=zeros(2*L,R);
    newvec(1:L,:)=X;
    newvec(L+1,:)=X(1,:);
    newvec(L+2:2*L,:)=conj(flipud(X(2:L,:)));
y=newvec;