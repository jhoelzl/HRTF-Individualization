function play_hrtf(hObject, eventdata, handles)

    if(get(handles.play_change,'Value') == 1)
    listen_single_hrtf(hObject, eventdata, handles); 
    end
end