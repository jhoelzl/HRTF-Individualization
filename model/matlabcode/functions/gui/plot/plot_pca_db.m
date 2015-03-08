function plot_pca_db(hObject, eventdata, handles)

global v;
global weights

plot_pcs = 5;

st_dev = std(weights(:,1:plot_pcs));
weights_mean = mean(weights(:,1:plot_pcs));
slider_intervall= 3;

% Total Variance
total_var = sum(v(1:plot_pcs))/sum(v)*100;
total_var = sprintf('Total Variance of first 5 PCs: %2.2f ',total_var);
total_var = [total_var,'%'];
set(handles.text_variance,'String', total_var);

% Plot 5 PCWs
for i=1:plot_pcs
    
    title_pcw = sprintf('PCW %i',i);
    plot_handle = sprintf('handles.basis%i',i);
    slider_handle = sprintf('handles.slider%i',i);
    
    set(eval(slider_handle),'Min',(weights_mean(i)-slider_intervall* st_dev(i)),'Max',(weights_mean(i)+slider_intervall* st_dev(i)),'Value', weights_mean(i)); 

    axes(eval(plot_handle)) 
    plot(weights(:,i));    
    grid on
    title(title_pcw);
    legend(sprintf('%2.2f %%' ,v(i)/sum(v)*100)); 

end


end