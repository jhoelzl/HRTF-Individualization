function bary_gains = HRTF_interpolation_in_3D
%HRTF_INTERPOLATION_IN_3D Head-related transfer function (HRTF) 
%                         interpolation in azimuth, elevation, and distance
% HRTF_INTERPOLATION_IN_3D returns the interpolation weights for 3-D
% interpolation of HRTF measurements
%
% References:
% Gamper, H. (2013). "Head-related transfer function interpolation in azimuth,
% elevation, and distance", JASA-EL.
%
% Qu, T., Xiao, Z., Gong, M., Huang, Y., Li, X., and Wu, X. (2009).
% "Distance-dependent head-related transfer functions measured with high
% spatial resolution using a spark gap", IEEE Audio, Speech, Language
% Process. 17, pp. 1124?1132.
%
% Sundareswara, R. and Schrater, P. (2003). "Extensible point location 
% algorithm", in Proc. Int. Conf. Geometric Modeling and Graphics, pp. 84?89
%
% Samet, H. (1989). "Implementing ray tracing with octrees and neighbor 
% finding", Computers & Graphics 13, pp. 445?460.
%
%
% Created by Hannes Gamper.
% 1.0 - Oct 2013 Initial release
%
% Please post comments to the FEX page for this entry if you have any
% bugs or feature requests.

% Flags
USE_ADJACENCY_WALK = true;  % true:  use adjacency walk
                            % false: use brute-force search
                            
USE_OCTREE = true;          % true:  use Octree query to find starting 
                            %        tetrahedron for adjacency walk
                            % false: use random starting tetrahedron for
                            %        adjacency walk

% constants
source_pos = [23, -11, 67]; % desired source position (azimuth [deg], elevation [deg], radius [cm])
binCapacity = 5;            % maximum number of points store in each leaf 
                            % node of the octree
fs = 44100;                 % sampling rate [Hz]
                            
%%%% INITIALISATIONS %%%%
                            
% get HRTF measurement coordinates
disp('Retrieving HRTF measurement coordinates...');
aziEleDist = get_HRTF_coords;

% Generate tetrahedral mesh via Delaunay triangulation
disp('Generating tetrahedral mesh and adjacency map of measurement points...');
if str2double(datestr(datenum(version('-date')),'YYYY'))>=2013
    dt = delaunayTriangulation(aziEleDist);
    T = dt.ConnectivityList;    % contains the tetrahedral mesh
    X = dt.Points;              % contains the vertices of the tetrahedra
    N = neighbors(dt);          % contains the adjacency list
else
    T = delaunay(aziEleDist);   % for older Matlab releases < 2013
    X = aziEleDist;
    N = dtNeighbours(T);
end

if USE_OCTREE
    if ~USE_ADJACENCY_WALK
        warning('Octree search can only be used in conjunction with adjacency walk, otherwise the selection might not terminate...');
        USE_ADJACENCY_WALK = true;
    end
    
    % Generate octree
    disp('Generating octree...');
    OT = getOT(aziEleDist, binCapacity);
    
    % get centres and one tetrahedron per octree leaf node
    OT = getOTcentres(OT, T);
    
    % find close tetrahedron
    disp('Querying octree...');
    ti = queryOT(source_pos, OT);
    disp(['Using tetrahedron ', num2str(ti), ' as starting point for adjacency walk']);
else
    ti = 1;
end

% variable initialisations
Niter = 0;
tetra_indices = zeros(size(T,1),1);
MIN_GAIN = -0.00001;        % due to numerical issues, very small negative 
                            % gains are considered 0

%%%% MAIN LOOP %%%%

% iterate through mesh to find tetrahedron for interpolation
disp(['Iterating through ', num2str(size(T,1)), ' tetrahedra...']);
for t = 1:size(T,1)
    % count iterations
    Niter = Niter+1;
    
    % vertices of tetrahedron
    HM = X(T(ti,:),:);
    v4 = HM(4,:);
    H = HM(1:3,:) - repmat(v4,3,1);
    tetra_indices(t) = ti;
    
    % calculate barycentric coordinates
    bary_gains = [(source_pos-v4)*(H^-1), 0];
    bary_gains(4) = 1-sum(bary_gains);
    
    % check barycentric coordinates
    if all(bary_gains>=MIN_GAIN)
        bary_gains = max(bary_gains, 0);
        disp('Success!');
        disp(['Tetrahedron ID: ', num2str(ti), ', iterations: ', num2str(Niter)]);
        tetra_indices = tetra_indices(1:Niter);
        break;
    end
    
    if USE_ADJACENCY_WALK
        % move to adjacent tetrahedron
        [~, bi] = min(bary_gains);
        ti = N(ti,bi);
    else
        % BRUTE-FORCE: move to next tetrahedron in list
        ti = ti+1;
    end
end

if tetra_indices(end)==0
    error('No tetrahedron found. Exiting...');
end

%%%% PLOTS %%%%
figure;
cols = [1,0,0;0,0.5,0;0,0,1;1,0,1;0,1,1;0,0,0];
subplot(2,2,[1,3]);
tetramesh(T(tetra_indices,:), X, 'FaceAlpha', 0.1);
hold on;
plot3(source_pos(1),source_pos(2),source_pos(3), 'rx', 'LineWidth', 3, 'MarkerSize', 20);
grid on;
xlabel('Azimuth [deg]'); ylabel('Elevation [deg]'); zlabel('Distance [cm]');
title(['Tetrahedral search: ', num2str(Niter), ' iterations']);

subplot(2,2,2);
tetramesh(T(tetra_indices(end),:), X, 'FaceAlpha', 0.1);
hold on;grid on;
plot3(source_pos(1),source_pos(2),source_pos(3), 'rx', 'LineWidth', 3, 'MarkerSize', 20);
ht = zeros(1,4);
legstr = cell(1,4);
for vi = 1:4
    ht(vi) = text(HM(vi,1), HM(vi,2), HM(vi,3), ['g', num2str(vi)], 'FontSize', 17, 'Color', cols(vi,:));
    legstr{vi} = ['g', num2str(vi), ' = ', num2str(bary_gains(vi))];
end
xlabel('Azimuth [deg]'); ylabel('Elevation [deg]'); zlabel('Distance [cm]');
hl = legend(ht, legstr{:}, 'Location', 'EastOutside');
set(hl, 'Position', get(hl, 'Position') + [0.01,0,0,0], 'Box', 'off');
title('Barycentric interpolation weights');

subplot(2,2,4);
% simple HRIR model
HM = X(T(tetra_indices(end),:),:);
htmp = simpleHRIR(0, fs);
hrir = zeros(length(htmp),4);
HRTF = zeros(length(htmp),4);
for hi = 1:4
    azi = HM(hi,1);
    ele = HM(hi,2);
    r = HM(hi,3)/100;
    aziInteraural = asind(sind(azi)*cosd(ele));   % convert to interaural coordinates
    distance_attenuation = 1/r;
    hrir(:,hi) = distance_attenuation*simpleHRIR(aziInteraural, fs);
    HRTF(:,hi) = fft(hrir(:,hi));
    NFFT = size(HRTF,1);
    fft_vect = linspace(0,fs/2,NFFT/2);
    plot(fft_vect, 20*log10(abs(HRTF(1:NFFT/2,hi))), 'Color', cols(hi,:));
    hold on; grid on;
end

%%%% INTERPOLATE %%%%
disp('>>> Interpolation: <<<');
disp('bary_gains * abs(HRTF)');
Hint = bary_gains*abs(HRTF(1:NFFT/2,:)');
%%%%%%%%%%%%%%%%%%%%%

xlim([0,fs/2]);
hold on;
plot(fft_vect, 20*log10(Hint), 'k', 'LineWidth', 2);
legend('h1', 'h2', 'h3', 'h4', 'h interpolated');
xlabel('Frequency [Hz]');
ylabel('Magnitude [dB]');
title('Interpolation of (modelled) HRTF data');
end

%% Get HRTF coordinates
function aziEleDist = get_HRTF_coords
% Get the HRTF coordinates used in the PKU&IOA HRTF database [1]
%
% [1] Qu, T., Xiao, Z., Gong, M., Huang, Y., Li, X., and Wu, X. (2009).
% "Distance-dependent head-related transfer functions measured with high
% spatial resolution using a spark gap", IEEE Audio, Speech, Language
% Process. 17, 1124?1132.

% Elevations measured
Elevations = -40:10:90;

% Azimuth steps from lowest to highest elevation
AzimuthStep = [repmat(5, 1, 10), 10, 15, 30, 360];

% Distances measured
Distances = [20:10:50, 75, 100, 130, 160];

% Total number of HRTFs in database
NumHRTFs = sum(360./AzimuthStep)*length(Distances);

% preallocate output array
aziEleDist = zeros(NumHRTFs,3);

% MAIN loop
n = 0;
for dist = Distances
    elei = 0;
    for ele = Elevations
        elei = elei+1;
        for azi = 0:AzimuthStep(elei):359
            n = n+1;
            aziEleDist(n,:) = [azi, ele, dist];
        end
    end
end

end

%% get OCTREE
% Organise 3-D points pts into an octree data structure
% 
% binCapacity: maximum number of points per leaf node
%
% References:
% Samet, H. (1989). "Implementing ray tracing with octrees and neighbor 
% finding", Computers & Graphics 13, pp. 445?460.
function OT = getOT(pts, binCapacity)
% inits
OT = struct;

% start with root
OT.Points = pts;
OT.PointBins = ones(size(pts,1),1);
OT.BinBoundaries = [min(pts), max(pts)];
OT.BinParents = 0;
OT.BinDepths = 0;

% MAIN LOOP
OT = getChildren(OT,1,binCapacity);
OT.BinCount = size(OT.BinParents,1);

end

% Recursive call to split bin into octants
function OT = getChildren(OT, parent, binCapacity)
parentBoundaries = OT.BinBoundaries(parent,:);
for bini = 1:8
    binBoundaries = zeros(1, 6);
    rng = range(reshape(parentBoundaries,3,2),2)';
    binBoundaries(1:3) = bitget(bini-1,1:3).*rng/2 + parentBoundaries(1:3);
    binBoundaries(4:6) = binBoundaries(1:3) + rng/2;
    
    % add bin to list of bins
    OT.BinBoundaries = [OT.BinBoundaries; binBoundaries];
    OT.BinParents = [OT.BinParents; parent];
    OT.BinDepths = [OT.BinDepths; OT.BinDepths(parent)+1];
    currBin = size(OT.BinParents,1);
    
    % check if bin contains any points
    ptinds = (1:size(OT.Points,1))';
    ptinds = ptinds(OT.PointBins==parent);
    
    binPoints = inBin(OT.Points(ptinds,:), binBoundaries);
    binPoints = ptinds(binPoints);
    if ~isempty(binPoints)
        OT.PointBins(binPoints) = currBin;
        if length(binPoints)>binCapacity
            % keep dividing
            OT = getChildren(OT, currBin, binCapacity);
        end
    end
end
end

% Determine which points pts are contained in bin
function inds = inBin(pts, binBoundaries)
N = size(pts,1);
lpts = pts-repmat(binBoundaries(1:3),N,1);
upts = pts-repmat(binBoundaries(4:6),N,1);
inds = find(sum(lpts>=0 & upts<=0,2)==3);
end

% get OT bin centres
function OT = getOTcentres(OT, T)
NPoints = size(OT.Points,1);
NBins = OT.BinCount;
OT.BinCentres = zeros(NBins,3);
OT.BinChildren = zeros(NBins,8);
for bi = 1:NBins
    bin_children = find(OT.BinParents==bi);
    if isempty(bin_children)
        % leaf node: insert a random point as a "child"
        pt = find(OT.PointBins==bi,1);
        if isempty(pt)
            % bin contains no point -> find closest point to bin centre
            binb = OT.BinBoundaries(bi,:);
            binc = (binb(1:3)+binb(4:6))./2;
            binn = sqrt(sum( (OT.Points-repmat(binc, NPoints,1)).^2,2 ));
            [~, pt] = min(binn);
        end
        
        % find a tetrahedron containing pt
        Tind = find(T==pt,1);
        Tind = bmod(Tind, size(T,1));
        
        OT.BinChildren(bi,2) = Tind;
        continue;
    end
    boundaries = OT.BinBoundaries(bin_children,:);
    
    % find centre
    x = unique(boundaries(:,[1,4]));
    y = unique(boundaries(:,[2,5]));
    z = unique(boundaries(:,[3,6]));
    OT.BinCentres(bi,:) = [x(2),y(2),z(2)];
    
    % store children in order
    for bch = 1:8
        chb = OT.BinBoundaries(bin_children(bch),:);
        chc = (chb(1:3)+chb(4:6))./2;
        chind = 0;
        for j = 1:3
            if chc(j) >= OT.BinCentres(bi,j)
                chind = chind + 2^(j-1);
            end
        end
        OT.BinChildren(bi,chind+1) = bin_children(bch);
    end
end
end

% query octree
function ti = queryOT(pos, OT)
binind = 1;
maxbiniter = 50;
biniter = 0;
while (1)
    if (biniter > maxbiniter)
        ti = 1;
        fprintf('No bin found...\n');
        break;
    end
    
    biniter = biniter + 1;
    currbin = binind;
    octind = 0;
    binc = OT.BinCentres(binind,:);
    
    if (pos(1)>=binc(1)); octind = bitor(octind,1); end
    if (pos(2)>=binc(2)); octind = bitor(octind,2); end
    if (pos(3)>=binc(3)); octind = bitor(octind,4); end
    
    has_children = OT.BinChildren(binind,1)>0;
    
    if (~has_children)
        ti = OT.BinChildren(currbin,2);
        break;
    end
    
    binind = OT.BinChildren(binind,octind+1);
end
end

%% Get adjacency list for delaunay triangulation
% T: connectivity list (tetrahedral mesh) of delaunay triangulation 
function N = dtNeighbours(T)

% create matrix containing all edges/faces
NT = size(T,1);
Tdim = size(T,2);
face = zeros(Tdim*NT,Tdim-1);
vinds = zeros(Tdim*NT,1);
Tinds = zeros(Tdim*NT,1);
ptr1 = 1;
ptr2 = NT;

for fi = 1:Tdim
    inds = 1:Tdim;
    inds(fi) = [];
    face(ptr1:ptr2,:) = T(:,inds);
    face(ptr1:ptr2,:) = sort(face(ptr1:ptr2,:), 2);
    vinds(ptr1:ptr2) = fi;
    Tinds(ptr1:ptr2) = 1:NT;
    ptr1 = ptr1+NT;
    ptr2 = ptr2+NT;
end
[faceS, indS] = sortrows(face);
vindsS = vinds(indS);
TindsS = Tinds(indS);

N = -ones(size(T));

n = 0;
while n<size(faceS,1)-1
    n = n+1;
    f1 = faceS(n,:);
    f2 = faceS(n+1,:);
    if sum(f1==f2)==(Tdim-1)
        % found matching edge/face!
        t1 = TindsS(n);
        t2 = TindsS(n+1);
        vi1 = vindsS(n);
        vi2 = vindsS(n+1);
        N(t1,vi1) = t2;
        N(t2,vi2) = t1;
        n = n+1;
    end
end

end

%% alternative modulus function
% mod(N,N) returns N (instead of 0)
% useful for indexing in Matlab
function y = bmod(x,a)
y = mod(x-1,a)+1;
end

%% Simple head-related impulse response (HRIR) model
% References:
% Pulkki, V., Lokki., T. and Rocchesso, D. (2011). "Spatial effects", in 
% DAFx: Digital Audio Effects, 2nd ed., U. Z?lzer, Ed., pp. 139-184
function [output] = simpleHRIR(theta, Fs)

theta = theta + 90;
theta0 = 150;
%alfa_min = 0.05;
alfa_min = 0.1;
c = 334;   % speed of sound
a = 0.08;  % head radius
w0 = c/a;

input = zeros(round(0.003*Fs),1);
input(1) = 1;
alfa = 1+alfa_min/2 + (1-alfa_min/2) * cos(theta/theta0*pi);
alfa2 = 1.05 + 0.95 * cosd(1.2*theta);
if any(abs(alfa-alfa2)>0.00001)
    error('Error');
end
B = [(alfa + w0/Fs)/(1+w0/Fs), (-alfa+w0/Fs)/(1+w0/Fs)];
A = [1, -(1-w0/Fs)/(1+w0/Fs)];

if (abs(theta) < 90)
    gdelay = round(-Fs/w0 * (cos(theta*pi/180) - 1));
else
    gdelay = round(Fs/w0 * ((abs(theta) - 90) * pi/180 + 1) );
end

out_magn = filter(B, A, input);
output = [zeros(gdelay,1); out_magn(1:end-gdelay)];

end
