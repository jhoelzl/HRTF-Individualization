function plot_spatial_resolution(angles,clr,fignum)

% Plot all source positions on a sphere

% Input
% db = HRTF database name
% clr = color for plotting points

% Import HRIR DATA
%[~,~,~,angles] = db_import(db);

if (nargin < 3)
    fignum = 3;
end

figure(fignum)
clf;
%plot a sphere with radius scale
load('topo.mat','topo','topomap1');
[X,Y,Z]=sphere(24);

surface(X,Y,Z);
alpha(0.3)
colormap(gray)
grid on
hold on


%Markersize
if (size(angles,1) < 300)
    msize = 20;
else
    msize = 15;
end

% Convert to cartesian for plotting
r = ones(size(angles,1),1);
[xt,yt,r]=sph2cart(deg2rad(angles(1,1)),deg2rad(angles(1,2)),r);
plot3(xt,yt,r,strcat(clr,'.'),'MarkerSize',msize)
view(220,20)
%title(sprintf('%s database',upper(db)))

%set(2,'paperunits','centimeters','paperposition',[1 1 10 8])
%saveas(2,sprintf('../report/images/dbs/resolution_%s',lower(db)),'epsc');
end