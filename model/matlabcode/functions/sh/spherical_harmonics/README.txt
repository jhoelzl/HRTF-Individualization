% This is a collection of MATLAB routines for dealing with real-valued
% spherical functions usually represented by spherical harmonics
% expansions.
%
% COPYRIGHT 2007 Bing Jian (bing.jian@gmail.com)
%
% --- Variable Naming Conventions:
% coff :  row vector, if in matrix form, then each row denotes a set of coefficients
% l,m : degree 'l' and order 'm' 
% degree : lmax 
% dl :  band interval, 
%       1 for full band (0,1,...,lmax), 
%       2 for even band (0,2,...,lmax), useful for symmetric functions  
% phi:  azimuth angle
% theta: polar angle
% real_or_complex:  'real' for real-valued basis; 'complex' for complex-valued basis

% --- List of MATLAB files
% compute_Ylm.m   evaluate spherical harmonic Ylm   
% construct_SH_basis.m  construct spherical harmonics basis at specified points
% construct_basis_from_grid.m  construct spherical harmonics basis at specified grid points
%                              (useful for visualization)
% real_spherical_harmonics.m  evaluate a spherical function and its gradient which can be used
%                             to find peaks
% rotate_coeff.m              compute the coefficients after certain rotation
% angular_correlation.m       compare two spherical functions using angular correlation
% compute_GA.m                compute the generalized anisotropy measure of a spherical function


% --- Other files
% SHRotate.m         supporting function for rotate_coeff.m
% test_rotation.m    test script for rotate_coeff.m
% 321vectors.txt     a point set sampled from a sphere tessellation
%





