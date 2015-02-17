function [ data ] = anthro_cipic(subject,dataset)


data = 0;
load('../../db/CIPIC/anthropometry/anthro.mat');

switch dataset
    
    case 'age'
    data = age(subject); 
    
    case 'sex'
    data = sex(subject); 
    
    
     case 'gender_number'
    data = sex(subject); 
    
    if(data == 'M')
       data = 1; 
    end
    
    if(data == 'F')
       data = 2; 
    end 
    
    case 'weight'
    data = WeightKilograms(subject);     
        
    case 'head width'  
    data = X(subject,1);   
        
    case 'head height'
    data = X(subject,2);    
    
    case 'head depth'
    data = X(subject,3); 
    
    case 'pinna offset down'
    data = X(subject,4); 
    
    case 'pinna offset back'
    data = X(subject,5); 
    
    case 'neck width'
    data = X(subject,6);
    
    case 'neck height'
    data = X(subject,7); 
    
    case 'neck depth'
    data = X(subject,8); 
    
    case 'torso top width'
    data = X(subject,9);
    
    case 'torso top height'
    data = X(subject,10);
    
    case 'torso top depth'
    data = X(subject,11);
    
    case 'shoulder width'
    data = X(subject,12); 
    
    case 'head offset forward'
    data = X(subject,13);
    
    case 'height'
    data = X(subject,14); 
    
    case 'seated height'
    data = X(subject,15); 
    
    case 'head circumference'
    data = X(subject,16); 
    
    case 'shoulder circumference'
    data = X(subject,17); 
        
    case 'cavum concha height left'
    data = D(subject,1);  
        
    case 'cymba concha height left'
    data = D(subject,2); 
    
    case 'cavum concha width left'
    data = D(subject,3); 
        
    case 'fossa height left'
    data = D(subject,4); 
    
    case 'pinna height left'
    data = D(subject,5); 
    
    case 'pinna width left'
    data = D(subject,6); 
    
    case 'intertragal incisure width left'
    data = D(subject,7); 
    
    case 'cavum concha depth left'
    data = D(subject,8); 
    
    case 'cavum concha height right'
    data = D(subject,9);  
        
    case 'cymba concha height right'
    data = D(subject,10); 
    
    case 'cavum concha width right'
    data = D(subject,11); 
        
    case 'fossa height right'
    data = D(subject,12); 
    
    case 'pinna height right'
    data = D(subject,13); 
    
    case 'pinna width right'
    data = D(subject,14); 
    
    case 'intertragal incisure width right'
    data = D(subject,15); 
    
    case 'cavum concha depth right'
    data = D(subject,16); 
    
    case 'pinna rotation angle left'
    data = theta(subject,1); 
    
    case 'pinna flare angle left'
    data = theta(subject,2); 
    
    case 'pinna rotation angle right'
    data = theta(subject,3); 
    
    case 'pinna flare angle right'
    data = theta(subject,4); 
    
    case 'pinna-cavity height left'
    data = D(subject,1) + D(subject,2) + D(subject,4);
    
    case 'pinna-cavity height right'
    data = D(subject,9) + D(subject,10) + D(subject,12);
        
    otherwise
    data = 0;    
        
end



    % Avoid NaN Data
    data_nan = isnan(data);
    index = find(data_nan == 1);
    data(index) = 0;
       
end
