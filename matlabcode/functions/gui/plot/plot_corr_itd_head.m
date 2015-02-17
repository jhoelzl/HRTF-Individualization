function plot_corr_itd_head(hObject, eventdata, handles)
global current_azimuth
global current_elevation
global current_db
global DB
global ANGLES
global azimuth_real
global elevation_real

% Correlation PLOT

switch(current_db)
case {'iem','kemar'}
    errordlg('No anthropometric data in iem db')
   
case 'cipic'
    
    
    for i=1:25
        
        % get head with data
        head_width(i) = anthropometric(i,'head width');
        
        if (head_width(i)  ~= 0)
        % get itd
        row = get_matrixvalue(azimuth_real,elevation_real,ANGLES)
        plotdata_l = squeeze(DB(i,row,1,:));
        plotdata_r = squeeze(DB(i,row,2,:));
        itd(i) = calculate_itd(plotdata_l,plotdata_r);
        end  
    end
    
    head_width = head_width(find(head_width~=0));
    itd = itd(find(itd~=0));
    figure
    plot(head_width)
    hold on
    plot(itd,'r-')
    
        
case 'ircam'  
    
    errordlg('No anthropometric data in ircam db')
 
end



end