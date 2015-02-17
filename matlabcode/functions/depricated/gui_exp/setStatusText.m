function setStatusText( handles,message,type )

text = sprintf('     %s',message);

% remove Text
if (type == 0)
    set(handles.gui_status,'String', '');
    set(handles.gui_status,'BackGroundColor', [126 126 126]/255);  
end

% red status Text
if (type == 1)
    set(handles.gui_status,'String', text);
    set(handles.gui_status,'BackGroundColor', 'r'); 
    set(handles.gui_status,'ForeGroundColor', 'w'); 
end

% orange status Text
if (type == 2)
    set(handles.gui_status,'String', text);
    set(handles.gui_status,'BackGroundColor', [180 163 136]/255); 
    set(handles.gui_status,'ForeGroundColor', 'w'); 
end

pause(0.0001)


end