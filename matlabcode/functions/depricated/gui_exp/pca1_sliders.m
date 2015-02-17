function pca1_sliders( hObject, eventdata, handles,slider_intervall)
global weights


size(weights)

% Get weight numbers
if (size(weights,2) < 10)
    weight_no = size(weights,2);
else
    weight_no = 10;
end

% Calculate mean and standard deviation and for PCWs
m = mean(weights(:,1:weight_no));
std_dev = std(weights(:,1:weight_no));

% Sort descend by variance
    for i=1:weight_no   
    slider_name = sprintf('handles.slider%i',i);
    set(eval(slider_name),'Value',0);
    set(eval(slider_name),'Min',(m(i)-slider_intervall* std_dev(i)),'Max',(m(i)+slider_intervall* std_dev(i)),'Value', m(i));
    end
   
    
        
% Plot PCW Histogram
if (get(handles.plot_pcw,'Value') == 1)
figure(4)
hist(weights(:,get(handles.plot_pcw_no,'Value')))
title(sprintf('PCW  No. %i',get(handles.plot_pcw_no,'Value')))
end


end