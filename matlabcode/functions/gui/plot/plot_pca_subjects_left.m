function plot_pca_subjects_left(hObject, eventdata, handles,mode)

% mode = 0: update all plots
% mode = 1,2,3,4,5 update only one specific plot

global weight_l_recon
global v_l
global anthro_data
global current_db
global subjects

switch (current_db)
    case {'cipic','ari'}
    mode_cor = 1;
    
    otherwise
    mode_cor = 0;
end

for i=1:5
    pcwl(i,:) = weight_l_recon(:,i);
end

anthro_data2 = anthro_data;

% Total Variance
total_var = sum(v_l(1:5))/sum(v_l)*100;
total_var = sprintf('Total Variance of first 5 PCs (left ear): %2.2f %%',total_var);
set(handles.text_variance_left,'String', total_var);

if (strcmp('cipic',current_db) == 1) || (strcmp('ari',current_db) == 1)
if (get(handles.view_mode,'Value') ~= 1)
if(get(handles.remove_null,'Value') == 1)
% if no anthro_data for this subject, remove data in pc for this subject
  for i=1:length(subjects)
       if (anthro_data(i)== 0)   
       for k=1:5
       pcwl(k,i) = 0;
       end
       end  
  end
  
pcwl(:,~all(pcwl))=[];
anthro_data2 = anthro_data(anthro_data~=0);
 
end
end
else
    anthro_data2 = zeros(1,length(subjects));
end

%% PLOT 5 PC WEIGHTS and existing anthro data

for i=1:5
    
    if (mode ~= 0) | (mode ~= i)
    
    title_handles = sprintf('handles.basis%i_left',i);   
    title_pcw = sprintf('PCW %i',i);
    
    if (mode_cor == 1)
    plotyy(eval(title_handles),[1:length(pcwl(i,:))],pcwl(i,:),[1:length(anthro_data2)],anthro_data2);
    else
    plot(eval(title_handles),pcwl(i,:))
    end    
        
    grid(eval(title_handles),'on')
    title(eval(title_handles),title_pcw);
    str=sprintf('%2.2f %%' ,v_l(i)/sum(v_l)*100);     

    R = corrcoef(pcwl(i,:),anthro_data2);
    %cor = R(2,1);
    cor = sign(R(2,1))*sqrt(abs(R(2,1)));
    cor_abs = abs(cor);
    cor=sprintf('%2.2f ' ,cor);
    cor = num2str(cor);

        if (mode_cor == 1)
        legend(eval(title_handles),[str,cor],{str,cor})
        else
        legend(eval(title_handles),str)    
        end
        if (cor_abs > 0.59)
        set(eval(title_handles), 'Color', 'yellow')
        else
        set(eval(title_handles), 'Color', 'white')   
        end

    end
    
    
end



end