function [sdc,ee,R] = spherical_analysis(az,el,az0,el0)
% data: azimuth, elevation of judgments
% loc : azimuth, elevation of original locations
% ee: azimuth, elevation error and distance between the two points

% Using Carlisle's Method
% Mean Direction in Hoop Coordinates
sdc = Mean_sp([az el]);
% Error

ra = Drcos_sp([sdc(1),0,1]);
ta = Drcos_sp([az0,0,1]);
ee(1) = acos(dot(ra,ta))*sign(dot(ta, cross([0 0 1], ra)))*180/pi;
% disp(sprintf('A -- T: %.2f,R: %.2f,D: %.2f',az0,sdc(1),ee(1)));

re = Drcos_sp([0,sdc(2),1]);
te = Drcos_sp([0,el0,1]);
ee(2) = sign(dot(te, cross([0 1 0], re)))*acos(dot(re,te))*180/pi;
% disp(sprintf('E -- T: %.2f,R: %.2f,D: %.2f',el0,sdc(2),ee(2)));

ee(3) = norm(Drcos_sp(sdc)-Drcos_sp([az0 el0]));

S = sum(Drcos_sp([az el]),1);
R = sqrt(sum(S.^2));
R = 1 - R/length(az);
if (R<0)
    1;
end
end
% ee = rotate(sdc,[az0 el0]);
% ee(1) = acos(dot(Drcos_sp(sdc),Drcos_sp([az0 el0])))*sign(dot(Drcos_sp([az0 el0]), cross([0 0 1], Drcos_sp(sdc))))*180/pi;
% ee(2) = sign(dot(Drcos_sp([az0 el0]), cross([0 1 0], Drcos_sp(sdc))))*acos(dot(Drcos_sp(sdc),Drcos_sp([az0 el0])))*180/pi;

% ee = Tp2hp(Dc2tp(Drcos_sp(sdc) - Drcos_sp([az0 el0])));


% N = length(az);
% az = az*pi/180;az0 = az0*pi/180;
% el = el*pi/180;el0 = el0*pi/180;
% 
% % Transform to Cartesian
% 
% [dc(:,1),dc(:,2),dc(:,3)] = sph2cart(-az,el,1);
% [lc(1),lc(2),lc(3)] = sph2cart(-az0,el0,1);
% 
% 
% % Mean Direction
% S = sum(dc,1);
% R = sqrt(sum(S.^2));
% k1 = 1/((N-1)^2/(N*(N-R)));



% dc0 = squeeze(S./R);
% 
% % Mean Response and Target Direction in Spherical Coordinates
% [sdc(1),sdc(2),sdc(3)] = cart2sph(dc0(1),dc0(2),dc0(3));
% [slc(1),slc(2),slc(3)] = cart2sph(lc(1),lc(2),lc(3));
% 
% % Azimuth and Elevation Error
% 
% [ra(:,1),ra(:,2),ra(:,3)] = sph2cart(sdc(1),0,1);
% [ta(1),ta(2),ta(3)] = sph2cart(slc(1),0,1);
% ee(1) = acos(dot(ra,ta))*sign(dot(ta, cross([0 0 1], ra)))*180/pi;
% % disp(sprintf('A -- T: %.2f,R: %.2f,D: %.2f',az0,sdc(1),ee(1)));
% 
% [re(:,1),re(:,2),re(:,3)] = sph2cart(0,sdc(2),1);
% [te(1),te(2),te(3)] = sph2cart(0,slc(2),1);
% ee(2) = sign(dot(te, cross([0 1 0], re)))*acos(dot(re,te))*180/pi;
% % disp(sprintf('E -- T: %.2f,R: %.2f,D: %.2f',el0,sdc(2),ee(2)));
% 
% sdc = sdc*180/pi;
% 
% % Error Vector 
% e = dc0-lc;
% c_e = norm(e); % Magnitude 
% ee(3) = norm(e);
% [s_e(1),s_e(2),s_e(3)] = cart2sph(e(1),e(2),e(3)); % Error in Cartesian
% s_e = s_e; % s_e Az,El,Mag of Error Vector


% if N>1
%     cdev = std(sqrt(repmat(lc,[size(dc,1) 1])- dc).^2); 
%     sdev = cart2sph(cdev(1),cdev(2),cdev(3)); % Deviation in Spherical Coords
% else   
%     sdev = NaN;
% end





% % Outliers
% [b_a, idx_a, o_a] = deleteoutliers(data(:,1),0.05);
% data(idx_a,1) = median(data(setxor(1:N,idx_a),1));
% [b_e, idx_e, o_e] = deleteoutliers(data(:,2),0.05);
% data(idx_e,2) = median(data(setxor(1:size(data,1),idx_e),2));
% disp(sprintf('Az:%d,El:%d, O_A=%d,O_E=%d ',loc(1),loc(2),length(idx_a),length(idx_e)));
% To Radians