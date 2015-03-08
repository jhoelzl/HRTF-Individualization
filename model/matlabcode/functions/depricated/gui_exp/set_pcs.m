function set_pcs(hObject, eventdata, handles)
global weights

% Set "Reconstruct PCs"
pc_list = '';

for i=1:size(weights,2)
    pc_list = sprintf('%s%i|',pc_list,i);
end

% delete last symbol |
pc_list=pc_list(1:(end-1));

set(handles.reconstruct_pcs,'String',pc_list);

% Set Value to 10, if possible
if (size(weights,2) < 10)
set(handles.reconstruct_pcs,'Value',size(weights,2));
else
set(handles.reconstruct_pcs,'Value',10);
end



% Set "Plot PCW No." Popupmenu
set(handles.plot_pcw_no,'String',pc_list);

end