function [ anthro_data ] = get_cipic_anthro()
 % Get Anthro data
        anthro_data = zeros(45,67);
        
        for i=1:45
            anthro_data(i,1) = anthro_cipic(i,'head width');
            anthro_data(i,2) = anthro_cipic(i,'head height');
            anthro_data(i,3) = anthro_cipic(i,'head depth');
            anthro_data(i,4) = anthro_cipic(i,'pinna offset down');
            anthro_data(i,5) = anthro_cipic(i,'pinna offset back');
            anthro_data(i,6) = anthro_cipic(i,'neck width');
            anthro_data(i,7) = anthro_cipic(i,'neck height');
            anthro_data(i,8) = anthro_cipic(i,'neck depth');
            anthro_data(i,9) = anthro_cipic(i,'torso top width');
            anthro_data(i,10) = anthro_cipic(i,'torso top height');
            anthro_data(i,11) = anthro_cipic(i,'torso top depth');
            anthro_data(i,12) = anthro_cipic(i,'shoulder width');
            anthro_data(i,13) = anthro_cipic(i,'head offset forward');
            anthro_data(i,14) = anthro_cipic(i,'height');
            anthro_data(i,15) = anthro_cipic(i,'seated height');
            anthro_data(i,16) = anthro_cipic(i,'head circumference');
            anthro_data(i,17) = anthro_cipic(i,'shoulder circumference');
            anthro_data(i,18) = anthro_cipic(i,'cavum concha height left');
            anthro_data(i,19) = anthro_cipic(i,'cavum concha height right');
            anthro_data(i,20) = anthro_cipic(i,'cymba concha height left');
            anthro_data(i,21) = anthro_cipic(i,'cymba concha height right');
            anthro_data(i,22) = anthro_cipic(i,'cavum concha width left');
            anthro_data(i,23) = anthro_cipic(i,'cavum concha width right');
            anthro_data(i,24) = anthro_cipic(i,'fossa height left');
            anthro_data(i,25) = anthro_cipic(i,'fossa height right');
            anthro_data(i,26) = anthro_cipic(i,'pinna height left');
            anthro_data(i,27) = anthro_cipic(i,'pinna height right');
            anthro_data(i,28) = anthro_cipic(i,'pinna width left');
            anthro_data(i,29) = anthro_cipic(i,'pinna width right');
            anthro_data(i,30) = anthro_cipic(i,'intertragal incisure width left');
            anthro_data(i,31) = anthro_cipic(i,'intertragal incisure width right');
            anthro_data(i,32) = anthro_cipic(i,'cavum concha depth left');
            anthro_data(i,33) = anthro_cipic(i,'cavum concha depth right');
            anthro_data(i,34) = anthro_cipic(i,'pinna rotation angle left');
            anthro_data(i,35) = anthro_cipic(i,'pinna rotation angle right');
            anthro_data(i,36) = anthro_cipic(i,'pinna flare angle left');
            anthro_data(i,37) = anthro_cipic(i,'pinna flare angle right');
            anthro_data(i,38) = anthro_cipic(i,'pinna-cavity height left');
            anthro_data(i,39) = anthro_cipic(i,'pinna-cavity height right');
            anthro_data(i,40) = anthro_cipic(i,'age');
            anthro_data(i,41) = anthro_cipic(i,'gender_number');
            anthro_data(i,42) = anthro_cipic(i,'weight');
            
            % ITD
            %plotdata_l = squeeze(CIPIC(current_azimuth,get_matrixvalue_cipic(i)+current_elevation-1,:));
            %plotdata_r = squeeze(CIPIC(current_azimuth,get_matrixvalue_cipic(i)+50+current_elevation-1,:));
            %anthro_data(i,43) = calculate_itd(plotdata_l,plotdata_r);
            
            % Linear Regression (from Paper ICAD05)
            % New extra paramteters from existing dimensions
            
            % d11 left ear (d1+d2)
            anthro_data(i,44)= anthro_data(18) + anthro_data(20);
            
            % d11 right ear (d1+d2)
            anthro_data(i,45) = anthro_data(19) + anthro_data(21);
            
            % d12 left ear (d1 + d2 + d4)
            anthro_data(i,46) = anthro_data(18) + anthro_data(20) + anthro_data(24);
            
            % d12  right ear (d1 + d2 + d4)
            anthro_data(i,47) = anthro_data(19) + anthro_data(21) + anthro_data(25);
            
            % d13 left ear (d1 + d2)*d3
            anthro_data(i,48) = (anthro_data(18) + anthro_data(20)) * anthro_data(22);
            
            % d13 right ear (d1 + d2)*d3
            anthro_data(i,49) = (anthro_data(19) + anthro_data(21)) * anthro_data(23);
            
            % d14 left ear (d1+d2)*d3*d8
            anthro_data(i,50) = (anthro_data(18) + anthro_data(20)) * anthro_data(22) * anthro_data(32);
            
            % d14 right ear (d1+d2)*d3*d8
            anthro_data(i,51) = (anthro_data(19) + anthro_data(21)) * anthro_data(23) * anthro_data(33);
            
            % d15 left ear (d1+d2)*d3*d10
            anthro_data(i,52) = (anthro_data(18) + anthro_data(20)) * anthro_data(22) * anthro_data(36);
            
            % d15 right ear (d1+d2)*d3*d10
            anthro_data(i,53) = (anthro_data(19) + anthro_data(21)) * anthro_data(23) * anthro_data(37);
            
            % d16 left ear (d1+d2)*d7*d8
            anthro_data(i,54) = (anthro_data(18) + anthro_data(20)) * anthro_data(30) * anthro_data(32);
            
            % d16 right ear (d1+d2)*d7*d8
            anthro_data(i,55) = (anthro_data(19) + anthro_data(21)) * anthro_data(31) * anthro_data(33);
            
            % d17 left ear (d1+d2)*d7*d10
            anthro_data(i,56) = (anthro_data(18) + anthro_data(20)) * anthro_data(30) * anthro_data(36);
            
            % d17 right ear (d1+d2)*d7*d10
            anthro_data(i,57) = (anthro_data(19) + anthro_data(21)) * anthro_data(31) * anthro_data(37);
            
            % d18 left ear (d1*d3)
            anthro_data(i,58)= anthro_data(18) + anthro_data(22);
            
            % d18 right ear (d1*d3)
            anthro_data(i,59)= anthro_data(19) + anthro_data(23);
            
            % d19 left ear (d5*d6)
            anthro_data(i,60)= anthro_data(26) + anthro_data(28);
            
            % d19 right ear (d5*d6)
            anthro_data(i,61)= anthro_data(27) + anthro_data(29);
            
            % d20 left ear (d5*d6*d8)
            anthro_data(i,62)= anthro_data(26) + anthro_data(28) * anthro_data(32);
            
            % d20 right ear (d5*d6*d8)
            anthro_data(i,63)= anthro_data(27) + anthro_data(29) * anthro_data(33);
            
            % d21 left ear (d5*d6*d10)
            anthro_data(i,64)= anthro_data(26) + anthro_data(28) * anthro_data(36);
            
            % d21 right ear (d5*d6*d10)
            anthro_data(i,65)= anthro_data(27) + anthro_data(29) * anthro_data(37);
            
            % d22 left ear (d4*d6)
            anthro_data(i,66)= anthro_data(24) + anthro_data(28);
            
            % d22 right ear (d4*d6)
            anthro_data(i,67)= anthro_data(25) + anthro_data(29);
            
        end

        

end

