

function [Numerator,Denominator]=Dig_Filter(Filter_Length,Type,Method,edges,ws,Ap,Aa,Optimization_Method,Filter_Order,Number_of_Iterations,eps1,eps2)
                                                                                                                                                                                                                                      
% Written By:   Iman Moazzen
%               Dept. of Electrical Engineering
%               University of Victoria
%               Under supervision of Prof. Andreas Antoniou and Prof. Panajotis Agathoklis
%                                                                                          
% [Numerator,Denominator]=Dig_Filter(Filter_Length,Type,Method,edges,ws,Ap,Aa)
% 
% This function can be used to design a lowpass, highpass, bandpass, or bandstop filter which satisfies prescribed specifications. 
% 
% _ Filter_Length can be ‘FIR’ or ‘IIR’
% _ Type can be ‘Lowpass’, ‘Highpass’, ‘Bandpass’, or 'Bandstop'
% _ Method can be selected as follows:
%            a) In the case we are working with FIR filters, Method can be selected ‘Kaiser’ or ‘Optimization’
%            b) In the case we are working with IIR filters, Method can be selected ‘Elliptic’, ‘Chebyshev’, 
%            , ‘Butterworth’, or 'Optimization'***
%        _ Edges is a vector of frequencies (rad/s) including passband and stopband edges. The frequencies           
%           must be in an increasing order.
%        _ ws is the sampling frequency (rad/s)
%        _ Ap: peak to peak passband ripple (db)
%        _ Aa: minimum stopband attenuation (db)
%
%*** in this case, the following command must be used
%
% [Numerator,Denominator]=Dig_Filter(Filter_Length,Type,Method,edges,ws,Ap,Aa,Optimization_Method,Filter_Order,Number_of_Iterations,eps1,eps2)
%
% This function can be used to design a lowpass, highpass, bandpass, or bandstop IIR filter using optimizaation method. 
%          - Optimization_Method can be (default is fminunc):
%          1- fminunc (Matlab Function)
%          2- bfgs(Implements the quasi-Newton algorithm with the Broyden-Fletcher-Goldfarb-Shanno) [2] 
%          3- dfp(Implements the quasi-Newton algorithm with the Davidon-Fletcher-Powell) [2]
%          - Filter_Order must be selected even. If user leaves it undefined, the filter order is selected based on
%            the method described in chapter 12 of [1].
%          - Number_of_Iterations is the maximum number that user would like to repeat the algorithm (default is 5)  
%          - eps1 is the termination tolerance (default is 0.01)
%          - eps2 is the termination tolerance for bfgs and dfp algorithms (defult is 0.01)
%
% Note: If user doesn't set "Optimization_Method", "Filter_Order", "Number_of_Iterations", "eps1", or "eps2", the default value
% is selected during the algorithm. (In order to leave each of these parameters undefined, just put [] instead of that parameter)
%
% Note: In the FIR filters, when the optimization method is selected, first, the function uses Herrmann method and Algorithm.5 in
% chapter 15 of [1] to find a suitable order which satisfies prescribed specifications. Then by using "firpm" command (Parks-McClellan 
% optimal FIR filter design) the filter is designed.  
%
% Note: In the IIR filters, when the optimization method is selected, the least pth norm is the objective function.
% The minimax algorithm is deployed to find the optimal solution, and it may repeat as many as the 
% "Number_of_Iterations" parameter. Each time, a random stable initial point is considered and the algorithm runs. 
% If the final filter doesn't satisfy the specifications, the next random initial point is generated. However, finally, 
% the specifications may not be satisfied. In this case the best solution is chosen as the winner. 
% If the optimal solutin is unstable, it will be stabilized using the technique found on p. 535 of [1].
%
% 
% Example1:
% [Numerator,Denominator]=Dig_Filter('FIR','Lowpass','Kaiser',[100 200],1000,0.25,45); 
% Which designs a lowpass FIR filter using Kaiser Method. Passband edge is 100, and stopband edge is 200. ws=1000 (rad/s), 
% Ap=0.25 (db) , and Aa=45 (db)
% 
% Example2:
% [Numerator,Denominator]=Dig_Filter('FIR','Bandpass','Optimization',[100 200 300 400],1000,0.25,45);
% Which designs a bandpass FIR filter using optimization method. 
%
% Example3:
% [Numerator,Denominator]=Dig_Filter('IIR','Bandstop','Elliptic',[100 200 300 400],1000,0.25,45);
% Which designs a bandstop IIR filter using Elliptic method. 
%
% Example4:
% [Numerator,Denominator]=Dig_Filter('IIR','Bandstop','Optimization',[100 200 300 400],1000,0.25,45,'fminunc',8,2,[]);
% Which designs a bandstop IIR filter using Optimization method. 'fminunc' is selected as the optimization method. 
% Order of filter is 8, and the algorithm is repeated 2 times (if a good solution can not be achieved in the first iteration).
% eps1 is not defined and set to the default value.
%
% Example5:
% [Numerator,Denominator]=Dig_Filter('IIR','Highpass','Optimization',[100 200],1000,0.25,45,'bfgs',8,[],0.001,[]);
% Which designs a highpass IIR filter using Optimization method. 'bfgs' is selected as the optimization method. 
% Order of filter is 8. "eps1" is set to 0.001 "Number_of_Iterations" and "eps2" are not defined and set to the default values.
%
% -------------------------------------------------------------------------
% Acknowledgment:
% This toolbox was developed under the supervision of Profs. A. Antoniou and P. Agathoklis
% of the University of Victoria, Victoria, BC, Canada.
% 
% The toolbox uses three MATLAB optimization functions (bfgs, dfp, and
% inex_lsearch) developed by Profs. W.-S. Lu and A. Antoniou, which are
% part of the support materials of their textbook on optimization [2].
%
% My sincere thanks to all the people who have contributed to this toolbox.
% -------------------------------------------------------------------------
%
% References:
% [1]  A. Antoniou, Digital Signal Processing: Signals, Systems, and Filters, McGraw-Hill, 2005.
% http://www.ece.uvic.ca/~dsp/  .
% [2]  A. Antoniou and W.-S. Lu, Practical Optimization: Algorithms and Engineering Applications. Springer, 2007.
% http://www.ece.uvic.ca/~optimization/
%
%
% To find other Matlab functions about filter design,
% please visit http://www.ece.uvic.ca/~imanmoaz/index_files/index1.htm



error_flag=0;
aa=33.1938;

switch lower(Type)
       case {'lowpass'}
           if length(edges)~=2
               disp('Lowpass filter needs exactly two edges')
               error_flag=1;
           end
       case {'highpass'}
           if length(edges)~=2
               disp('Highpass filter needs exactly two edges')
               error_flag=1;
           end    
       case {'bandpass'}
           if length(edges)~=4
               disp('Bandpass filter needs exactly four edges')
               error_flag=1;
           end                
       case {'bandstop'}
           if length(edges)~=4
               disp('Bandstop filter needs exactly four edges')
               error_flag=1;
           end  
    otherwise
           disp('Unknown Type')
           error_flag=1;
end

if sum(sort(edges)~=edges)~=0
    disp('The cut-off frequencies must be in an increasing order')
    error_flag=1;
end
           
  

switch lower(Filter_Length)
    case {'iir'}
    case 'fir'
    otherwise
           disp('Unknown Filter Length')
           error_flag=1;        
end


switch lower(Method)
       case {'butterworth'}
       case 'chebyshev'   
       case 'elliptic'    
       case 'optimization'
       case 'kaiser'
       otherwise
           disp('Unknown Method')
           error_flag=1;     
end

if nargin>13
    disp('Too many inputs')
    error_flag=1;
elseif nargin<7
    disp('Not enough input arguments')
    error_flag=1;
end

if nargin>13
    disp('Too many inputs')
    error_flag=1;
end

switch lower(Filter_Length)
    case {'iir'}

        switch lower(Method)
            case {'optimization'}
                                        
                if isempty(Optimization_Method)
                      Optimization_Method='fminunc';
                else
                
                    switch lower(Optimization_Method)
                    case {'fminunc'}
                    case 'bfgs'
                         if isempty(eps2)
                            eps2=0.01;
                         end
                    case 'dfp'
                         if isempty(eps2)
                            eps2=0.01;
                         end
                    otherwise
                           disp('Unknown Optimization Method')
                           error_flag=1;  
                    end
                end
                
                if isempty(Filter_Order)                    
                else
                if Filter_Order/2~=round(Filter_Order/2)
                disp('Filter order must be even')
                error_flag=1;
                end
                end
                
                if isempty(Number_of_Iterations)
                    Number_of_Iterations=5;
                end
                
                if isempty(eps1)
                    eps1=0.01;
                end
                
        end
end

if ws/2<=edges(end)
    disp('The sampling frequency is not correct. ws/2 must be greater than the last element of "edges" vector')
    error_flag=1;
end




if error_flag==0
    
flag_opt=0;
T=2*pi/ws;

switch lower(Filter_Length)
    case {'iir'}
                temp1=(10^(0.1*Aa))-1;
                temp2=(10^(0.1*Ap))-1;

                D=temp1/temp2;
                M=10;

                switch lower(Type)
                    case {'lowpass'}
                    wp1=edges(1);
                    wa1=edges(2);   
                    K0=tan(wp1*T/2)/tan(wa1*T/2);
                    k=K0;
                    case 'highpass'   
                    wa1=edges(1);
                    wp1=edges(2);   
                    K0=tan(wp1*T/2)/tan(wa1*T/2);   
                    k=1/K0;
                    case 'bandpass'   
                    wa1=edges(1);
                    wp1=edges(2); 
                    wp2=edges(3);
                    wa2=edges(4); 
                    KA=tan(wp2*T/2)-tan(wp1*T/2);
                    KB=tan(wp1*T/2)*tan(wp2*T/2);
                    KC=tan(wa1*T/2)*tan(wa2*T/2);
                    K1=KA*tan(wa1*T/2)/(KB-(tan(wa1*T/2)^2));
                    K2=KA*tan(wa2*T/2)/((tan(wa2*T/2)^2)-KB);
                        if KC>=KB
                            k=K1;
                        else 
                            k=K2;
                        end     
                   case 'bandstop'

                    wp1=edges(1);
                    wa1=edges(2); 
                    wa2=edges(3);
                    wp2=edges(4); 
                    KA=tan(wp2*T/2)-tan(wp1*T/2);
                    KB=tan(wp1*T/2)*tan(wp2*T/2);
                    KC=tan(wa1*T/2)*tan(wa2*T/2);
                    K1=KA*tan(wa1*T/2)/(KB-(tan(wa1*T/2)^2));
                    K2=KA*tan(wa2*T/2)/((tan(wa2*T/2)^2)-KB);         
                       if KC>=KB
                            k=1/K2;
                        else
                            k=1/K1;
                       end

                end


                switch lower(Method)
                   case {'butterworth'}

                                switch lower(Type)
                                   case {'lowpass'}
                                    temp_n=log10(D)/(2*log10(1/k));
                                    n=ceil(temp_n);
                                    wp=(10^(0.1*Ap)-1)^(1/(2*n));
                                    landa=wp*T/(2*tan(wp1*T/2));

                                   case 'highpass'
                                    temp_n=log10(D)/(2*log10(1/k));
                                    n=ceil(temp_n);
                                    wp=(10^(0.1*Ap)-1)^(1/(2*n));
                                    landa=2*wp*tan(wp1*T/2)/T;  

                                   case 'bandpass'
                                    temp_n=log10(D)/(2*log10(1/k));
                                    n=ceil(temp_n);
                                    wp=(10^(0.1*Ap)-1)^(1/(2*n));

                                        w0=2*sqrt(KB)/T;
                                        B=2*KA/(T*wp);

                                   case 'bandstop'
                                    temp_n=log10(D)/(2*log10(1/k));
                                    n=ceil(temp_n);
                                    wp=(10^(0.1*Ap)-1)^(1/(2*n));       

                                        w0=2*sqrt(KB)/T;
                                        B=2*KA*wp/T;
                                end

                   case 'chebyshev'

                                switch lower(Type)
                                   case {'lowpass'}
                                    wp=1;
                                    landa=wp*T/(2*tan(wp1*T/2));

                                   case 'highpass'
                                    wp=1;
                                    landa=2*wp*tan(wp1*T/2)/T;  

                                   case 'bandpass'
                                        wp=1;
                                        w0=2*sqrt(KB)/T;
                                        B=2*KA/(T*wp);

                                   case 'bandstop'
                                        wp=1;
                                        w0=2*sqrt(KB)/T;
                                        B=2*KA*wp/T;
                                end       
                    case 'elliptic'

                                switch lower(Type)
                                   case {'lowpass'}
                                    wp=sqrt(k);
                                    landa=wp*T/(2*tan(wp1*T/2));

                                   case 'highpass'
                                    wp=sqrt(k);
                                    landa=2*wp*tan(wp1*T/2)/T;  

                                   case 'bandpass'
                                    wp=sqrt(k);
                                    w0=2*sqrt(KB)/T;
                                    B=2*KA/(T*wp);

                                   case 'bandstop'
                                    wp=sqrt(k);
                                    w0=2*sqrt(KB)/T;
                                    B=2*KA*wp/T;
                                end 
                     case 'optimization'
                         
                             global ws T edges Aa Ap weight1 weight2 weight3 m1 m2 m3 w p J Number_of_variables Number_of_samples L M_First M_Second M_Third
                             
                             
                               switch lower(Type)
                                   case {'lowpass'}
                                    wp=sqrt(k);
                                    landa=wp*T/(2*tan(wp1*T/2));

                                   case 'highpass'
                                    wp=sqrt(k);
                                    landa=2*wp*tan(wp1*T/2)/T;  

                                   case 'bandpass'
                                    wp=sqrt(k);
                                    w0=2*sqrt(KB)/T;
                                    B=2*KA/(T*wp);

                                   case 'bandstop'
                                    wp=sqrt(k);
                                    w0=2*sqrt(KB)/T;
                                    B=2*KA*wp/T;
                                end  
                                
                                


                                Mo=2;
                                E_hat(1)=10^(99);
                                
                                eps_a=10^(-0.05*Aa);
                                eps_p=[(10^(0.05*Ap))-1]/[(10^(0.05*Ap))+1]; 

                end


                switch lower(Method)
                   case {'butterworth'}
                            for i=1:2*n
                                if round(n/2)==n/2
                                z(i)=exp(sqrt(-1)*(2*i-1)*pi/(2*n));
                                else
                                z(i)=exp(sqrt(-1)*(i-1)*pi/n);
                                end
                            end

                            p=z(find(real(z)<0));


                            temp5=1;

                            for i=1:n
                                temp5=tf(1,[1,-p(i)])*temp5;
                            end

                            HN=temp5;
                    case 'chebyshev'
                            temp3=acosh(sqrt(D))/acosh(1/k);
                            n=ceil(temp3);

                            if round(n/2)==n/2
                                r=n/2;
                            else
                                r=(n-1)/2;
                            end

                            eps=sqrt((10^(0.1*Ap))-1);
                            delta_n=-sinh((1/n)*asinh(1/eps));
                            p0=delta_n;

                            for i=1:r
                                delta(i)=-sinh((1/n)*asinh(1/eps))*sin((2*i-1)*pi/(2*n));
                                w(i)=cosh((1/n)*asinh(1/eps))*cos((2*i-1)*pi/(2*n));
                                p(i)=delta(i)+sqrt(-1)*w(i);
                            end


                            temp4=1;

                            for i=1:r
                                temp4=abs(p(i))^2*temp4;
                            end


                            if round(n/2)==n/2
                                H0=(10^(-0.05*Ap))*temp4;
                                D0=1;
                            else
                                H0=-p0*temp4;
                                D0=tf([1,-p0],1);
                            end

                            temp5=1;

                            for i=1:r
                                temp5=tf([1,-2*real(p(i)),(abs(p(i)))^2],1)*temp5;
                            end

                            HN=H0/[D0*temp5];
                    case 'elliptic'
                            kp=sqrt(1-(k^2));
                            temp=sqrt(kp);
                            q0=0.5*(1-temp)/(1+temp);
                            q=q0+2*(q0^5)+15*(q0^9)+150*(q0^13);


                            temp3=log10(16*D)/(log10(1/q));
                            n=ceil(temp3);

                            if round(n/2)==n/2
                                r=n/2;
                            else
                                r=(n-1)/2;
                            end


                            temp4=(10^(0.05*Ap))+1;
                            temp5=(10^(0.05*Ap))-1;

                            A=(1/(2*n))*log(temp4/temp5);


                            temp=0;
                            temp1=0;

                            for m=0:M  
                                temp=((-1)^m)*(q^(m^2+m))*sinh((2*m+1)*A)+temp;
                                if m>0
                                temp1=((-1)^m)*(q^(m^2))*cosh(2*m*A)+temp1;  
                                end
                            end

                            a=(2*(q^(1/4))*temp)/(1+2*temp1);


                            W=sqrt((1+k*(a^2))*(1+((a^2)/k)));


                            for i=1:r
                                if round(n/2)==n/2
                                    Muo=i-0.5;
                                else
                                    Muo=i;
                                end

                            temp=0;
                            temp1=0;

                            for m=0:M  
                                temp=((-1)^m)*(q^(m^2+m))*sin((2*m+1)*pi*Muo/n)+temp;
                                if m>0
                                temp1=((-1)^m)*(q^(m^2))*cos(2*m*pi*Muo/n)+temp1;  
                                end
                            end

                            b=(2*(q^(1/4))*temp)/(1+2*temp1);    

                            Rad(i)=b;
                            V(i)=sqrt((1-k*(Rad(i)^2))*(1-(Rad(i)^2/k)));

                            a0(i)=1/(Rad(i)^2);

                            temp6=(a*V(i))^2+(Rad(i)*W)^2;
                            temp7=(1+(a^2)*(Rad(i)^2))^2;

                            b0(i)=temp6/temp7;

                            temp8=2*a*V(i);
                            temp9=1+(a^2)*(Rad(i)^2);

                            b1(i)=temp8/temp9;
                            end

                            temp10=1;

                            if round(n/2)==n/2
                                for i=1:r
                                    temp10=(b0(i)/a0(i))*temp10;
                                end
                                H0=10^(-0.05*Ap)*temp10;    
                            else
                                for i=1:r
                                    temp10=(b0(i)/a0(i))*temp10;
                                end
                                H0=a*temp10;
                            end 



                            s = tf('s');

                            temp11=1;

                            for i=1:r
                            temp11=[s^2+a0(i)]/[s^2+b1(i)*s+b0(i)]*temp11;
                            end


                            if round(n/2)==n/2
                                D0=1;
                            else
                                D0=s+a;
                            end


                            HN=(H0/D0)*temp11;
                            
                            case 'optimization'
 
                            kp=sqrt(1-(k^2));
                            temp=sqrt(kp);
                            q0=0.5*(1-temp)/(1+temp);
                            q=q0+2*(q0^5)+15*(q0^9)+150*(q0^13);


                            temp3=log10(16*D)/(log10(1/q));
                            n=ceil(temp3);


                            
                            
                                switch lower(Type)
                                   case {'lowpass'}
                                        if round(n/2)==n/2
                                            n=n;
                                        else
                                            n=(n+1);
                                        end                                      
                                    Initial_Filter_Order=n;
                                    weight1=1;
                                    weight2=eps_p/eps_a;
                                    weight3=eps_p/eps_a;    
                                    M_First=1;
                                    M_Second=0;
                                    M_Third=0;     
                                    edges(3)=edges(2);
                                    edges(4)=edges(2);

                                   case 'highpass'
                                        if round(n/2)==n/2
                                            n=n;
                                        else
                                            n=(n+1);
                                        end                                           
                                    Initial_Filter_Order=n;
                                    
                                    weight1=eps_p/eps_a;
                                    weight2=1;
                                    weight3=1;    
                                    M_First=0;
                                    M_Second=1;
                                    M_Third=1;
                                    edges(3)=edges(2);
                                    edges(4)=edges(2);

                                   case 'bandpass'
                                    Initial_Filter_Order=2*n;
                                    weight1=eps_p/eps_a;
                                    weight2=1;
                                    weight3=eps_p/eps_a;    
                                    M_First=0;
                                    M_Second=1;
                                    M_Third=0;

                                   case 'bandstop'
                                    Initial_Filter_Order=2*n;
                                    weight1=1;
                                    weight2=eps_p/eps_a;
                                    weight3=1;  
                                    M_First=1;
                                    M_Second=0;
                                    M_Third=1;                                    
                                end  

                        if isempty(Filter_Order)
                           N=Initial_Filter_Order;
                        else
                           N=Filter_Order;
                        end
                                                             
                                        
                                        J=N/2;
                                        Number_of_variables=4*J+1;


                                    for iteration=1:Number_of_Iterations
                                        
                                        p=2;
                                        index=0;


                                            
                                        for j=1:J
                                            x0_Cof(j+index:j+index+3)=random_stable_initial_points;
                                            index=index+3;
                                        end
                                        x0=[x0_Cof 1]';
                                        

                                                                            

                                      Number_of_samples=20*Number_of_variables;
                                      W0=[edges(1)+(edges(3)-edges(2))+((ws/2)-edges(4))]/[Number_of_samples+1-3];
                                      m1=ceil((edges(1)/W0)+0.5);
                                      m2=ceil(((edges(3)-edges(2))/W0)+0.5);
                                      m3=Number_of_samples-(m1+m2);
                                      w=[linspace(0,edges(1),m1) edges(1) linspace(edges(2),edges(3),m2) edges(3) linspace(edges(4),ws/2,m3)];


                                    L=length(w);


                                    for kk=2:100


                                    switch lower(Optimization_Method)

                                           case {'fminunc'}
                                             options = optimset('GradObj','on');
                                             [xs,fval,exitflag,output] = fminunc(@myfun_dig_filter,x0,options);
                                           case 'bfgs'
                                             [xs,fs,k] = bfgs('f_dig_filter','g_dig_filter',x0,eps2);
                                           case 'dfp'
                                             [xs,fs,k] = dfp('f_dig_filter','g_dig_filter',x0,eps2);
                                            
                                    end



                                    x0=xs;
                                    x=xs;


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



                                    E_hat(kk)=max(abs(e));

                                    if abs(E_hat(kk)-E_hat(kk-1))<eps1
                                        break
                                    else
                                        p=Mo*p;
                                    end


                                    end


                                    temp_num=[];
                                    temp_den=[];

                                    if J==1
                                    Numerator_temp=x(5)*[1,x(2),x(1)];
                                    Denominator_temp=[1,x(4),x(3)];    

                                    elseif J==2
                                    Numerator_temp=x(9)*conv([1,x(2),x(1)],[1,x(6),x(5)]);
                                    Denominator_temp=conv([1,x(4),x(3)],[1,x(8),x(7)]);   

                                    elseif J>=3

                                        temp_num=conv([1,x(2),x(1)],[1,x(6),x(5)]);
                                        temp_den=conv([1,x(4),x(3)],[1,x(8),x(7)]);    

                                        for j=9:4:4*J
                                            temp_num=conv(temp_num,[1,x(j+1),x(j)]);
                                            temp_den=conv(temp_den,[1,x(j+3),x(j+2)]);
                                        end

                                        Numerator_temp=x(4*J+1)*temp_num;
                                        Denominator_temp=temp_den;

                                    end


                                    [h,ww] =freqz(Numerator_temp,Denominator_temp,2048);
                                    w_denormalized=ww*ws/(2*pi);



                                    switch lower(Type)
                                        case 'lowpass'    

                                                Index_1=find(w_denormalized<=wp1);
                                                Index_2=find(w_denormalized>=wa1);

                                                Actual_Ripple_Passband_Max=max(20*log10(abs(h(Index_1))));
                                                Actual_Ripple_Passband_Min=min(20*log10(abs(h(Index_1))));
                                                Actual_Attenuation_Stopband(iteration)=abs(max(20*log10(abs(h(Index_2)))));

                                                Actual_Ripple_Passband(iteration)=Actual_Ripple_Passband_Max-Actual_Ripple_Passband_Min;

                                        case 'highpass' 

                                                Index_1=find(w_denormalized<=wa1);
                                                Index_2=find(w_denormalized>=wp1);


                                                Actual_Ripple_Passband_Max=max(20*log10(abs(h(Index_2))));
                                                Actual_Ripple_Passband_Min=min(20*log10(abs(h(Index_2))));
                                                Actual_Attenuation_Stopband(iteration)=abs(max(20*log10(abs(h(Index_1)))));                

                                                Actual_Ripple_Passband(iteration)=Actual_Ripple_Passband_Max-Actual_Ripple_Passband_Min;        

                                        case 'bandpass'

                                                Index_1=find(w_denormalized<=edges(1));
                                                Index_2=find(w_denormalized>=edges(4));
                                                Index_3=find(w_denormalized<=edges(3) & w_denormalized>=edges(2));

                                                Actual_Attenuation_First_Stopband=max(20*log10(abs(h(Index_1))));
                                                Actual_Attenuation_First_Secondband=max(20*log10(abs(h(Index_2))));
                                                Actual_Ripple_Passband_Max=max(20*log10(abs(h(Index_3))));
                                                Actual_Ripple_Passband_Min=min(20*log10(abs(h(Index_3))));

                                                Actual_Attenuation_Stopband(iteration)=min(abs(Actual_Attenuation_First_Stopband),abs(Actual_Attenuation_First_Secondband));
                                                Actual_Ripple_Passband(iteration)=Actual_Ripple_Passband_Max-Actual_Ripple_Passband_Min;

                                        case 'bandstop'

                                                Index_1=find(w_denormalized<=wp1);
                                                Index_3=find(w_denormalized>=wp2);
                                                Index_2=find(w_denormalized<=wa2 & w_denormalized>=wa1);


                                                Actual_Ripple_Passband_Max_First_Passband=max(20*log10(abs(h(Index_1))));
                                                Actual_Ripple_Passband_Min_First_Passband=min(20*log10(abs(h(Index_1))));            
                                                Actual_Attenuation_Stopband(iteration)=abs(max(20*log10(abs(h(Index_2)))));
                                                Actual_Ripple_Passband_Max_Second_Passband=max(20*log10(abs(h(Index_3))));
                                                Actual_Ripple_Passband_Min_Second_Passband=min(20*log10(abs(h(Index_3))));


                                                Actual_Ripple_Passband_First_Band=Actual_Ripple_Passband_Max_First_Passband-Actual_Ripple_Passband_Min_First_Passband;
                                                Actual_Ripple_Passband_Second_Band=Actual_Ripple_Passband_Max_Second_Passband-Actual_Ripple_Passband_Min_Second_Passband;            
                                                Actual_Ripple_Passband(iteration)=max(abs(Actual_Ripple_Passband_First_Band),abs(Actual_Ripple_Passband_Second_Band));
                                    end

                                    Numerator_Book(iteration,:)=Numerator_temp;
                                    Denominator_Book(iteration,:)=Denominator_temp;


                                    if Actual_Attenuation_Stopband(iteration)>=Aa & Actual_Ripple_Passband(iteration)<=Ap
                                        Numerator=Numerator_Book(iteration,:);
                                        Denominator=Denominator_Book(iteration,:);
                                        display('A good solution was found in this iteration')
                                        break

                                    else
                                        display('A good solution was not achieved in this iteration')
                                        if iteration==Number_of_Iterations
                                                [xx,yy]=max(Actual_Attenuation_Stopband);
                                                Numerator=Numerator_Book(yy,:);
                                                Denominator=Denominator_Book(yy,:);
                                        end

                                    end



                                    end 
                                    
                                    flag_opt=1;

                                        for j=4:4:4*J
                                            temp_roots=roots([1,x(j),x(j-1)]);

                                            if abs(temp_roots(1))>=1
                                                temp_roots_stabe(1)=1/temp_roots(1);
                                                x(4*J+1)=x(4*J+1)*temp_roots_stabe(1);
                                            else
                                                temp_roots_stabe(1)=temp_roots(1);      
                                            end

                                            if abs(temp_roots(2))>=1
                                                temp_roots_stabe(2)=1/temp_roots(2);
                                                x(4*J+1)=x(4*J+1)*temp_roots_stabe(2);          
                                            else
                                                temp_roots_stabe(2)=temp_roots(2);
                                            end

                                            temp_poly=poly([temp_roots_stabe(1),temp_roots_stabe(2)]);
                                            x(j)=temp_poly(2);
                                            x(j-1)=temp_poly(3);
                                        end


                                        if J==1
                                        Numerator=x(5)*[1,x(2),x(1)];
                                        Denominator=[1,x(4),x(3)];    

                                        elseif J==2
                                        Numerator=x(9)*conv([1,x(2),x(1)],[1,x(6),x(5)]);
                                        Denominator=conv([1,x(4),x(3)],[1,x(8),x(7)]);   

                                        elseif J>=3

                                            temp_num=conv([1,x(2),x(1)],[1,x(6),x(5)]);
                                            temp_den=conv([1,x(4),x(3)],[1,x(8),x(7)]);    

                                            for j=9:4:4*J
                                                temp_num=conv(temp_num,[1,x(j+1),x(j)]);
                                                temp_den=conv(temp_den,[1,x(j+3),x(j+2)]);
                                            end

                                            Numerator=x(4*J+1)*temp_num;
                                            Denominator=temp_den;

                                        end                                    
                            
                end
                
                
                if flag_opt==1
                    
                %%%%%%% Amplitude and Phase Response %%%%%%%%%%%%%%%    
                [h,ww] =freqz(Numerator,Denominator,2048);
                w_denormalized=ww*ws/(2*pi);
                plot(w_denormalized,20*log10(abs(h)))  
                
                grid on
                
                title('Amplitude Response(db)')
                xlabel('W, rad/s')       

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                else
                Num=HN.num{1};
                Den=HN.den{1};


                switch lower(Type)
                   case {'lowpass'}
                        fun=landa*tf([1,0],1);
                        temp14=0;
                        temp15=0;

                        for i=1:n+1
                        temp14=Num(i)*fun^(n+1-i)+temp14;
                        temp15=Den(i)*fun^(n+1-i)+temp15;
                        end
                   case 'highpass'
                        fun=landa*tf(1,[1,0]);
                        temp14=0;
                        temp15=0;

                        for i=1:n+1
                        temp14=Num(i)*fun^(n+1-i)+temp14;
                        temp15=Den(i)*fun^(n+1-i)+temp15;
                        end        
                   case 'bandpass'
                        fun=(1/B)*tf([1,0,w0^2],[1,0]);
                        temp14=0;
                        temp15=0;

                        for i=1:n+1
                        temp14=Num(i)*fun^(n+1-i)+temp14;
                        temp15=Den(i)*fun^(n+1-i)+temp15;
                        end        
                   case 'bandstop'
                        fun_temp1=(B)*tf([1,0],1);
                        fun_temp2=tf([1,0,w0^2],1);
                        temp14=0;
                        temp15=0;

                        for i=1:n+1
                        temp14=Num(i)*fun_temp1^(n+1-i)*fun_temp2^(i-1)+temp14;
                        temp15=Den(i)*fun_temp1^(n+1-i)*fun_temp2^(i-1)+temp15;
                        end        
                end


                T_HN=temp14/temp15;


                T_Num_Double=T_HN.num{1};
                T_Den_Double=T_HN.den{1};

                fun2=(2/T)*tf([1,-1],1,T);
                fun3=tf([1,1],1,T);


                switch lower(Type)
                   case {'lowpass'}

                    T_Num_Double_Modified=T_Num_Double(1:n+1);
                    T_Den_Double_Modified=T_Den_Double(1:n+1);
                        temp12=0;
                        temp13=0;

                        for i=1:n+1
                            temp12=T_Num_Double_Modified(i)*fun2^(n+1-i)*fun3^(i-1)+temp12;
                            temp13=T_Den_Double_Modified(i)*fun2^(n+1-i)*fun3^(i-1)+temp13;
                        end

                    case 'highpass'

                    T_Num_Double_Modified=T_Num_Double(1:n+1);
                    T_Den_Double_Modified=T_Den_Double(1:n+1);
                        temp12=0;
                        temp13=0;

                        for i=1:n+1
                            temp12=T_Num_Double_Modified(i)*fun2^(n+1-i)*fun3^(i-1)+temp12;
                            temp13=T_Den_Double_Modified(i)*fun2^(n+1-i)*fun3^(i-1)+temp13;
                        end   

                    case 'bandpass'

                    T_Num_Double_Modified=T_Num_Double(1:2*n+1);
                    T_Den_Double_Modified=T_Den_Double(1:2*n+1);
                        temp12=0;
                        temp13=0;

                        for i=1:2*n+1
                            temp12=T_Num_Double_Modified(i)*fun2^(2*n+1-i)*fun3^(i-1)+temp12;
                            temp13=T_Den_Double_Modified(i)*fun2^(2*n+1-i)*fun3^(i-1)+temp13;
                        end    

                   case 'bandstop'

                    T_Num_Double_Modified=T_Num_Double(1:2*n+1);
                    T_Den_Double_Modified=T_Den_Double(1:2*n+1);
                        temp12=0;
                        temp13=0;

                        for i=1:2*n+1
                            temp12=T_Num_Double_Modified(i)*fun2^(2*n+1-i)*fun3^(i-1)+temp12;
                            temp13=T_Den_Double_Modified(i)*fun2^(2*n+1-i)*fun3^(i-1)+temp13;
                        end   

                end


                HN_Modified=tf(T_Num_Double_Modified,T_Den_Double_Modified);
                HN_Bilinear=temp12/temp13;


                Num_Bilinear=HN_Bilinear.num{1};
                Den_Bilinear=HN_Bilinear.den{1};

                Numerator=Num_Bilinear/Den_Bilinear(1);
                Denominator=Den_Bilinear/Den_Bilinear(1);

                %%%%%%% Amplitude and Phase Response %%%%%%%%%%%%%%%
                fs=1/T;
                [hh,ff]=freqz(Num_Bilinear,Den_Bilinear,2048,fs);
                figure,plot(ff*2*pi,20*log10(abs(hh)))
                grid on
                
                title('Amplitude Response(db)')
                xlabel('W, rad/s')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
                




    case {'fir'}

    switch lower(Type)
            case {'lowpass'}
                 wp1=edges(1);
                 wa1=edges(2);
                 wp1_normalized=2*pi*wp1/ws;
                 wa1_normalized=2*pi*wa1/ws;
            case {'highpass'}
                 wp1=edges(2);
                 wa1=edges(1);
                 wp1_normalized=2*pi*wp1/ws;
                 wa1_normalized=2*pi*wa1/ws;                 
            case 'bandpass'
                 wa1=edges(1);
                 wp1=edges(2);
                 wp2=edges(3);                               
                 wa2=edges(4);  
                 wp1_normalized=2*pi*wp1/ws;
                 wa1_normalized=2*pi*wa1/ws;
                 wp2_normalized=2*pi*wp2/ws;
                 wa2_normalized=2*pi*wa2/ws;                 
            case 'bandstop'
                 wp1=edges(1);
                 wa1=edges(2); 
                 wa2=edges(3);
                 wp2=edges(4);
                 wp1_normalized=2*pi*wp1/ws;
                 wa1_normalized=2*pi*wa1/ws;
                 wp2_normalized=2*pi*wp2/ws;
                 wa2_normalized=2*pi*wa2/ws;

    end

                    
        switch lower(Method)
            case {'kaiser'}

                wc=(wa1+wp1)/2;

                %%%%%%%%%%%% Filter Design %%%%%%%%%%%%%%%%%%%%%%%%%%
                eps_p=[10^(0.05*Ap)-1]/[10^(0.05*Ap)+1];
                eps_a=10^(-0.05*Aa);

                eps=min(eps_p,eps_a);

                Actual_Ap=20*log10((1+eps)/(1-eps));
                Actual_Aa=-20*log10(eps);


                if Actual_Aa<=21
                    alpha=0;
                elseif Actual_Aa<=50 & Actual_Aa>21;
                    alpha=0.5842*((Actual_Aa-21)^0.4)+0.07886*(Actual_Aa-21);
                elseif Actual_Aa>50
                    alpha=0.1102*(Actual_Aa-8.7);
                end


                if Actual_Aa<=21
                    D=0.9222;
                elseif Actual_Aa>21
                    D=(Actual_Aa-7.95)/14.36;
                end


                    switch lower(Type)
                           case {'lowpass'}
                               Bt=wa1-wp1;
                           case {'highpass'}
                               Bt=wp1-wa1;               
                           case 'bandpass'
                               Bt=min(wp1-wa1,wa2-wp2);
                           case 'bandstop'
                               Bt=min(wa1-wp1,wp2-wa2);
                    end


                NN=ceil((ws*D/Bt)+1);


                if  NN/2==floor(NN/2)
                    N=NN+1;
                else
                    N=NN;
                end

                N=N+2;
                M=(N-1)/2;

                for n=-M:M
                    beta=alpha*sqrt(1-((n/M)^2));


                    x=beta;
                    I=10;
                    temp=0;

                    for k=1:I
                    temp_f=1/factorial(k);
                    temp_x=(x/2)^k;
                    temp3=(temp_f*temp_x)^2;
                    temp=temp+temp3;
                    end
                    temp1=temp+1;
                    
                    
                    x=alpha;
                    I=10;
                    temp=0;

                    for k=1:I
                    temp_f=1/factorial(k);
                    temp_x=(x/2)^k;
                    temp3=(temp_f*temp_x)^2;
                    temp=temp+temp3;
                    end
                    temp2=temp+1;


                    switch lower(Type)
                           case {'lowpass'}
                                     if n==0
                                         h(n+M+1)=(2*wc/ws);
                                     else
                                         h(n+M+1)=sin(wc*n*T)/(n*pi);
                                     end

                           case 'highpass'
                                    if n==0
                                        h(n+M+1)=1-(2*wc/ws);
                                    else
                                        h(n+M+1)=-sin(wc*n*T)/(n*pi);
                                    end
                           case 'bandpass'
                                    Bt=min(wp1-wa1,wa2-wp2);
                                    wc1=wp1-Bt/2;
                                    wc2=wp2+Bt/2;

                                    if n==0
                                        h(n+M+1)=(2/ws)*(wc2-wc1);
                                    else
                                        h(n+M+1)=(sin(wc2*n*T)-sin(wc1*n*T))/(n*pi);
                                    end              
                           case 'bandstop'    
                                    Bt=min(wa1-wp1,wp2-wa2);
                                    wc1=wp1+(Bt/2);
                                    wc2=wp2-(Bt/2);    

                                    if n==0
                                        h(n+M+1)=(2/ws)*(wc1-wc2)+1;
                                    else
                                        h(n+M+1)=(sin(wc1*n*T)-sin(wc2*n*T))/(n*pi);
                                    end
                    end

                    w(n+M+1)=temp1/temp2;
                end

                final_filter=h.*w;
                filter_order=N;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


                %%%%%%% Amplitude and Phase Response %%%%%%%%%%%%%%%
                fs=1/T;
                [HH,ff]=freqz(final_filter,1,2048,fs);
                plot(ff*2*pi,20*log10(abs(HH)))
                grid on

                title('Amplitude Response(db)')
                xlabel('W, rad/s')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                Numerator=final_filter;
                Denominator=1;
                
            case 'optimization'
                
eps_a=10^(-Aa/20);

temp=10^(Ap/20);
eps_p=(temp-1)/(temp+1);

switch lower(Type)
    case 'lowpass'  
            wa=wa1_normalized;
            wp=wp1_normalized;


            N=N_Dig_Filter(wa,wp,eps_p,eps_a);
            Initial_N=N;
    case 'highpass'  
            wa=wa1_normalized;
            wp=wp1_normalized;


            N=N_Dig_Filter(wa,wp,eps_p,eps_a);
            Initial_N=N;            

     case 'bandpass' 

            for i=1:2
                if i==1
                    wa=wa1_normalized;
                    wp=wp1_normalized;
                    N(i)=N_Dig_Filter(wa,wp,eps_p,eps_a);
                else 
                    wa=wa2_normalized;
                    wp=wp2_normalized;
                    N(i)=N_Dig_Filter(wa,wp,eps_p,eps_a);
                end
            end

            Initial_N=max(N);
            
     case 'bandstop' 

            for i=1:2
                if i==1
                    wa=wa1_normalized;
                    wp=wp1_normalized;
                    N(i)=N_Dig_Filter(wa,wp,eps_p,eps_a)
                else 
                    wa=wa2_normalized;
                    wp=wp2_normalized;
                    N(i)=N_Dig_Filter(wa,wp,eps_p,eps_a)
                end
            end

            Initial_N=max(N);            
end

if round(Initial_N/2)==Initial_N/2
    Initial_N=Initial_N+1;
end


switch lower(Type)
    case 'lowpass'    
         Weight=[1 eps_p/eps_a];
         f=[0 wp1_normalized/pi wa1_normalized/pi 1];
         a=[1 1 0 0];
         
            N=Initial_N;

            b_initial=firpm(N-1,f,a,Weight);

            [h,w] = freqz(b_initial,1,2048);
            w_denormalized=w*ws/(2*pi);

            Index_1=find(w_denormalized<=wp1);
            Index_2=find(w_denormalized>=wa1);

            Actual_Ripple_Passband_Max(1)=max(20*log10(abs(h(Index_1))));
            Actual_Ripple_Passband_Min(1)=min(20*log10(abs(h(Index_1))));
            Actual_Attenuation_Stopband(1)=abs(max(20*log10(abs(h(Index_2)))));

            Actual_Ripple_Passband(1)=Actual_Ripple_Passband_Max(1)-Actual_Ripple_Passband_Min(1);

            index=1;

            if Actual_Attenuation_Stopband(1)>Aa & Actual_Ripple_Passband(1)<Ap
                while Actual_Attenuation_Stopband(index)>Aa & Actual_Ripple_Passband(index)<Ap
                N=N-2;
                temp_vector=firpm(N-1,f,a,Weight);
                index=index+1;

                [h,w] = freqz(temp_vector,1,2048);
                w_denormalized=w*ws/(2*pi);

                Index_1=find(w_denormalized<=wp1);
                Index_2=find(w_denormalized>=wa1);

                Actual_Ripple_Passband_Max(index)=max(20*log10(abs(h(Index_1))));
                Actual_Ripple_Passband_Min(index)=min(20*log10(abs(h(Index_1))));
                Actual_Attenuation_Stopband(index)=abs(max(20*log10(abs(h(Index_2)))));

                Actual_Ripple_Passband(index)=Actual_Ripple_Passband_Max(index)-Actual_Ripple_Passband_Min(index);
                end
                N_final=N+2;
                b_final=firpm(N_final-1,f,a,Weight);
                Actual_Ripple_Passband_Final=Actual_Ripple_Passband(index-1);
                Actual_Attenuation_Stopband_Final=Actual_Attenuation_Stopband(index-1);

            elseif Actual_Attenuation_Stopband(1)<Aa | Actual_Ripple_Passband(1)>Ap
                while Actual_Attenuation_Stopband(index)<Aa | Actual_Ripple_Passband(index)>Ap
                N=N+2;
                temp_vector=firpm(N-1,f,a,Weight);
                index=index+1;

                [h,w] = freqz(temp_vector,1,2048);
                w_denormalized=w*ws/(2*pi);

                Index_1=find(w_denormalized<=wp1);
                Index_2=find(w_denormalized>=wa1);

                Actual_Ripple_Passband_Max(index)=max(20*log10(abs(h(Index_1))));
                Actual_Ripple_Passband_Min(index)=min(20*log10(abs(h(Index_1))));
                Actual_Attenuation_Stopband(index)=abs(max(20*log10(abs(h(Index_2)))));

                Actual_Ripple_Passband(index)=Actual_Ripple_Passband_Max(index)-Actual_Ripple_Passband_Min(index);
                end
                N_final=N;
                b_final=firpm(N_final-1,f,a,Weight);
                Actual_Ripple_Passband_Final=Actual_Ripple_Passband(index-1);
                Actual_Attenuation_Stopband_Final=Actual_Attenuation_Stopband(index-1);    

            end                  
         
    case 'highpass'    
         Weight=[eps_p/eps_a 1];
         f=[0 wa1_normalized/pi wp1_normalized/pi 1];
         a=[0 0 1 1];       
         
                N=Initial_N;

                b_initial=firpm(N-1,f,a,Weight);

                [h,w] = freqz(b_initial,1,2048);
                w_denormalized=w*ws/(2*pi);

                Index_1=find(w_denormalized<=wa1);
                Index_2=find(w_denormalized>=wp1);
                
                
                Actual_Ripple_Passband_Max(1)=max(20*log10(abs(h(Index_2))));
                Actual_Ripple_Passband_Min(1)=min(20*log10(abs(h(Index_2))));
                Actual_Attenuation_Stopband(1)=abs(max(20*log10(abs(h(Index_1)))));                


                Actual_Ripple_Passband(1)=Actual_Ripple_Passband_Max(1)-Actual_Ripple_Passband_Min(1);

                index=1;

                if Actual_Attenuation_Stopband(1)>Aa & Actual_Ripple_Passband(1)<Ap
                    while Actual_Attenuation_Stopband(index)>Aa & Actual_Ripple_Passband(index)<Ap
                    N=N-2;
                    temp_vector=firpm(N-1,f,a,Weight);
                    index=index+1;

                    [h,w] = freqz(temp_vector,1,2048);
                    w_denormalized=w*ws/(2*pi);

                    Index_1=find(w_denormalized<=wa1);
                    Index_2=find(w_denormalized>=wp1);

                    Actual_Ripple_Passband_Max(index)=max(20*log10(abs(h(Index_2))));
                    Actual_Ripple_Passband_Min(index)=min(20*log10(abs(h(Index_2))));
                    Actual_Attenuation_Stopband(index)=abs(max(20*log10(abs(h(Index_1)))));   

                    Actual_Ripple_Passband(index)=Actual_Ripple_Passband_Max(index)-Actual_Ripple_Passband_Min(index);
                    end
                    N_final=N+2;
                    b_final=firpm(N_final-1,f,a,Weight);
                    Actual_Ripple_Passband_Final=Actual_Ripple_Passband(index-1);
                    Actual_Attenuation_Stopband_Final=Actual_Attenuation_Stopband(index-1);

                elseif Actual_Attenuation_Stopband(1)<Aa | Actual_Ripple_Passband(1)>Ap
                    while Actual_Attenuation_Stopband(index)<Aa | Actual_Ripple_Passband(index)>Ap
                    N=N+2;
                    temp_vector=firpm(N-1,f,a,Weight);
                    index=index+1;

                    [h,w] = freqz(temp_vector,1,2048);
                    w_denormalized=w*ws/(2*pi);

                    Index_1=find(w_denormalized<=wa1);
                    Index_2=find(w_denormalized>=wp1);

                    Actual_Ripple_Passband_Max(index)=max(20*log10(abs(h(Index_2))));
                    Actual_Ripple_Passband_Min(index)=min(20*log10(abs(h(Index_2))));
                    Actual_Attenuation_Stopband(index)=abs(max(20*log10(abs(h(Index_1)))));   

                    Actual_Ripple_Passband(index)=Actual_Ripple_Passband_Max(index)-Actual_Ripple_Passband_Min(index);
                    end
                    N_final=N;
                    b_final=firpm(N_final-1,f,a,Weight);
                    Actual_Ripple_Passband_Final=Actual_Ripple_Passband(index-1);
                    Actual_Attenuation_Stopband_Final=Actual_Attenuation_Stopband(index-1);    

                end                           
         
    case 'bandpass'
         Weight=[eps_p/eps_a 1 eps_p/eps_a];
         f=[0 wa1_normalized/pi wp1_normalized/pi wp2_normalized/pi wa2_normalized/pi 1];
         a=[0 0 1 1 0 0];
         
            N=Initial_N;

            b_initial=firpm(N-1,f,a,Weight);

            [h,w] = freqz(b_initial,1,2048);
            w_denormalized=w*ws/(2*pi);

            Index_1=find(w_denormalized<=wa1);
            Index_2=find(w_denormalized>=wa2);
            Index_3=find(w_denormalized<=wp2 & w_denormalized>=wp1);
            
            
            Actual_Attenuation_First_Stopband=max(20*log10(abs(h(Index_1))));
            Actual_Attenuation_First_Secondband=max(20*log10(abs(h(Index_2))));
            Actual_Ripple_Passband_Max(1)=max(20*log10(abs(h(Index_3))));
            Actual_Ripple_Passband_Min(1)=min(20*log10(abs(h(Index_3))));

            Actual_Attenuation_Stopband(1)=min(abs(Actual_Attenuation_First_Stopband),abs(Actual_Attenuation_First_Secondband));
            Actual_Ripple_Passband(1)=Actual_Ripple_Passband_Max(1)-Actual_Ripple_Passband_Min(1);
           

            index=1;

            if Actual_Attenuation_Stopband(1)>Aa & Actual_Ripple_Passband(1)<Ap
                while Actual_Attenuation_Stopband(index)>Aa & Actual_Ripple_Passband(index)<Ap
                N=N-2;
                temp_vector=firpm(N-1,f,a,Weight);
                index=index+1;

                [h,w] = freqz(temp_vector,1,2048);
                w_denormalized=w*ws/(2*pi);

                Index_1=find(w_denormalized<=wa1);
                Index_2=find(w_denormalized>=wa2);
                Index_3=find(w_denormalized<=wp2 & w_denormalized>=wp1);

                Actual_Attenuation_First_Stopband=max(20*log10(abs(h(Index_1))));
                Actual_Attenuation_First_Secondband=max(20*log10(abs(h(Index_2))));
                Actual_Ripple_Passband_Max(index)=max(20*log10(abs(h(Index_3))));
                Actual_Ripple_Passband_Min(index)=min(20*log10(abs(h(Index_3))));

                Actual_Attenuation_Stopband(index)=min(abs(Actual_Attenuation_First_Stopband),abs(Actual_Attenuation_First_Secondband));
                Actual_Ripple_Passband(index)=Actual_Ripple_Passband_Max(index)-Actual_Ripple_Passband_Min(index);
                end
                N_final=N+2;
                b_final=firpm(N_final-1,f,a,Weight);
                Actual_Ripple_Passband_Final=Actual_Ripple_Passband(index-1);
                Actual_Attenuation_Stopband_Final=Actual_Attenuation_Stopband(index-1);

            elseif Actual_Attenuation_Stopband(1)<Aa | Actual_Ripple_Passband(1)>Ap
                while Actual_Attenuation_Stopband(index)<Aa | Actual_Ripple_Passband(index)>Ap
                N=N+2;
                temp_vector=firpm(N-1,f,a,Weight);
                index=index+1;

                [h,w] = freqz(temp_vector,1,2048);
                w_denormalized=w*ws/(2*pi);

                Index_1=find(w_denormalized<=wa1);
                Index_2=find(w_denormalized>=wa2);
                Index_3=find(w_denormalized<=wp2 & w_denormalized>=wp1);

                Actual_Attenuation_First_Stopband=max(20*log10(abs(h(Index_1))));
                Actual_Attenuation_First_Secondband=max(20*log10(abs(h(Index_2))));
                Actual_Ripple_Passband_Max(index)=max(20*log10(abs(h(Index_3))));
                Actual_Ripple_Passband_Min(index)=min(20*log10(abs(h(Index_3))));

                Actual_Attenuation_Stopband(index)=min(abs(Actual_Attenuation_First_Stopband),abs(Actual_Attenuation_First_Secondband));
                Actual_Ripple_Passband(index)=Actual_Ripple_Passband_Max(index)-Actual_Ripple_Passband_Min(index);
                end
                N_final=N;
                b_final=firpm(N_final-1,f,a,Weight);
                Actual_Ripple_Passband_Final=Actual_Ripple_Passband(index-1);
                Actual_Attenuation_Stopband_Final=Actual_Attenuation_Stopband(index-1);    

            end         
         
    case 'bandstop'
         Weight=[1 eps_p/eps_a 1];
         f=[0 wp1_normalized/pi wa1_normalized/pi wa2_normalized/pi wp2_normalized/pi 1];
         a=[1 1 0 0 1 1];  
         
            N=Initial_N;

            b_initial=firpm(N-1,f,a,Weight);

            [h,w] = freqz(b_initial,1,2048);
            w_denormalized=w*ws/(2*pi);

            Index_1=find(w_denormalized<=wp1);
            Index_3=find(w_denormalized>=wp2);
            Index_2=find(w_denormalized<=wa2 & w_denormalized>=wa1);
              
           
            Actual_Ripple_Passband_Max_First_Passband(1)=max(20*log10(abs(h(Index_1))));
            Actual_Ripple_Passband_Min_First_Passband(1)=min(20*log10(abs(h(Index_1))));            
            Actual_Attenuation_Stopband(1)=abs(max(20*log10(abs(h(Index_2)))));
            Actual_Ripple_Passband_Max_Second_Passband(1)=max(20*log10(abs(h(Index_3))));
            Actual_Ripple_Passband_Min_Second_Passband(1)=min(20*log10(abs(h(Index_3))));


            Actual_Ripple_Passband_First_Band(1)=Actual_Ripple_Passband_Max_First_Passband(1)-Actual_Ripple_Passband_Min_First_Passband(1);
            Actual_Ripple_Passband_Second_Band(1)=Actual_Ripple_Passband_Max_Second_Passband(1)-Actual_Ripple_Passband_Min_Second_Passband(1);            
            Actual_Ripple_Passband(1)=max(abs(Actual_Ripple_Passband_First_Band(1)),abs(Actual_Ripple_Passband_Second_Band(1)));

            index=1;

            if Actual_Attenuation_Stopband(1)>Aa & Actual_Ripple_Passband(1)<Ap
                while Actual_Attenuation_Stopband(index)>Aa & Actual_Ripple_Passband(index)<Ap
                N=N-2;
                temp_vector=firpm(N-1,f,a,Weight);
                index=index+1;

                [h,w] = freqz(temp_vector,1,2048);
                w_denormalized=w*ws/(2*pi);

                Index_1=find(w_denormalized<=wp1);
                Index_3=find(w_denormalized>=wp2);
                Index_2=find(w_denormalized<=wa2 & w_denormalized>=wa1);

                Actual_Ripple_Passband_Max_First_Passband(index)=max(20*log10(abs(h(Index_1))));
                Actual_Ripple_Passband_Min_First_Passband(index)=min(20*log10(abs(h(Index_1))));            
                Actual_Attenuation_Stopband(index)=abs(max(20*log10(abs(h(Index_2)))));
                Actual_Ripple_Passband_Max_Second_Passband(index)=max(20*log10(abs(h(Index_3))));
                Actual_Ripple_Passband_Min_Second_Passband(index)=min(20*log10(abs(h(Index_3))));


                Actual_Ripple_Passband_First_Band(index)=Actual_Ripple_Passband_Max_First_Passband(index)-Actual_Ripple_Passband_Min_First_Passband(index);
                Actual_Ripple_Passband_Second_Band(index)=Actual_Ripple_Passband_Max_Second_Passband(index)-Actual_Ripple_Passband_Min_Second_Passband(index);            
                Actual_Ripple_Passband(index)=max(abs(Actual_Ripple_Passband_First_Band(index)),abs(Actual_Ripple_Passband_Second_Band(index)));
                end
                N_final=N+2;
                b_final=firpm(N_final-1,f,a,Weight);
                Actual_Ripple_Passband_Final=Actual_Ripple_Passband(index-1);
                Actual_Attenuation_Stopband_Final=Actual_Attenuation_Stopband(index-1);

            elseif Actual_Attenuation_Stopband(1)<Aa | Actual_Ripple_Passband(1)>Ap
                while Actual_Attenuation_Stopband(index)<Aa | Actual_Ripple_Passband(index)>Ap
                N=N+2;
                temp_vector=firpm(N-1,f,a,Weight);
                index=index+1;

                [h,w] = freqz(temp_vector,1,2048);
                w_denormalized=w*ws/(2*pi);

                Index_1=find(w_denormalized<=wp1);
                Index_3=find(w_denormalized>=wp2);
                Index_2=find(w_denormalized<=wa2 & w_denormalized>=wa1);

                Actual_Ripple_Passband_Max_First_Passband(index)=max(20*log10(abs(h(Index_1))));
                Actual_Ripple_Passband_Min_First_Passband(index)=min(20*log10(abs(h(Index_1))));            
                Actual_Attenuation_Stopband(index)=abs(max(20*log10(abs(h(Index_2)))));
                Actual_Ripple_Passband_Max_Second_Passband(index)=max(20*log10(abs(h(Index_3))));
                Actual_Ripple_Passband_Min_Second_Passband(index)=min(20*log10(abs(h(Index_3))));


                Actual_Ripple_Passband_First_Band(index)=Actual_Ripple_Passband_Max_First_Passband(index)-Actual_Ripple_Passband_Min_First_Passband(index);
                Actual_Ripple_Passband_Second_Band(index)=Actual_Ripple_Passband_Max_Second_Passband(index)-Actual_Ripple_Passband_Min_Second_Passband(index);            
                Actual_Ripple_Passband(index)=max(abs(Actual_Ripple_Passband_First_Band(index)),abs(Actual_Ripple_Passband_Second_Band(index)));
                end
                N_final=N;
                b_final=firpm(N_final-1,f,a,Weight);
                Actual_Ripple_Passband_Final=Actual_Ripple_Passband(index-1);
                Actual_Attenuation_Stopband_Final=Actual_Attenuation_Stopband(index-1);    

            end                  
      
end
         

                [h,w] = freqz(b_final,1,2048);
                plot(w*ws/(2*pi),20*log10(abs(h)));
                grid on

                title('Amplitude Response(db)')
                xlabel('W, rad/s')
                Numerator=b_final;
                Denominator=1;
                      
        end

end

clear  global ws T edges Aa Ap weight1 weight2 weight3 m1 m2 m3 w p J Number_of_variables Number_of_samples L M_First M_Second M_Third

else
    Numerator=[];
    Denominator=[];
end