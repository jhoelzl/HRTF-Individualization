function test_plot_sh1( )


sphere_points = rand(100,3);
[basis] = construct_SH_basis(2, sphere_points, 1, 'real');



figure(2)

surf(basis(:,:))


end

