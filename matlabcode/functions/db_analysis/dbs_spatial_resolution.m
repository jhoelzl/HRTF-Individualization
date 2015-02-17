function dbs_spatial_resolution(db,clr)
% Plot all source positions of a HRTF database on a sphere

% Input 
% db = HRTF database name
% clr = color for plotting points

% Import HRIR DATA
[~,~,~,angles] = db_import(db);

figure(3)
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
    msize = 15;
else
    msize = 10;
end

% Convert to cartesian for plotting
r = ones(size(angles,1),1);
[xt,yt,r]=sph2cart(deg2rad(angles(:,1)),deg2rad(angles(:,2)),r);
plot3(xt,yt,r,strcat(clr,'.'),'MarkerSize',msize)
view(220,20)


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

%title(sprintf('%s database',upper(db)))

set(3,'paperunits','centimeters','paperposition',[1 1 15 12])
saveas(3,sprintf('../thesis/images/dbs/resolution_%s',lower(db)),'epsc');
end