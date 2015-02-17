function plot_sh_order(order)

N = 30;
th = linspace(0,360,N);
ph = linspace(0,180,N);

[TH,PH] = meshgrid(th/180*pi,ph/180*pi);

    
    for l = 1:size(TH,1)
        for m = 1:size(PH,2)
            a(l,m,:) = SHCreateYVec(order,TH(l,m),PH(l,m),'rad');
             %a(l,m,:) = sh_matrix_real(order,TH(l,m),PH(l,m));
        end
    end
    
          
  for o = 1:size(a,3)
        h = figure(o);
        [x,y,z] = sph2cart(TH,PH-pi/2,abs(squeeze(a(:,:,o))));
        clf;
        surf(x,y,z); hold on;
        [xo,yo,zo] = sph2cart(0,0,0);
        [xt,yt,zt] = sph2cart(0,0,1);
        plot3(linspace(xo,xt,10),linspace(yo,yt,10),linspace(zo,zt,10),'k','Linewidth',1);
        plot3(xt,yt,zt,'k>','Markersize',14,'Markerfacecolor','k');
        axis equal;
        view(45,10);
        xlabel('X-Axis');
        ylabel('Y-Axis');
        zlabel('Z-Axis');
        %grid on;
        %grid off
        %set(h,'InvertHardcopy','on')
        %colorbar;
        %axis off
        %set(gca,'position',[0 0 1 1],'units','normalized')
        
        xlim([-1.4 1.4])
        ylim([-1.4 1.4])
        zlim([-1.4 1.4])
        set(h,'paperunits','centimeters','paperposition',[1 1 12 7])
        %saveas(h,sprintf('../thesis/images/sh/base/sh_order%i',o),'epsc');

        
  end
         
    
  

end

