function [subject_id,eq_id,ari_id] = init_name()

choice = menu('Choose your name','Georgios','Josef','Other');

switch(choice)
    
    case 1
    subject_id = 104;    
        
    case 2
    subject_id = 103;
    
    otherwise
        
    % Ask ID
    prompt={'Your ID'};
    answer = inputdlg(prompt);
    subject_id = str2num(cell2mat(answer));    
          
end


text = sprintf('Your ID: %i',subject_id);

% Get telation between subejcts_id and ari_id
switch (subject_id)

    case  103
    disp('Hi Josef!')
    text = sprintf('%s, Josef',text);
    eq_id =  2; 
    ari_id = 64;
   

    case 104
    disp('Hi Georgios!')
    text = sprintf('%s, Georgios',text);
    eq_id =  3;
    ari_id = 65; 
    
    otherwise
    disp('Hi Anonymus!')    
    eq_id = 1;
    ari_id = 0;
    
end

end

