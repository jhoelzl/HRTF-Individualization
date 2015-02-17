

function f= f_dig_filter(x)

global edges ws T weight1 weight2 weight3 w p J L M_First M_Second M_Third



Num=zeros(L,J);
Den=zeros(L,J);


for i=1:L
    

    if w(i)<=edges(1)
        M0(i)=M_First;
        weight=weight1;
    elseif w(i)<=edges(3) & w(i)>=edges(2)
        M0(i)=M_Second;
        weight=weight2;
    elseif w(i)<=(ws/2) & w(i)>=edges(4)
        M0(i)=M_Third;
        weight=weight3;
    end
    
    index=0;
    
    
    for j=1:J 
    Num(i,j)=sqrt(1+(x(j+index)^2)+(x(j+index+1)^2)+2*x(j+index+1)*(1+x(j+index))*cos(w(i)*T)+2*x(j+index)*cos(2*w(i)*T));
    Den(i,j)=sqrt(1+(x(j+index+2)^2)+(x(j+index+3)^2)+2*x(j+index+3)*(1+x(j+index+2))*cos(w(i)*T)+2*x(j+index+2)*cos(2*w(i)*T));
    index=index+3;
    end
    

    
    tempp=1;
    
    for j=1:J
    tempp=(Num(i,j)/Den(i,j))*tempp;
    end
    
    M(i)=x(4*J+1)*tempp;  
    e(i)=weight*(M(i)-M0(i));
    
  
end

E_hat=max(abs(e));


temp=0;

for i=1:L
    temp=(abs(e(i))/E_hat)^p+temp;
end

f=E_hat*(temp^(1/p));



