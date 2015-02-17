function [ output_args ] = calc_avg( input_args )


%% Calc Averaged DTF Magnitude
avg_dtf_left = zeros(offset,length(current_positions));
avg_dtf_right = zeros(offset,length(current_positions));
avg_hrir_left = zeros(hrir_db_length,length(current_positions));
avg_hrir_right = zeros(hrir_db_length,length(current_positions));

set(handles.play_positions,'String',{[1:length(current_positions)],'all'});
set(handles.play_positions,'Value',length(current_positions)+1);

switch(get(handles.calc_mode,'Value'))
    
case 1 % PCA1
    
    avg_DATA_PCA = mean(DATA_PCA);
    
    c =0;
    for pos=1:length(current_positions)

        if (get(handles.pca_mode,'Value') <= 2) % PCA DTF MODE
            c=c+1;
            avg_dtf_left(:,pos) = avg_DATA_PCA((c-1)*offset+1:c*offset);

            c=c+1;
            avg_dtf_right(:,pos) = avg_DATA_PCA((c-1)*offset+1:c*offset);

            % Find matching phase and mean
            rms_error_l = zeros(database_size_real,1);
            rms_error_r = zeros(database_size_real,1);

            for i=1:database_size_real       
            rms_error_l(i) = rmse(avg_dtf_left(:,pos),DATA_PCA(i,(c-2)*offset+1:(c-1)*offset));
            rms_error_r(i) = rmse(avg_dtf_right(:,pos),DATA_PCA(i,(c-1)*offset+1:c*offset));
            end

            % Sort descend
            [~, rms_ind_l] = sort(rms_error_l);
            [~, rms_ind_r] = sort(rms_error_r);

            % Get Phase from best matching DTF
            size(DATA_PHASE)
            matching_phase_l = squeeze(DATA_PHASE(rms_ind_l(1),pos,1,:));
            matching_phase_r = squeeze(DATA_PHASE(rms_ind_r(1),pos,2,:));
            
            avg_hrtf_left = avg_dtf_left(:,pos) + squeeze(MEAN_SUB(rms_ind_l(1),pos,1,:));
            avg_hrtf_right = avg_dtf_right(:,pos) + squeeze(MEAN_SUB(rms_ind_r(1),pos,2,:));

            % Perform IFFT
            [hrir_left, hrir_right] = perform_ifft(avg_hrtf_left,avg_hrtf_right,matching_phase_l,matching_phase_r,hrir_db_length);

            avg_hrir_left(:,pos) = hrir_left;
            avg_hrir_right(:,pos) = hrir_right;

        else % PCA HRIR MODE  
            c=c+1;
            avg_hrir_left(:,pos) = avg_DATA_PCA((c-1)*offset+1:c*offset);  
            c=c+1;
            avg_hrir_right(:,pos) = avg_DATA_PCA((c-1)*offset+1:c*offset);
        end

    end


case 2 % PCA2
       avg_DATA_PCA = zeros(1,size(DATA_PCA,2)*2*length(current_positions));
       
       for pos=1:length(current_positions)
           
           if (get(handles.pca_mode,'Value') <= 2) % PCA DTF MODE
                
                avg_dtf_left(:,pos) = mean(DATA_PCA(2*pos-1:2*length(current_positions):end,:));
                avg_dtf_right(:,pos) = mean(DATA_PCA(2*pos:2*length(current_positions):end,:));
                

                % Find matching phase and mean
                rms_error_l = zeros(database_size_real,1);
                rms_error_r = zeros(database_size_real,1);

                for i=1:database_size_real     
                rms_error_l(i) = rmse(avg_dtf_left(:,pos),DATA_PCA((i-1)*(2*length(current_positions))+1,:));
                rms_error_r(i) = rmse(avg_dtf_right(:,pos),DATA_PCA((i-1)*(2*length(current_positions))+2,:));
                end
                
                % Sort descend
                [~, rms_ind_l] = sort(rms_error_l);
                [~, rms_ind_r] = sort(rms_error_r);

                % Get Phase from best matching DTF
                matching_phase_l = DATA_PHASE(:,rms_ind_l(1),pos,1);
                matching_phase_r = DATA_PHASE(:,rms_ind_r(1),pos,2);
           
                avg_hrtf_left = avg_dtf_left(:,pos) + squeeze(MEAN_SUB(rms_ind_l(1),pos,1,:));
                avg_hrtf_right = avg_dtf_right(:,pos) + squeeze(MEAN_SUB(rms_ind_r(1),pos,2,:));

                % Perform IFFT
                [hrir_left, hrir_right] = perform_ifft(avg_hrtf_left,avg_hrtf_right,matching_phase_l,matching_phase_r,hrir_db_length);

                avg_hrir_left(:,pos) = hrir_left;
                avg_hrir_right(:,pos) = hrir_right;
           
           else % PCA HRIR MODE
           
                avg_hrir_left(:,pos) = mean(DATA_PCA(2*pos-1:2*length(current_positions):end,:));
                avg_hrir_right(:,pos) = mean(DATA_PCA(2*pos:2*length(current_positions):end,:));
               
           end

       end
       
       
    
case 3 % PCA3
       avg_DATA_PCA = zeros(1,size(DATA_PCA,2)*length(current_positions));
       
       
       for pos=1:length(current_positions)
           
           if (get(handles.pca_mode,'Value') <= 2) % PCA DTF MODE
               
                avg_dtf_left(:,pos) = mean(DATA_PCA(pos:length(current_positions):end,1:offset));
                avg_dtf_right(:,pos) = mean(DATA_PCA(pos:length(current_positions):end,offset+1:end));
                
                % Find matching phase and mean
                rms_error_l = zeros(database_size_real,1);
                rms_error_r = zeros(database_size_real,1);
                
                for i=1:database_size_real     
                rms_error_l(i) = rmse(avg_dtf_left(:,pos),DATA_PCA((i-1)*(length(current_positions))+1,1:offset));
                rms_error_r(i) = rmse(avg_dtf_right(:,pos),DATA_PCA((i-1)*(length(current_positions))+1,offset+1:end));
                end
                
                 % Sort descend
                [~, rms_ind_l] = sort(rms_error_l);
                [~, rms_ind_r] = sort(rms_error_r);

                % Get Phase from best matching DTF
                matching_phase_l = DATA_PHASE(:,rms_ind_l(1),pos,1);
                matching_phase_r = DATA_PHASE(:,rms_ind_r(1),pos,2);
           
                avg_hrtf_left = avg_dtf_left(:,pos) + squeeze(MEAN_SUB(rms_ind_l(1),pos,1,:)); %mean(MEAN_SUB(:,:,pos,1),2);
                avg_hrtf_right = avg_dtf_right(:,pos) + squeeze(MEAN_SUB(rms_ind_r(1),pos,2,:)); %mean(MEAN_SUB(:,:,pos,2),2);

                % Perform IFFT
                [hrir_left, hrir_right] = perform_ifft(avg_hrtf_left,avg_hrtf_right,matching_phase_l,matching_phase_r,hrir_db_length);

                avg_hrir_left(:,pos) = hrir_left;
                avg_hrir_right(:,pos) = hrir_right;
                
               
           else % HRIR
               
                avg_hrir_left(:,pos) = mean(DATA_PCA(pos:length(current_positions):end,1:offset));
                avg_hrir_right(:,pos) = mean(DATA_PCA(pos:length(current_positions):end,offset+1:end));
            
           end
           
       end
       
end



end

