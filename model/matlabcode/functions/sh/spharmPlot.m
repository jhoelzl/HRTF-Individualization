function spharmPlot(L, resolution)
% This function plots base spherical harmonic functions in their real forms
%
% Syntax: 
% spharmPlot(L, resolution)
% spharmPlot(L)
% spharmPlot()
%
% Inputs:% 
% L: degree of the functions, default value = 2;
% resolution: resolution of sphere surface, default value = 500.
%
% Results:
% green regions represent negative values
% red regions represent positive values
%
% Reference: http://en.wikipedia.org/wiki/Spherical_harmonics
% 
% Written by Mengliu Zhao, School of Computing Science, Simon Fraser University
% Date: 2013/May/02

if nargin < 1
	L = 2;
	resolution = 500;
end
if nargin < 2
	resolution = 500;
end

% discretize sphere surface
delta = pi/resolution;
theta = 0:delta:pi; % altitude
phi = 0:2*delta:2*pi; % azimuth
[phi,theta] = meshgrid(phi,theta);

subpos = [3 9 8 7 15 14 13 12 11];
plot_offset = [0 3 10];
order = 2;

figure(20)
clf;
c=0;
for L=0:order
  
figure(20)
% set figure background to white
xx = figure(20);
set(xx,'Color',[1 1 1])
for M = -L:L
    c = c+1;
	% Legendre polynomials
	P_LM = legendre(L,cos(theta(:,1)));
	P_LM = (-1)^(M)*P_LM(abs(M)+1,:)';
	P_LM = repmat(P_LM, [1, size(theta, 1)]);

	% normalization constant
	N_LM = sqrt((2*L+1)/4/pi*factorial(L-abs(M))/factorial(L+abs(M)));
		
	% base spherical harmonic function
	if M>=0
		Y_LM = sqrt(2) * N_LM * P_LM .* cos(M*phi);
	else		
		Y_LM = sqrt(2) * N_LM * P_LM .* sin(abs(M)*phi);
	end
	
	% map to sphere surface	
	r = Y_LM;	
	x = abs(r).*sin(theta).*cos(phi); 
	y = abs(r).*sin(theta).*sin(phi);
	z = abs(r).*cos(theta);

	% visualization
	%subplot(ceil(sqrt(2*L+1)),ceil(sqrt(2*L+1)),M+1+L)
    %subplot(order+1,2*L+1,M+1+L + plot_offset(L+1))
    subplot(order+1,5,subpos(c))
    
    
%     fprintf('Order: %i',L)
%     M+1+L + plot_offset(L+1)
    
	
    [xo,yo,zo] = sph2cart(0,0,0);
    [xt,yt,zt] = sph2cart(0,0,0.8);
    plot3(linspace(xo,-xt,5),linspace(yo,yt,5),linspace(zo,zt,5),'k','Linewidth',1);
    hold on
    plot3(linspace(yo,yt,5),linspace(xo,xt,5),linspace(zo,zt,5),'k','Linewidth',1);
    hold on
    plot3(linspace(zo,zt,5),linspace(yo,yt,5),linspace(xo,xt,5),'k','Linewidth',1);
   
    %plot3(xt,yt,zt,'k>','Markersize',14,'Markerfacecolor','k');
    hold on
    h = surf(x,y,z,double(r>=0));
    
	
	% adjust camera view
	view(210,30)
	camzoom(2)
	camlight left
	%camlight right
	%lighting phong

	axis([-1 1 -1 1 -1 1])
	  axis off
	% map positive regions to red, negative regions to green
	colormap(redgreencolormap([2]))
	%colormap(summer)
	% hide edges
	set(h, 'LineStyle','none')
	
	grid off
    text(-xt-0.1,yt,zt,'y','Fontsize',9,'FontWeight','light')
    text(yt+0.0,xt+0.2,zt,'x','Fontsize',9,'FontWeight','normal')
    text(0,0.05,1,'z','Fontsize',9,'FontWeight','light')
	%text(0,-.25,-1,sprintf('Y_%i%i',L,M))
end

set(20,'paperunits','centimeters','paperposition',[1 1 22 12])
%saveas(20,'../thesis/images/sh/base/sh_order_all','epsc');


end