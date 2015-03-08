function pca2_sliders( hObject, eventdata, handles,slider_intervall)

global subjects
global ANGLES

subjects = getSubjects(hObject, eventdata, handles);
position = get(handles.position,'Value');
    
% Extend Positions with az/el sliders
azimuth = ANGLES(position,1);
elevation = ANGLES(position,2);
pos_ind =  positions_extend(ANGLES,azimuth,elevation,get(handles.az_extend,'Value'),get(handles.el_extend,'Value'));

[weights_selected] = pca2_weights_positions(pos_ind,hObject, eventdata, handles);

% Plot selected weights in Gui
set(handles.extend_used, 'String',sprintf('Used: %i weights',size(weights_selected,1)));

% Calc mean / std (left/right) across subjects and positions / first 10 weights
if (size(weights_selected,2) < 10)
    slider_used = size(weights_selected,2);
else
    slider_used = 10;
end

mean_left = mean(weights_selected(:,1:slider_used));
std_left = std(weights_selected(:,1:slider_used));

    
for i=1:slider_used
    
    % First Set Slider Values to zero to avoid gui errors
    slider_name = sprintf('handles.slider%i',i);
    set(eval(slider_name),'Value',0);

    % Gui Slider Min-Max, Values, only for left-ear weights
    set(eval(slider_name),'Min',(mean_left(i)-slider_intervall* std_left(i)),'Max',(mean_left(i)+slider_intervall* std_left(i)),'Value', mean_left(i)); 

end

% Plot PCW Histogram
if (get(handles.plot_pcw,'Value') == 1)
figure(4)
hist(weights_selected(:,get(handles.plot_pcw_no,'Value')))
title(sprintf('PCW  No. %i',get(handles.plot_pcw_no,'Value')))
end

end

