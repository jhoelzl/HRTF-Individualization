function [shws,sha] = algo_sh(parameter,input_data,algo_before,algo_after,dimensions)

% Hint: currently working only with Input Matrix struct2,mode1

sh_order = str2num(parameter{1});

if (length(parameter) > 1)
    pc_order = str2num(parameter{2});
else
    pc_order = size(input_data,2)*2;
end

% SH
shws = [];

disp(sprintf('SH with Order %i of %s [%i x %i]',sh_order,algo_before,size(input_data,1),size(input_data,2))) 
input_data = reshape(input_data,[dimensions.subjects,size(dimensions.angles,1),dimensions.samples]);
disp(sprintf('New Dimensions after Reshape: [%i x %i x %i]',size(input_data,1),size(input_data,2),size(input_data,3)))
  
  
if (strcmp(algo_before,'pca')) && (dimensions.structure == 2)
    [shws,sha] = pca2sh(input_data,dimensions.angles,pc_order,sh_order); 
end


if (strcmp(algo_before,'input_matrix'))
    [shws,sha] = db2sh(input_data,dimensions.angles,sh_order); 
end

disp(sprintf('Finished: SHWs [%i x %i x %i]',size(shws,1),size(shws,2),size(shws,3)))

end