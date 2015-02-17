f=2; % 2 freuqency similar to soccer ball 

r=4; % 4 meter radius

[x2, y2, z2, it]=icosahedron_nodes(f, r);

[x, y, z]=build_icosa(x2, y2, z2);

[rho, theta, phi]=spherical_angle_ed(x, y, z);

[x10, y10, z10]=splat(rho, theta, phi);

TRI = delaunay(x10, y10);

[TRI, x, y, z]=make_sphere(TRI, x, y, z);

figure(1);
h=trisurf(TRI,x,y,z, 'FaceColor', [1 0 0], 'EdgeColor', 0*[1 1 1], ...
'LineWidth', 1 );
title('Red Soccer Ball');
axis equal