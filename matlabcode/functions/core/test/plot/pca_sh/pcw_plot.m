function pcw_plot(angles,W,mode,max_pc,sh_order,reg,db,sub,mesh_mode,type)

% Input
% mode: plot mode: 0=sphere_plot; 1=radial_plot; 2=point_plot
% mesh_mode: use linespace or extact database locations

% Initialization 
% 

if (mesh_mode == 0)
    N = 720;
    th = linspace(0,360,N);
    ph = linspace(0,180,N);
    
    [TH,PH] = meshgrid(th/180*pi,ph/180*pi);
elseif (mesh_mode ==1)
    [TH,PH] = meshgrid(angles(:,1)/180*pi,angles(:,2)/180*pi);
end

for pc=1:max_pc   
    % ZI = griddata(angles(:,1),angles(:,2),pc_weights_rc(:,1),Thetas,Phis);
    W_PC = squeeze(W(:,pc));
    W_G = TriScatteredInterp(angles(:,1)/180*pi,angles(:,2)/180*pi,W_PC); % old    
    %W_G = scatteredInterpolant(angles(:,1)/180*pi,angles(:,2)/180*pi,W_PC);% new
    ZI(pc,:,:) = W_G(TH,PH);
    mn(pc) = min(W_PC); mx(pc) = max(W_PC);
end


if mode == 0
    sphere_plot(TH,PH,ZI,max_pc,sh_order,reg,db,type,sub,mesh_mode);
elseif mode == 1
    radial_plot(TH,PH,ZI,max_pc,sh_order,reg,db,type,sub,mesh_mode);
elseif mode == 2
    point_plot(angles(:,1)/180*pi,angles(:,2)/180*pi,W,max_pc,sh_order,reg,type,sub,mesh_mode);
end

% st = zeros(size(w,2),size(a,1),size(a,2));
% 
% for pc = 1:size(w,2)    
%     
%     for o = 1:size(a,3)         
%         st(pc,:,:) = squeeze(st(pc,:,:)) + squeeze(w(o,pc)*a(:,:,o));        
%     end
%     [x(pc,:,:),y(pc,:,:),z(pc,:,:)] = sph2cart(TH,PH,abs(squeeze(st(pc,:,:))));
%     mm(pc) = max(max(squeeze(z(pc,:,:))));
%     mn(pc) = min(min(squeeze(z(pc,:,:))));
% end


end

function point_plot(TH,PH,W,max_pc,sh_order,reg,db,type,sub,mesh_mode)


for pc=1:max_pc
    [x,y,z] = sph2cart(TH,PH,abs(squeeze(W(:,pc))));
    ip = W(:,pc)>0;
    in = W(:,pc)<0;
    figure;hold on;
    plot3(x(ip),y(ip),z(ip),'.','Color',[0.7 0.7 0.7]);
    plot3(x(in),y(in),z(in),'.','Color',[0.3 0.3 0.3]);
    zz = zeros(size([x y z]));
    plot3(zz(ip,1), zz(ip,2), zz(ip,3),x,y,z,'Color',[0.7 0.7 0.7]);
    plot3(zz(in,1), zz(in,2), zz(in,3),x,y,z,'Color',[0.3 0.3 0.3]);
%     for i = 1:length(x)
%         plot3(linspace(0,x(i),10),linspace(0,y(i),10),linspace(0,z(i),10));
%     end
%     surf(ccx,ccy,ccz,squeeze(ZI(pc,:,:)));
    title(sprintf('PC %i',pc));
%     caxis([min(mn) max(mx)]);    
%     rotate3d on
    % arrow in front
    [xt,yt,zt] = sph2cart(0,0,1);
    plot3(xt,yt,zt,'k>','Markersize',14,'Markerfacecolor','k');

end

end

function sphere_plot(TH,PH,ZI,max_pc,sh_order,reg,db,type,sub,mesh_mode)

[ccx,ccy,ccz] = sph2cart(TH,PH,ones(size(TH)));
for pc=1:max_pc
    figure(pc)
    clf;
    hold on;
    surf(ccx,ccy,ccz,squeeze(ZI(pc,:,:)),'EdgeAlpha', 0.1);
    %title(sprintf('PC %i',pc));
%     caxis([min(mn) max(mx)]);    
    rotate3d on
    % arrow in front
    [xt,yt,zt] = sph2cart(0,0,1);
    plot3(xt,yt,zt,'k>','Markersize',14,'Markerfacecolor','k');
    view(78,28)
    grid on
    axis equal
    
    colorbar
    if (strcmp(db,'ircam') == 1)        
        switch(pc)
            case 1
        caxis([-300 300]);
            case 2
        caxis([-150 150]);
            case 3
        caxis([-80 80]);
        end
    end
    
     if (strcmp(db,'cipic') == 1)        
         switch(pc)
             case 1
         caxis([-200 200]);
             case 2
         caxis([-100 100]);
             case 3
         caxis([-90 60]);
            case 4
         caxis([-65 65]);
         end
     end
    
    %Axis 
    xlim(gca,[-1 1])
    ylim(gca,[-1 1])
    zlim(gca,[-1 1])
    set(gca, 'XTick', []);
    set(gca, 'YTick', []);
    set(gca, 'ZTick', []);
    set(gca,'color','none')
    set(gca,'box','off');
    axis(gca,'equal')
    axis(gca,'square')
    set(gca,'visible','off')

    set(pc,'paperunits','centimeters','paperposition',[1 1 20 12])
    
    if (strcmp(type,'modeled') ==1)
    saveas(pc,sprintf('../thesis/images/test_pca_sh/pcws_sphere/%s_sub%i_mesh%i_sh_order%i_pc%i_reg%i',db,sub,mesh_mode,sh_order,pc,reg),'epsc');
    else
    saveas(pc,sprintf('../thesis/images/test_pca_sh/pcws_sphere/%s_sub%i_mesh%i_pc%i',db,sub,mesh_mode,pc),'epsc');    
    end
    

end

end

function radial_plot(TH,PH,ZI,max_pc,sh_order,reg,db,type,sub,mesh_mode)

for pc = 1:max_pc
    
    [x(pc,:,:),y(pc,:,:),z(pc,:,:)] = sph2cart(TH,PH,abs(squeeze(ZI(pc,:,:))));
    figure(pc);
    clf;
   % title(sprintf('PC: %d',pc),'Fontsize',14);
    hold on;
    
    pha = zeros(size(squeeze(ZI(pc,:,:))));
   % pha(squeeze(ZI(pc,:,:))>0) = 1;
    %pha(squeeze(ZI(pc,:,:))<0) = -1;
    
    pha(squeeze(ZI(pc,:,:))>0) = 0.7;
    pha(squeeze(ZI(pc,:,:))<0) = 0.3;
    pha = repmat(pha,[1 1 3]);
    
    surf(squeeze(x(pc,:,:)),squeeze(y(pc,:,:)),squeeze(z(pc,:,:)),'CDATA',pha,'CDataMapping','scaled','EdgeAlpha',0.1,'FaceLighting','phong'); hold on;
    %alpha(0.7)
    
    xl = xlim;
    [xo,yo,zo] = sph2cart(0,0,0);
    [xt,yt,zt] = sph2cart(0,0,xl(2)+0.1*xl(2));
    
    plot3(linspace(xo,xt,10),linspace(yo,yt,10),linspace(zo,zt,10),'k','Linewidth',2);
    plot3(xt,yt,zt,'k>','Markersize',14,'Markerfacecolor','k');    
    %axis equal;
    xlabel('Y-Axis');
    ylabel('X-Axis');
    zlabel('Z-Axis');
    grid on;    
    view(62,28)
    set(gca,'visible','on')
    %Save as EPS
    set(pc,'paperunits','centimeters','paperposition',[1 1 20 12])
    
    if (strcmp(type,'modeled') ==1)
    saveas(pc,sprintf('../thesis/images/test_pca_sh/pcws/%s_sub%i_mesh%i_sh_order%i_pc%i_reg%i',db,sub,mesh_mode,sh_order,pc,reg),'epsc');
    else
    saveas(pc,sprintf('../thesis/images/test_pca_sh/pcws/%s_sub%i_mesh%i_pc%i',db,sub,mesh_mode,pc),'epsc');    
    end
        
end

end

