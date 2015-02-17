function plot_sh_order_all(order)

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
    
  figure(1)
  clf;
  
  z_offset = [0 -3 -3 -3 -6 -6 -6 -6 -6];
  y_offset = [0 0 -3 +3 0 -3 +3 6 -6];
  c = ones(30,30);
  
  for o = 1:size(a,3)
        
        h = figure(1);
        [x,y,z] = sph2cart(TH,PH-pi/2,abs(squeeze(a(:,:,o))));
        %clf;
        z = z+z_offset(o);
        y = y+y_offset(o);
        hold on
        surf(x,y,z); hold on;
        %[xo,yo,zo] = sph2cart(0,0,0);
        %[xt,yt,zt] = sph2cart(0,0,1);
        %plot3(linspace(xo,xt,10),linspace(yo,yt,10),linspace(zo,zt,10),'k','Linewidth',1);
        %plot3(xt,yt,zt,'k>','Markersize',14,'Markerfacecolor','k');
        %axis equal;
        
        %grid off
        %set(h,'InvertHardcopy','on')
        
        %axis off
        %set(gca,'position',[0 0 1 1],'units','normalized')
        
        %xlim([-1.4 1.4])
        %ylim([-1.4 1.4])
        %zlim([-1.4 1.4])
        %set(h,'paperunits','centimeters','paperposition',[1 1 12 7])
        %saveas(h,sprintf('../thesis/images/sh/base/sh_order%i',o),'epsc');

  end
         
view(85,10);
        xlabel('X-Axis');
        ylabel('Y-Axis');
        zlabel('Z-Axis');
        %grid on;
        axis off
  colorbar;

[Ymn,THETA,PHI,X,Y,Z]=spharm(2,0,a(l,1,:),1);  
end

