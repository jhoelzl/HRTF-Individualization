function [cjdg,fb_conf,ud_conf,fb_conf_full,ud_conf_full] = confussions_gm(jdg,loc,tol1,tol2,tol3,crc)

% jdg: individual judgements; azimuth [-+ 180], elevation [-90 to 270]

% tol1: tolerance front/back front
% tol2: tolerance front/back back
% tol3: tolerance up/down
% crc: if 1 then correct judgements in matrix cjdg

% Calculate Error and Front-Back Confusions
cjdg = jdg;
fb_conf = zeros(2,size(loc,1),size(loc,2));ud_conf = zeros(2,size(loc,1),size(loc,2));
fb_conf_full = zeros(size(loc,1),size(loc,2));ud_conf_full = zeros(size(loc,1),size(loc,2));
for l = 1:size(loc,1) % locations
    for t = 1:size(loc,2) % trials
        % Front-Back Confusions
        if loc(l,t,1) < 0 % Left Hemishphere
            if ( (loc(l,t,1) >= (-90-tol1)) && (loc(l,t,1) <= (-90+tol1)))  % target inside IAA exclusion zone
                % ignore
            else
%             if loc(l,t,1)~= -90 % Exclude locations directly on the side
                if (loc(l,t,1) > - 90) && (loc(l,t,1) > (-90+tol1)) % Front and Outside Conf Zone
                    if (jdg(l,t,1) < - 90) && (jdg(l,t,1) < 0)  || (jdg(l,t,1) > 90) && (jdg(l,t,1) > 0) % Target Outside Tolerance                        
                        fb_conf(1,l,t) = 1;
                        fb_conf_full(l,t) = 1;
                        if crc == 1
                            if (jdg(l,t,1) < - 90) && (jdg(l,t,1) < 0)
                                cjdg(l,t,1) = - 90 - (jdg(l,t,1) + 90);
                            elseif (jdg(l,t,1) > 90) && (jdg(l,t,1) > 0)
                                cjdg(l,t,1) = 90 - (jdg(l,t,1) - 90);
                            end
                        else
                            cjdg(l,t,:) = NaN;
                        end                        
                    elseif (jdg(l,t,1) > 180 - tol2) && (jdg(l,t,1) > 0)
                        fb_conf(1,l,t) = 1;
                        fb_conf_full(l,t) = 1;
                        if crc == 1
                            cjdg(l,t,1) = -180 + jdg(l,t,1);
                        else
                            cjdg(l,t,:) = NaN;                            
                        end
                    end
                end

                if (loc(l,t,1) < -90) && (loc(l,t,1) < (90-tol1)) % Back and Outside Zone
                    if jdg(l,t,1) > - 90 && (jdg(l,t,1) < 0)  % Target Outside Horizontal Tolerance                         
                        fb_conf(2,l,t) = 1;
                        fb_conf_full(l,t) = 1;                        
                        if crc == 1
                            cjdg(l,t,1) = -90 - (jdg(l,t,1) + 90);                                                        
                        else
                            cjdg(l,t,:) = NaN;
                        end
                    elseif (jdg(l,t,1) < tol2) && (jdg(l,t,1) > 0)
                        fb_conf(2,l,t) = 1;
                        fb_conf_full(l,t) = 1;
                        if crc == 1
                            cjdg(l,t,1) = 180 - jdg(l,t,1);
                        else
                            cjdg(l,t,:) = NaN;
                        end
                    end
                end
            end
            
        else % Right Hemisphere or Zero
            if ((loc(l,t,1) >= (90-tol1)) && (loc(l,t,1) <= (90+tol1))) % target inside IAA exclusion zone      
                %ignore 
            else
                if (loc(l,t,1) <= 90-tol1) && (loc(l,t,1) >= 0) % Front and Outsize Conf Zone
                    if (jdg(l,t,1)) > 90 || (jdg(l,t,1))<-90 % Outside Tolerance                
                        fb_conf(1,l,t) = 1;
                        fb_conf_full(l,t) = 1;
                        if crc == 1
                            if (jdg(l,t,1)) > 90
                                cjdg(l,t,1) =  90 - (jdg(l,t,1)-90);
                            elseif (jdg(l,t,1)) < -90
                                cjdg(l,t,1) =  -90 - (jdg(l,t,1)+90);
                            end                                
                        else  
                            cjdg(l,t,:) =  NaN;
                        end
                    elseif (jdg(l,t,1) < - 180 + tol2) 
                        fb_conf(1,l,t) = 1;
                        fb_conf_full(l,t) = 1;
                        if crc == 1
                            cjdg(l,t,1) = -180 - jdg(l,t,1);
                        else
                            cjdg(l,t,:) = NaN;
                        end
                    end
                end                                
                if (loc(l,t,1) >= 90 + tol1) && (loc(l,t,1) >= 0) % Back and Outside Confussion Zone                 
                    if jdg(l,t,1) < 90 && jdg(l,t,1) >= 0  
                        fb_conf(2,l,t) = 1;
                        fb_conf_full(l,t) = 1;
                        if crc == 1
                            cjdg(l,t,1) = 90 + (90 - jdg(l,t,1));
                        else
                            cjdg(l,t,:) = NaN;
                        end
                    elseif (jdg(l,t,1) > - tol2) && jdg(l,t,1) <= 0
                        fb_conf(2,l,t) = 1;
                        fb_conf_full(l,t) = 1;
                        if crc == 1
                            cjdg(l,t,1) = - 180 - jdg(l,t,1);
                        else
                            cjdg(l,t,:) = NaN;
                        end
                    end
                end
            end
           
        end % End Front - Back Confussions
        
       
        
        
        
        % Up - Down Confusions
        
        if loc(l,t,2) < tol3 && loc(l,t,2) > -tol3 % Exclusion Zone
                % ignore
        else
            if loc(l,t,2) > 0 % Up 
                if jdg(l,t,2) < 0 % Down Judgment
                    ud_conf(1,l,t) = 1;
                    ud_conf_full(l,t) = 1;
                    if crc == 1
                        cjdg(l,t,2) = -jdg(l,t,2);
                    else
                        cjdg(l,t,:) = NaN;
                    end
                end
            end


            if loc(l,t,2)<0 % Down
                if jdg(l,t,2) > 0 % 
                    ud_conf(2,l,t) = 1;
                    ud_conf_full(l,t) = 1;
                    if crc == 1
                        cjdg(l,t,2) = -jdg(l,t,2);
                    else
                        cjdg(l,t,:) = NaN;
                    end
                end
            end
        end                        
    end
end

% cjdg(find(loc==180)) = abs(cjdg(find(loc==180)));

end

function z = m_sign(x)
    if x>=0
        z = 1;
    else
        z = -1;
    end
end


% x =[
%   -45     0  -135     0
%  -135     0   -45     0
%   -90     0  -100     0
%   -10     0   175     0
%   -10     0  -175     0
%    45     0   135     0
%   135     0    45     0
%    90     0   100     0
%    10     0  -175     0
%    10     0   175     0 
%    ]




% for l = 1:16
%     for r = 1:5
%         [rcjdg(l,r,1),rcjdg(l,r,2),rcjdg(l,r,3)] = sph2cart(-cjdg(l,r,1)*pi/180,cjdg(l,r,2)*pi/180,1);        
%         [rloc(l,r,1),rloc(l,r,2),rloc(l,r,3)] = sph2cart(-loc(l,r,1)*pi/180,loc(l,r,2)*pi/180,1);
%         e(l,r) = sum((rcjdg(l,r,:)-rloc(l,r,:)).^2);
%     end    
% end
% az_e = sqrt((abs(cjdg(:,:,1)) - abs(loc(:,:,1))).^2);
% el_e = sqrt((cjdg(:,:,2) - loc(:,:,2)).^2);