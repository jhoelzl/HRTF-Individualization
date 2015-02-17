function [input_matrix,mean_matrix,dimensions] = algo_input_matrix(hrirs,parameter,dimensions)

disp('Input Matrix')
% Split Parameter
% db = parameter{1};
pca_structure = str2num(strrep(parameter{1},'struct',''));
ear_mode = str2num(strrep(parameter{2},'ear_mode',''));
pca_mode = str2num(strrep(parameter{3},'mode',''));
ears = strrep(parameter{4},'ears','');
if (~strcmp(ears,':'))
   ears = str2num(ears); 
end

pca_mean_mode = str2num(strrep(parameter{5},'mean_mode',''));
freq_mode =  str2num(strrep(parameter{6},'freq_mode',''));
minimum_phase = str2num(strrep(parameter{7},'mp',''));
smooth_val = str2num(strrep(parameter{1},'s',''));

% [hrirs,~,~,angles,~,~,~,~,~,~,fs] = db_import(db);
dimensions.structure = pca_structure;
dimensions.mode = pca_mode;
dimensions.ear_mode = ear_mode;
dimensions.ears = ears;
dimensions.freq_mode = freq_mode;

% Create INPUT MATRIX
[input_matrix,mean_matrix] = algo_input(hrirs(:,:,ears,:),pca_mode,pca_structure,pca_mean_mode,freq_mode,ear_mode,minimum_phase,smooth_val,dimensions.fs);

disp(sprintf('Finished: Input Matrix [%i x %i]',size(input_matrix,1),size(input_matrix,2)))

end