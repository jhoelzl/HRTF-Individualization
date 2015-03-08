function [answer,db_file] = check_data(m)

% Check if precalculated Data is available in filesystem and import it

if (strcmp(m.weight_model.parameter.type,'local') ==1)
db_file = sprintf('../matlabdata/model/%s_%s_%s_inpm%i_inps%i_em%i_sm%i_fft%i_pc%i_sub%i_dens%i_bp%i.mat',m.database.name,m.model.parameter.type,m.weight_model.parameter.type,m.model.parameter.input_mode,m.model.parameter.structure,m.model.parameter.ear_mode,m.dataset.parameter.smooth_ratio,m.dataset.parameter.fft_size,m.model.parameter.pcs,m.dataset.parameter.subjects, m.dataset.parameter.density,m.dataset.parameter.bp_mode);
else
db_file = sprintf('../matlabdata/model/%s_%s_%s_inpm%i_inps%i_em%i_sm%i_fft%i_pc%i_sh%i_reg%i_sub%i_dens%i_bp%i.mat',m.database.name,m.model.parameter.type,m.weight_model.parameter.type,m.model.parameter.input_mode,m.model.parameter.structure,m.model.parameter.ear_mode,m.dataset.parameter.smooth_ratio,m.dataset.parameter.fft_size,m.model.parameter.pcs,m.weight_model.parameter.order,m.weight_model.parameter.regularize,m.dataset.parameter.subjects,m.dataset.parameter.density,m.dataset.parameter.bp_mode);
end

if (exist(db_file,'file') == 2)
    answer = 1;
else
    answer = 0;
end

end