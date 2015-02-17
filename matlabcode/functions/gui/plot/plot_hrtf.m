function plot_hrtf(hObject, eventdata, handles)

global current_azimuth
global current_elevation
global current_subject
global current_db
global DB
global UNIVERSAL_DTF
global ANGLES
global azimuth_real
global elevation_real
global fs
global subjects_mean_left
global subjects_mean_right

current_azimuth = get(handles.azimuth,'Value');
current_elevation = get(handles.elevation,'Value'); 
current_subject = get(handles.subject,'Value'); 

% Get All Elevation Listbox values
all_elevation = str2num(get(handles.elevation,'String'));
elevation_real = all_elevation(current_elevation);

% Get All Azimuth Listbox values
all_azimuth = str2num(get(handles.azimuth,'String'));
azimuth_real = all_azimuth(current_azimuth);

% Get All Subject Listbox values
all_subjects = str2num(get(handles.subject,'String'));
current_subject_id = all_subjects(current_subject);


if (strcmp(current_db,'universal') == 0)
    % HRIR
    row = get_matrixvalue(azimuth_real,elevation_real,ANGLES);
    plotdata_l = squeeze(DB(current_subject,row,1,:));
    plotdata_r = squeeze(DB(current_subject,row,2,:));
    
    if (get(handles.plot_type,'Value') <= 3 )
    % HRTF
    [hrtf_l,~,freq_l] = perform_fft(plotdata_l);
    [hrtf_r,~,freq_r] = perform_fft(plotdata_r);
    % DTF
    dtf_l = hrtf_l - subjects_mean_left;
    dtf_r = hrtf_r - subjects_mean_right;
    end    
    
    
else
    
    [value,hrir_length,fs] = get_matrixvalue_universal(elevation_real,azimuth_real,current_subject,ANGLES);    
    plotdata_l = squeeze(DB(current_subject,value,1,1:hrir_length));
    plotdata_r = squeeze(DB(current_subject,value,2,1:hrir_length));
    
    if (get(handles.plot_type,'Value') <= 3 )
    % HRTF
    [hrtf_l,~,freq_l] = perform_fft(plotdata_l,fs);
    [hrtf_r,~,freq_r] = perform_fft(plotdata_r,fs);
    
    % DTF
    dtf_l = squeeze(UNIVERSAL_DTF(current_subject,value,1,:));
    dtf_r = squeeze(UNIVERSAL_DTF(current_subject,value,2,:));
    end 
    
    
end

set(handles.anthropometric,'String',anthro_text(current_subject,current_subject_id,current_db));



    %% Calculate ITD     
    %[itd_ms, idtpos1, idtpos2] = calculate_itd(plotdata_l,plotdata_r);

        
    %% PLOT GUI FIGURES

    % Plot Type
    % Both: DTF and HRTF
     if(get(handles.plot_type,'Value') == 3)
       title_hrtf_l = 'DTF / HRTF left';
       title_hrtf_r = 'DTF / HRTF right';    
     end
    
    % only HRTF
    if(get(handles.plot_type,'Value') == 2)
       title_hrtf_l = 'HRTF left';
       title_hrtf_r = 'HRTF right';   
    end
    
    % only DTF
     if(get(handles.plot_type,'Value') == 1)
       title_hrtf_l = 'DTF left';
       title_hrtf_r = 'DTF right'; 
     end
    
    
    % Smooth DTF / HRTF Options
    switch get(handles.fft_smooth,'Value')
        case 1
        intervall = 256;     
        case 2
        intervall = 128;    
        case 3
        intervall = 64;
        case 4
        intervall = 32;
        case 5
        intervall = 16;
        case 6 
        intervall = 8;  
    end
    
  
    if (get(handles.plot_type,'Value') <= 3 )
        
    hrtf_l = band_limit(hrtf_l,intervall,512);
    dtf_l = band_limit(dtf_l,intervall,512);

    hrtf_r = band_limit(hrtf_r,intervall,512);
    dtf_r = band_limit(dtf_r,intervall,512);
    end
    
    
    
    if (get(handles.show_d,'Value') == 1 )
    % Normal HRIR DATA
    
        if(get(handles.zoom_plot,'Value') == 2) || (get(handles.zoom_plot,'Value') == 1)
        % HRIR left
        plot(handles.hrir_l,plotdata_l);
        grid(handles.hrir_l,'on');
        title(handles.hrir_l,'HRIR left');
        xlabel(handles.hrir_r,'samples')
        %text(idtpos1,idtpos2,['ITD: ',num2str(sprintf('%0.3g',itd_ms)),' ms'],'FontSize',15);
        end

        % HRIR right
        if(get(handles.zoom_plot,'Value') == 3) || (get(handles.zoom_plot,'Value') == 1)
        plot(handles.hrir_r,plotdata_r);
        grid(handles.hrir_r,'on');
        title(handles.hrir_r,'HRIR right');
        xlabel(handles.hrir_r,'samples')
        end
    
    
    end
    
    if (get(handles.show_d,'Value') == 2 ) 
    % 2d HRIR DATA of all elevations
    
        [hrir_ld, hrir_rd] = get_2d_hrir_elevations();
    
        % Convert Samples to ms
        timems= (1:size(hrir_ld,1))/fs;
    
        % 2D HRIR left
        if(get(handles.zoom_plot,'Value') == 2) || (get(handles.zoom_plot,'Value') == 1)
        colormap(handles.hrir_l,gray)    
        imagesc(all_elevation,timems,hrir_ld,'Parent',handles.hrir_l);
        hold(handles.hrir_l,'on');   
        line([elevation_real elevation_real],get(handles.hrir_l,'Ylim'),'Color',[1 0 0],'Parent',handles.hrir_l) 
        hold(handles.hrir_l,'off');
        grid(handles.hrir_l,'on');
        title(handles.hrir_l,'2D HRIR left of all elevations');
        xlabel(handles.hrir_l,'Elevation')
        ylabel(handles.hrir_l,'Time [ms]')
        end

        % 2D HRIR right
        if(get(handles.zoom_plot,'Value') == 3) || (get(handles.zoom_plot,'Value') == 1)
        colormap(handles.hrir_r,gray)
        imagesc(all_elevation,timems,hrir_rd,'Parent',handles.hrir_r);
        hold(handles.hrir_r,'on');   
        line([elevation_real elevation_real],get(handles.hrir_r,'Ylim'),'Color',[1 0 0],'Parent',handles.hrir_r) 
        hold(handles.hrir_r,'off');
        grid(handles.hrir_r,'on');
        title(handles.hrir_r,'2D HRIR right of all elevations');
        xlabel(handles.hrir_r,'Elevation')
        ylabel(handles.hrir_r,'Time [ms]')
        end
    
    end
    
    
    if (get(handles.show_d,'Value') == 3 ) 
    % 2d HRIR DATA of all azimuths
    
        [hrir_ld, hrir_rd] = get_2d_hrir_azimuths(); 
    
        % Convert Samples to ms
        timems = (1:size(hrir_ld,1))/fs; 
        
        % 2D HRIR left
        if(get(handles.zoom_plot,'Value') == 2) || (get(handles.zoom_plot,'Value') == 1)
        colormap(handles.hrir_l,gray)    
        imagesc(all_azimuth,timems,hrir_ld,'Parent',handles.hrir_l)
        hold(handles.hrir_l,'on');   
        line([azimuth_real azimuth_real],get(handles.hrir_l,'Ylim'),'Color',[1 0 0],'Parent',handles.hrir_l) 
        hold(handles.hrir_l,'off');
        grid(handles.hrir_l,'on');
        title(handles.hrir_l,'2D HRIR left of all azimuths');
        xlabel(handles.hrir_l,'Azimuths')
        ylabel(handles.hrir_l,'Time [ms]');
        end

        % 2D HRIR right
        if(get(handles.zoom_plot,'Value') == 3) || (get(handles.zoom_plot,'Value') == 1)
        colormap(handles.hrir_r,gray)
        imagesc(all_azimuth,timems,hrir_rd,'Parent',handles.hrir_r)
        hold(handles.hrir_r,'on');   
        line([azimuth_real azimuth_real],get(handles.hrir_r,'Ylim'),'Color',[1 0 0],'Parent',handles.hrir_r) 
        hold(handles.hrir_r,'off');
        grid(handles.hrir_r,'on');
        title(handles.hrir_r,'2D HRIR right of all azimuths');
        xlabel(handles.hrir_r,'Azimuths')
        ylabel(handles.hrir_r,'Time [ms]')
        end
    
    end
    
    
    if (get(handles.show_d,'Value') == 5 ) 
    % Minimum Phase HRIR

        % HRIR left
        if(get(handles.zoom_plot,'Value') == 2) || (get(handles.zoom_plot,'Value') == 1)
        [~, plotdata_l_m] = rceps(plotdata_l);
        plot(handles.hrir_l,plotdata_l_m);
        grid(handles.hrir_l,'on');
        title(handles.hrir_l,'Minimum Phase HRIR left');
        xlabel(handles.hrir_l,'samples')
        
        end

        % HRIR right
        [~, plotdata_r_m] = rceps(plotdata_r);
        if(get(handles.zoom_plot,'Value') == 3) || (get(handles.zoom_plot,'Value') == 1)
        plot(handles.hrir_r,plotdata_r_m);
        grid(handles.hrir_r,'on');
        title(handles.hrir_r,'Minimum Phase HRIR right');
        xlabel(handles.hrir_r,'samples')
        end
    
    end
    
    
    if (get(handles.show_d,'Value') == 4 )
    % Overall ITD
            
        % 2D ITD of azimuths
        if(get(handles.zoom_plot,'Value') == 2) || (get(handles.zoom_plot,'Value') == 1)
            
        itd_2d = itd_azimuths();    
        pos1 = max(all_azimuth) * 0.3;
        
%         figure
%         plot(all_azimuth,itd_2d)
%         hold('on');   
%         text(pos1,0.2,['ITD: ',num2str(sprintf('%0.3g',itd_2d(current_azimuth))),' ms'],'FontSize',15,'Parent',handles.hrir_l);
%         hold('off');
%         grid('on');
%         title('ITD across all azimuths');
%         xlabel('Azimuths')
%         ylabel('Time [ms]');  
        
        
        plot(handles.hrir_l,all_azimuth,itd_2d)
        hold(handles.hrir_l,'on');   
        line([azimuth_real azimuth_real],get(handles.hrir_l,'Ylim'),'Color',[1 0 0],'Parent',handles.hrir_l) 
        hold(handles.hrir_l,'on')
        text(pos1,0.2,['ITD: ',num2str(sprintf('%0.3g',itd_2d(current_azimuth))),' ms'],'FontSize',15,'Parent',handles.hrir_l);
        hold(handles.hrir_l,'off');
        grid(handles.hrir_l,'on');
        title(handles.hrir_l,'ITD across all azimuths');
        xlabel(handles.hrir_l,'Azimuths')
        ylabel(handles.hrir_l,'Time [ms]');  
        end
        
        % 2D ITD of elevations
        if(get(handles.zoom_plot,'Value') == 3) || (get(handles.zoom_plot,'Value') == 1)
        
        itd_2d_elev = itd_elevations(hObject, eventdata, handles);        
        indizes = ANGLES(:,1) == azimuth_real;
        all_elevation = sort(ANGLES(indizes,2));
              
        plot(handles.hrir_r,all_elevation,itd_2d_elev)
        hold(handles.hrir_r,'on');   
        line([elevation_real elevation_real],get(handles.hrir_r,'Ylim'),'Color',[1 0 0],'Parent',handles.hrir_r') 
        hold(handles.hrir_r,'on')
        %text(pos1,0.2,['ITD: ',num2str(sprintf('%0.3g',itd_2d(current_elevation))),' ms'],'FontSize',15,'Parent',handles.hrir_r);
        hold(handles.hrir_r,'off');
        grid(handles.hrir_r,'on');
        title(handles.hrir_r,'ITD across all elevations');
        xlabel(handles.hrir_r,'Elevation')
        ylabel(handles.hrir_r,'Time [ms]'); 
        end
    
    
    end
    
    
    
    % Single HRTFs, DTF and Both
    if(get(handles.plot_type,'Value') < 4)
        
           
        
    % HRTF left
    if(get(handles.zoom_plot,'Value') == 4) || (get(handles.zoom_plot,'Value') == 1)
    if (get(handles.plot_axes,'Value') == 1 )
        
        if(get(handles.plot_type,'Value') == 1)
        plot(handles.hrtf_l,freq_l,dtf_l,'r');
        end
        if(get(handles.plot_type,'Value') == 2)
        plot(handles.hrtf_l,freq_l,hrtf_l);
        end
        
        if(get(handles.plot_type,'Value') == 3)
        plot(handles.hrtf_l,freq_l,dtf_l,'r');
        hold(handles.hrtf_l,'on');
        plot(handles.hrtf_l,freq_l,hrtf_l);
        hold(handles.hrtf_l,'off');
        end
          
    else
        
        if(get(handles.plot_type,'Value') == 1)
        semilogx(handles.hrtf_l,freq_l,dtf_l,'r');
        end
        if(get(handles.plot_type,'Value') == 2)
        semilogx(handles.hrtf_l,freq_l,hrtf_l);
        end
        
        if(get(handles.plot_type,'Value') == 3)
        semilogx(handles.hrtf_l,freq_l,dtf_l,'r');
        hold(handles.hrtf_l,'on');
        semilogx(handles.hrtf_l,freq_l,hrtf_l);
        hold(handles.hrtf_l,'off');
        end 
    end
    grid(handles.hrtf_l,'on')
    
    if (get(handles.plot_display,'Value') == 1 )
    axis(handles.hrtf_l,[0 20000 -40 30])
    end
    grid on;
    title(handles.hrtf_l,title_hrtf_l);
    
    if(get(handles.show_peaks,'Value') == 1)
    % Peak and Notch Values
    hold(handles.hrtf_l,'on');
    [peaks_l,notches_l] = peakdet(dtf_l,get(handles.peak_slider,'Value'),freq_l);
    if (size(peaks_l) ~= [0 0])
    plot(handles.hrtf_l,peaks_l(:,1),peaks_l(:,2), 'k*');
    end
    if (size(notches_l) ~= [0 0])
    plot(handles.hrtf_l,notches_l(:,1),notches_l(:,2), 'g*');
    end
    hold(handles.hrtf_l,'off');
    end

    end
         
        
    % HRTF right
    if(get(handles.zoom_plot,'Value') == 5) || (get(handles.zoom_plot,'Value') == 1)
    hold(handles.hrtf_r,'off');
    
    if (get(handles.plot_axes,'Value') == 1 )
        
        if(get(handles.plot_type,'Value') == 1)
        plot(handles.hrtf_r,freq_r,dtf_r,'r');
        end
        if(get(handles.plot_type,'Value') == 2)
        plot(handles.hrtf_r,freq_r,hrtf_r);
        end
        
        if(get(handles.plot_type,'Value') == 3)
        plot(handles.hrtf_r,freq_r,dtf_r,'r');
        hold(handles.hrtf_r,'on');
        plot(handles.hrtf_r,freq_r,hrtf_r);
        hold(handles.hrtf_r,'off');
        end
          
    else
        
        if(get(handles.plot_type,'Value') == 1)
        semilogx(handles.hrtf_r,freq_r,dtf_r,'r');
        end
        if(get(handles.plot_type,'Value') == 2)
        semilogx(handles.hrtf_r,freq_r,hrtf_r);
        end
        
        if(get(handles.plot_type,'Value') == 3)    
        semilogx(handles.hrtf_r,freq_r,dtf_r,'r');
        hold(handles.hrtf_r,'on');
        semilogx(handles.hrtf_r,freq_r,hrtf_r);
        hold(handles.hrtf_r,'off');
        
        end 
    end
    
    if (get(handles.plot_display,'Value') == 1)
    axis(handles.hrtf_r,[0 20000 -40 30])
    end
    grid(handles.hrtf_r,'on');
    title(handles.hrtf_r,title_hrtf_r);
    
    
    if(get(handles.show_peaks,'Value') == 1)
    % Peak and Notch Values
    hold(handles.hrtf_r,'on');
    [peaks_r,notches_r] = peakdet(dtf_r,get(handles.peak_slider,'Value'),freq_r);
    if (size(peaks_r) ~= [0 0])
    plot(handles.hrtf_r,peaks_r(:,1),peaks_r(:,2), 'k*');
    end
    if (size(notches_r) ~= [0 0])
    plot(handles.hrtf_r,notches_r(:,1),notches_r(:,2), 'g*');
    end
    hold(handles.hrtf_r,'off');
    end
  
    end
    
    end
   
   [~,~,freq_l] = perform_fft(plotdata_l,fs);
   
     % 2D HRTF of all elevations
    if(get(handles.plot_type,'Value') == 4)
        
        [hrtf_ld, hrtf_rd] = get_2d_hrtf_elevations(1);
       
        % 2D HRTF left
        if(get(handles.zoom_plot,'Value') == 4) || (get(handles.zoom_plot,'Value') == 1)
        colormap(handles.hrtf_l,gray)    
        imagesc(all_elevation,freq_l,hrtf_ld,'Parent',handles.hrtf_l)
        hold(handles.hrtf_l,'on');   
        line([elevation_real elevation_real],get(handles.hrtf_l,'Ylim'),'Color',[1 0 0],'Parent',handles.hrtf_l) 
        hold(handles.hrtf_l,'off');
        grid(handles.hrtf_l,'on');
        title(handles.hrtf_l,'2D HRTF left of all elevations');
        xlabel(handles.hrtf_l,'Elevations')
        ylabel(handles.hrtf_l,'Frequency [Hz]');            
        end

        % 2D HRTF right
        if(get(handles.zoom_plot,'Value') == 5) || (get(handles.zoom_plot,'Value') == 1)
        colormap(handles.hrtf_r,gray)
        imagesc(all_elevation,freq_l,hrtf_rd,'Parent',handles.hrtf_r)
        hold(handles.hrtf_r,'on');   
        line([elevation_real elevation_real],get(handles.hrtf_r,'Ylim'),'Color',[1 0 0],'Parent',handles.hrtf_r) 
        hold(handles.hrtf_r,'off');
        grid(handles.hrtf_r,'on');
        title(handles.hrtf_r,'2D HRTF right of all elevations');
        xlabel(handles.hrtf_r,'Elevations')
        ylabel(handles.hrtf_r,'Frequency [Hz]')
        end
        
    end
    
    % 2D HRTF of all azimuths
    if(get(handles.plot_type,'Value') == 5)
        
        [hrtf_ld, hrtf_rd] = get_2d_hrtf_azimuths(1); 
       
        % 2D HRTF left
        if(get(handles.zoom_plot,'Value') == 4) || (get(handles.zoom_plot,'Value') == 1)
        colormap(handles.hrtf_l,gray)    
        imagesc(all_azimuth,freq_l,hrtf_ld,'Parent',handles.hrtf_l)
        hold(handles.hrtf_l,'on');   
        line([azimuth_real azimuth_real],get(handles.hrtf_l,'Ylim'),'Color',[1 0 0],'Parent',handles.hrtf_l) 
        hold(handles.hrtf_l,'off');
        grid(handles.hrtf_l,'on');
        title(handles.hrtf_l,'2D HRTF left of all azimuths');
        xlabel(handles.hrtf_l,'Azimuths')
        ylabel(handles.hrtf_l,'Frequency [Hz]');  
        end

        % 2D HRIR right
        if(get(handles.zoom_plot,'Value') == 5) || (get(handles.zoom_plot,'Value') == 1)
        colormap(handles.hrtf_r,gray)
        imagesc(all_azimuth,freq_l,hrtf_rd,'Parent',handles.hrtf_r)
        hold(handles.hrtf_r,'on');   
        line([azimuth_real azimuth_real],get(handles.hrtf_r,'Ylim'),'Color',[1 0 0],'Parent',handles.hrtf_r) 
        hold(handles.hrtf_r,'off');
        grid(handles.hrtf_r,'on');
        title(handles.hrtf_r,'2D HRTF right of all azimuths');
        xlabel(handles.hrtf_r,'Azimuths')
        ylabel(handles.hrtf_r,'Frequency [Hz]')
        end
        
    end
    
    
    % 2D DTF of all elevations
    if(get(handles.plot_type,'Value') == 6)
        
        [hrtf_ld, hrtf_rd] = get_2d_hrtf_elevations(2);
       
        % 2D DTF left
        if(get(handles.zoom_plot,'Value') == 4) || (get(handles.zoom_plot,'Value') == 1)
        colormap(handles.hrtf_l,gray)    
        imagesc(all_elevation,freq_l,hrtf_ld,'Parent',handles.hrtf_l)
        hold(handles.hrtf_l,'on');   
        line([elevation_real elevation_real],get(handles.hrtf_l,'Ylim'),'Color',[1 0 0],'Parent',handles.hrtf_l) 
        hold(handles.hrtf_l,'off');
        grid(handles.hrtf_l,'on');
        title(handles.hrtf_l,'2D DTF left of all elevations');
        xlabel(handles.hrtf_l,'Elevations')
        ylabel(handles.hrtf_l,'Frequency [Hz]');            
        end

        % 2D DTF right
        if(get(handles.zoom_plot,'Value') == 5) || (get(handles.zoom_plot,'Value') == 1)
        colormap(handles.hrtf_r,gray)
        imagesc(all_elevation,freq_l,hrtf_rd,'Parent',handles.hrtf_r)
        hold(handles.hrtf_r,'on');   
        line([elevation_real elevation_real],get(handles.hrtf_r,'Ylim'),'Color',[1 0 0],'Parent',handles.hrtf_r) 
        hold(handles.hrtf_r,'off');
        grid(handles.hrtf_r,'on');
        title(handles.hrtf_r,'2D DTF right of all elevations');
        xlabel(handles.hrtf_r,'Elevations')
        ylabel(handles.hrtf_r,'Frequency [Hz]')
        end
        
    end
    
    % 2D DTF of all azimuths
    if(get(handles.plot_type,'Value') == 7)
        
        [hrtf_ld, hrtf_rd] = get_2d_hrtf_azimuths(2); 
       
        % 2D DTF left
        if(get(handles.zoom_plot,'Value') == 4) || (get(handles.zoom_plot,'Value') == 1)
        colormap(handles.hrtf_l,gray)
        imagesc(all_azimuth,freq_l,hrtf_ld,'Parent',handles.hrtf_l)
        hold(handles.hrtf_l,'on');   
        line([azimuth_real azimuth_real],get(handles.hrtf_l,'Ylim'),'Color',[1 0 0],'Parent',handles.hrtf_l) 
        hold(handles.hrtf_l,'off');
        grid(handles.hrtf_l,'on');
        title(handles.hrtf_l,'2D DTF left of all azimuths');
        xlabel(handles.hrtf_l,'Azimuths')
        ylabel(handles.hrtf_l,'Frequency [Hz]') 
        end

        % 2D DTF right
        if(get(handles.zoom_plot,'Value') == 5) || (get(handles.zoom_plot,'Value') == 1)
        colormap(handles.hrtf_r,gray)
        imagesc(all_azimuth,freq_l,hrtf_rd,'Parent',handles.hrtf_r)
        hold(handles.hrtf_r,'on');   
        line([azimuth_real azimuth_real],get(handles.hrtf_r,'Ylim'),'Color',[1 0 0],'Parent',handles.hrtf_r) 
        hold(handles.hrtf_r,'off');
        grid(handles.hrtf_r,'on');
        title(handles.hrtf_r,'2D DTF right of all azimuths');
        xlabel(handles.hrtf_r,'Azimuths')
        ylabel(handles.hrtf_r,'Frequency [Hz]')
        end
        
    end
    



end