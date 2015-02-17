
function g = g_dig_filter(x)

global edges ws T weight1 weight2 weight3 w p J Number_of_variables L M_First M_Second M_Third


Num=zeros(L,J);
Den=zeros(L,J);
g_partial=zeros(L,4*J+1);    


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


for i=1:L
    

    if w(i)<=edges(1)
        weight=weight1;
    elseif w(i)<=edges(3) & w(i)>=edges(2)
        weight=weight2;
    elseif w(i)<=(ws/2) & w(i)>=edges(4)
        weight=weight3;
    end
    
       
 
        
        index=0;
        for j=1:J
            g_partial(i,j+index)=sign(e(i))*weight*[x(j+index)+x(j+index+1)*cos(w(i)*T)+cos(2*w(i)*T)]*M(i)/(Num(i,j)^2);
            g_partial(i,j+index+1)=sign(e(i))*weight*[x(j+index+1)+(1+x(j+index))*cos(w(i)*T)]*M(i)/(Num(i,j)^2);    
            g_partial(i,j+index+2)=-sign(e(i))*weight*[x(j+index+2)+x(j+index+3)*cos(w(i)*T)+cos(2*w(i)*T)]*M(i)/(Den(i,j)^2);
            g_partial(i,j+index+3)=-sign(e(i))*weight*[x(j+index+3)+(1+x(j+index+2))*cos(w(i)*T)]*M(i)/(Den(i,j)^2);
            index=index+3;
        end
        
       g_partial(i,4*J+1)=sign(e(i))*weight*M(i)/x(4*J+1);  
    
 
       
end

E_hat=max(abs(e));

temp1=0;
for i=1:L
temp1=(abs(e(i))/E_hat)^p+temp1;
end


temp3=1/p;
cof=(temp1^(temp3-1));
temp4=zeros(1,Number_of_variables);


for i=1:L
temp4=cof*((abs(e(i))/E_hat)^(p-1))*g_partial(i,1:Number_of_variables)+temp4;
end



g=[temp4].';
