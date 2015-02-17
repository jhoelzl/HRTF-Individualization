function [ anthropometric_info ] = anthro_text(current_subject,current_subject_id,current_db)

anthropometric_info = '';

switch(current_db)
    
    case 'ari'

    % Show anthro_data;
    age = anthro_ari(current_subject_id,'age',current_db);
    gender = anthro_ari(current_subject_id,'sex',current_db);
    headwidth = anthro_ari(current_subject_id,'head width',current_db);
    headheight = anthro_ari(current_subject_id,'head height',current_db);
    headdepth = anthro_ari(current_subject_id,'head depth',current_db);
    headcircumference = anthro_ari(current_subject_id,'head circumference',current_db);
    pinnacavityheight = anthro_ari(current_subject_id,'pinna-cavity height left',current_db);
    pinnaheight = anthro_ari(current_subject_id,'pinna height left',current_db);
    
    if isempty(gender) ||  (gender == 0)
    gender_info = '';
    else
    gender_info = sprintf('Gender: %s \n',gender);
    end
    
    if age > 0
    age_info = sprintf('Age: %d \n',age);
    else
    age_info = '';
    end

    if (pinnaheight == 0)
        pinnaheight_info = '';
    else
        pinnaheight_info = sprintf('Pinna height: %0.5g cm\n', pinnaheight);
    end

    if (headdepth == 0)
        headdepth_info = '';
    else
        headdepth_info = sprintf('Head depth: %0.5g cm\n', headdepth);
    end
    
    if (headwidth == 0)
        headwidth_info = '';
    else
        headwidth_info = sprintf('Head width: %0.5g cm\n', headwidth);
    end
    
    if (headcircumference == 0)
        headcircumference_info = '';
    else
        headcircumference_info = sprintf('Head circumference: %0.5g cm\n', headcircumference);
    end
    
    if (headheight == 0)
        headheight_info = '';
    else
        headheight_info = sprintf('Head height: %0.5g cm\n', headheight);
    end
        
    
    
    if (pinnacavityheight == 0.000000)
    pinnacavityheight_info = '';
    else
    pinnacavityheight_info = sprintf('Pinna length: %0.5g cm\n', pinnacavityheight);
    end
    
    anthropometric_info = [gender_info, age_info,headwidth_info,headheight_info,headdepth_info,headcircumference_info,pinnacavityheight_info,pinnaheight_info];
    
    case 'cipic'
        
    % Show anthro_data;
    age = anthro_cipic(current_subject,'age');
    gender = anthro_cipic(current_subject,'sex');
    headwidth = anthro_cipic(current_subject,'head width');
    headheight = anthro_cipic(current_subject,'head height');
    headdepth = anthro_cipic(current_subject,'head depth');
    headcircumference = anthro_cipic(current_subject,'head circumference');
    pinnacavityheight = anthro_cipic(current_subject,'pinna-cavity height left');
    pinnaheight = anthro_cipic(current_subject,'pinna height left');
    
    if isempty(gender)
    gender_info = '';
    else
    gender_info = sprintf('Gender: %s \n',gender);
    end
    
    if age > 0
    age_info = sprintf('Age: %d \n',age);
    else
    age_info = '';
    end

    if (pinnaheight == 0)
        pinnaheight_info = '';
    else
        pinnaheight_info = sprintf('Pinna height: %0.5g cm\n', pinnaheight);
    end

    if (headdepth == 0)
        headdepth_info = '';
    else
        headdepth_info = sprintf('Head depth: %0.5g cm\n', headdepth);
    end
    
    if (headwidth == 0)
        headwidth_info = '';
    else
        headwidth_info = sprintf('Head width: %0.5g cm\n', headwidth);
    end
    
    if (headcircumference == 0)
        headcircumference_info = '';
    else
        headcircumference_info = sprintf('Head circumference: %0.5g cm\n', headcircumference);
    end
    
    if (headheight == 0)
        headheight_info = '';
    else
        headheight_info = sprintf('Head height: %0.5g cm\n', headheight);
    end
        
    
    
    if (pinnacavityheight == 0.000000)
    pinnacavityheight_info = '';
    else
    pinnacavityheight_info = sprintf('Pinna length: %0.5g cm\n', pinnacavityheight);
    end
    
    anthropometric_info = [gender_info, age_info,headwidth_info,headheight_info,headdepth_info,headcircumference_info,pinnacavityheight_info,pinnaheight_info];
        
        
    case 'ircam'
        
    % Get XML Data
    % Get Current Subject specific DB ID
    [gender, hairstyle, descr] = ircam_xml(current_subject_id);
    
    if isempty(gender)
    gender_info = '';
    else
    gender_info = sprintf('Gender: %s \n',gender);
    end
    
    if isempty(hairstyle)
    hair_info = '';
    else
    hair_info = sprintf('Hairstyle: %s \n',hairstyle);
    end
    
    if isempty(descr)
    descr_info = '';
    else
    descr_info = sprintf('%s \n',descr);
    end
    
    anthropometric_info = [gender_info, hair_info, descr_info];
    
        
end
if (isempty(anthropometric_info) == 1)
anthropometric_info = 'No anthropometric data';
end

end

