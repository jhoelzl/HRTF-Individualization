function perform_pca_direction(hObject, eventdata, handles)

% PCA Decomposition of one specific Angle of all Subjects in db

global current_db
global subjects
global DB
global ANGLES
global weights
global pcs
global v
global mn
global azimuth_real
global elevation_real
global MEAN_SUB
global DATA_DTF
global weights_modified

text = sprintf('Elevation %0.5g / Azimuth %d / All %i %s Subjects',elevation_real,azimuth_real,length(subjects),upper(current_db));
set(handles.pca_choose_text,'String', text);

% Construct PCA Input Matrix
positions = get_matrixvalue(azimuth_real,elevation_real,ANGLES);
[DATA_DTF,MEAN_SUB] = pca_in(DB,1,2,length(subjects),positions,1,current_db,0);

% Perform PCA
[pcs,weights,v,mn] = pca_calc(DATA_DTF,1);

% Plot PCA
weights_modified = weights; 
plot_pca_db(hObject, eventdata, handles)

end