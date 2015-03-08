function pca_error_table2(db)

% Construct LaTex Table with required PC numbers for 90% variance

% Load Error File
error_data = sprintf('../matlabdata/test_pca/variance_pca_%s.mat',db);
load(error_data,'pcs_variance','conf');

% Show conf
conf

% Config
parameters.smoothing = conf.smoothing;
input_modes = 1:4;
input_mode_names = {'HRIR','Min HRIR','DTF lin','DTF log'};
input_structures = [1:5];
ear_modes = [1 2];
offset_columns = 2;
ears_names = {'only left','only right','both'};
ears = 3;

           
% LATEX Table Headings
col_len= length(ear_modes)*length(input_modes)+offset_columns;
table_str = '';
for c=1:col_len
    table_str = [table_str 'c|'];
end

% Table first head
table_string = sprintf('\\tablefirsthead{\\hline & ',0);

for c=1:length(input_modes)
    table_string = [table_string sprintf('& \\multicolumn{2}{c|}{%s}',input_mode_names{input_modes(c)})];
end
table_string = [table_string sprintf('\\\\ \\hline \n',0)];


table_string = [table_string '&'];

for c=1:length(input_modes)
    for e=1:length(ear_modes)
    %table_string = [table_string sprintf('&\\textbf{Em%i}',e)];
    if (e ==1)
        table_string = [table_string sprintf('&\\textbf{E $\\downarrow$}',0)];
        else
        table_string = [table_string sprintf('&\\textbf{E $\\rightarrow$}',0)];    
    end
        
    end
end
table_string = [table_string sprintf('\\\\}\n',0)];

% Table head
table_string = [table_string sprintf('\\tablehead{\\hline\\multicolumn{%i}{|r|}{\\small\\sl continued from previous page}\\\\ \\hline &',col_len)];
for c=1:length(input_modes)
    table_string = [table_string sprintf('& \\multicolumn{2}{c|}{%s}',input_mode_names{input_modes(c)})];
end

table_string = [table_string sprintf('\\\\ \\hline',0)];


table_string = [table_string '&'];

for c=1:length(input_modes)
    for e=1:length(ear_modes)
        %table_string = [table_string sprintf('&\\textbf{Em%i}',e)];
        if (e ==1)
        table_string = [table_string sprintf('&\\textbf{E $\\downarrow$}',0)];
        else
        table_string = [table_string sprintf('&\\textbf{E $\\rightarrow$}',0)];    
    end
    end
end

table_string = [table_string sprintf('\\\\ \\hline}\n',0)];


table_string = [table_string sprintf('\\tabletail{\\hline\\multicolumn{%i}{|r|}{\\small\\sl continued on next page}\\\\ \\hline}\n',col_len)];
table_string = [table_string sprintf('\\tablelasttail{\\hline}\n',0)];
table_string = [table_string sprintf('\\bottomcaption{Number of PCs required to yield 90 percent variance in %s database for different parameters in the input matrix. S/1 and S/2 refers to no smoothing or reducing Fourier coefficients to a half. E$\\downarrow$ and E$\\rightarrow$ correspond to ears blocked in rows or columns.}',upper(db))];

table_string = [ table_string sprintf('\\begin{supertabular}{|%s}\\hline\n',table_str)];


for input_struct=1:length(input_structures)
   
    table_string = [table_string sprintf('\\multirow{%i}{*}{\\begin{sideways}Struct%i\\end{sideways}}',length(parameters.smoothing),input_structures(input_struct))];
    
    for smooth = 1:length(parameters.smoothing)
    table_string = [table_string sprintf('& S/%i',parameters.smoothing(smooth))];
       

    
    %for d=1:length(parameters.density)
        
        %if (d ==1)
            % D1    
            %table_string = [table_string sprintf('& \\textbf{D%i}',1)];
            %else
            % other D values
            %table_string = [table_string sprintf('& & \\textbf{D%i}',parameters.density(d))];
       % end
            
        
        for input_mode =1:length(input_modes)
            for ear_mode = 1:length(ear_modes)
            numpcs = (squeeze(pcs_variance(1,1,ears,input_mode,input_struct,ear_mode,smooth,:)));
            var= find(numpcs>90);
            var90 = var(1);
         
            
            table_string = [table_string sprintf('& %i',var90)];
            
            end
        end
        

        %if (d == length(parameters.density))
            if (smooth == length(parameters.smoothing))
            table_string = [table_string sprintf('\\\\ \\cline{1-%i}\n',col_len)]; 
            else
            table_string = [table_string sprintf('\\\\ \\cline{2-%i}\n',col_len)];     
            end
        %else
        %table_string = [table_string sprintf('\\\\ \\cline{3-%i}\n',col_len)];    
        %end
        
    %end
        
    end
    
end

table_string = [table_string '\end{supertabular}'];

f = fopen(sprintf('../thesis/matlab_generated/pca_error_table_%s_ear%s.tex',db,ears_names{ears}), 'w');
fprintf(f, '%s',table_string);
fclose(f);
end