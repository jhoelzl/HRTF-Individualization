function setProcessText( handles,message,type )

text = sprintf('\n\n\n\n\n%s',message);

% remove Text
if (type == 0)
    set(handles.gui_process,'String', '');
    set(handles.gui_process,'BackGroundColor', [126 126 126]/255);  
end

% red status Text
if (type == 1)
    set(handles.gui_process,'String', text);
    set(handles.gui_process,'BackGroundColor', 'r'); 
    set(handles.gui_process,'ForeGroundColor', 'w'); 
end

% orange status Text
if (type == 2)
    set(handles.gui_process,'String', text);
    set(handles.gui_process,'BackGroundColor', [180 163 136]/255); 
    set(handles.gui_process,'ForeGroundColor', 'w'); 
end

pause(0.0001)


end