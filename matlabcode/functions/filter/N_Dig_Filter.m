

function N=N_Dig_Filter(wa,wp,eps_p,eps_a)

            B=abs(wa-wp)/(2*pi);
            D=[0.005309*(log10(eps_p))^2+0.07114*log10(eps_p)-0.4761]*log10(eps_a)-[0.00266*(log10(eps_p))^2+0.5941*log10(eps_p)+0.4278];
            F=0.51244*(log10(eps_p)-log10(eps_a))+11.012;
            
            temp=(D-F*(B^2))/B;
            N=round(temp+1.5);