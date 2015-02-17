function pca_error_table(db)

% INPUT
% db = name of database

% Load Error File
error_data = sprintf('../matlabdata/test_pca/variance_pca_%s_fft512',db);
load(error_data,'pcs_variance','conf');

% Show conf
conf

% Config
parameters.density = [1];
parameters.smoothing = conf.smoothing;
input_modes = conf.input_modes;
input_mode_names = {'HRIR','Min HRIR','DTF lin','DTF log'};
input_structures = conf.input_structures;
ear_modes = conf.ear_modes;
%ears = [3];
if (length(conf.ears) == 1)
    ears = 3;
else
    ears = 1:length(conf.ears);
end
ears_names = {'left ear','right ear','both ears'};

           
% LATEX Table Headings
col_len= length(ear_modes)*length(input_modes)+3;
table_str = '';
for c=1:col_len
    table_str = [table_str 'c|'];
end

% Table first head
table_string = sprintf('\\tablefirsthead{\\hline & & ',0);

for c=1:length(input_modes)
    table_string = [table_string sprintf('& \\multicolumn{2}{c|}{%s}',input_mode_names{input_modes(c)})];
end
table_string = [table_string sprintf('\\\\ \\hline \n',0)];


table_string = [table_string '& & '];

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
table_string = [table_string sprintf('\\tablehead{\\hline\\multicolumn{%i}{|r|}{\\small\\sl continued from previous page}\\\\ \\hline & &',col_len)];
for c=1:length(input_modes)
    table_string = [table_string sprintf('& \\multicolumn{2}{c|}{%s}',input_mode_names{input_modes(c)})];
end

table_string = [table_string sprintf('\\\\ \\hline',0)];


table_string = [table_string '& &'];

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

table_string = [table_string sprintf('\\\\}\n \\hline',0)];


table_string = [table_string sprintf('\\tabletail{\\hline\\multicolumn{%i}{|r|}{\\small\\sl continued on next page}\\\\ \\hline}\n',col_len)];
table_string = [table_string sprintf('\\tablelasttail{\\hline}\n',0)];
%table_string = [table_string sprintf('\\bottomcaption{Number of PCs required to yield 90 percent variance in %s database for different parameters in the input matrix. S0 and S16 refers to no smoothing or reducing Fourier coefficients to 16. D1 and D10 refers to including all positions or every 10th. Em1 and Em2 corresponds to Earmode1 or Earmode2.}',upper(db))];
table_string = [table_string sprintf('\\bottomcaption{Number of PCs required to yield 90 percent variance for different realizations of a PCA input matrix based on the ARI dataset. S/1 refers to no smoothing and S/2..S/N to different degrees of HRTF spectrum smoothing (see Section \ref{sec:smoothing}). E$\downarrow$ and E$\rightarrow$ correspond to ears blocked in rows or columns.}',upper(db))];

table_string = [ table_string sprintf('\\begin{supertabular}{|%s}\\hline\n',table_str)];


for input_struct=1:length(input_structures)
   
    table_string = [table_string sprintf('\\multirow{%i}{*}{\\begin{sideways}Struct%i\\end{sideways}}',length(parameters.smoothing)*length(ears),input_structures(input_struct))];
    
    for smooth = 1:length(parameters.smoothing)
        
    % horizontal or vertical "Smooth"
    if (length(ears) == 1)
    table_string = [table_string sprintf('& S/%i',length(ears),parameters.smoothing(smooth))];    
    else
    table_string = [table_string sprintf('& \\multirow{%i}{*}{\\begin{sideways}S/%i\\end{sideways}}',length(ears),parameters.smoothing(smooth))];
    end   
   
    
    for ear=1:length(ears)
        
        if (ear ==1)
            % Ear 1    
            table_string = [table_string sprintf('& %s',ears_names{ears(ear)})];
            else
            % other Ear values
            table_string = [table_string sprintf('& & %s',ears_names{ears(ear)})];
        end
            
        
        for input_mode =1:length(input_modes)
            for ear_mode = 1:length(ear_modes)
            numpcs = (squeeze(pcs_variance(1,1,1,ear,input_mode,input_struct,ear_mode,smooth,:)));
            var= find(numpcs>90);
            var90 = var(1);
            %numpcs = cell2mat(squeeze(num_pcs(input_mode,input_struct,ear_mode,smooth,d)));
           
            
            table_string = [table_string sprintf('& %i',var90)];
            
            end
        end
        

        if (ear == length(ears))
            if (smooth == length(parameters.smoothing))
            table_string = [table_string sprintf('\\\\ \\cline{1-%i}\n',col_len)]; 
            else
            table_string = [table_string sprintf('\\\\ \\cline{2-%i}\n',col_len)];     
            end
        else
        table_string = [table_string sprintf('\\\\ \\cline{%i-%i}\n',length(ears),col_len)];    
        end
        
    end
        
    end
    
end

table_string = [table_string '\end{supertabular}'];

f = fopen(sprintf('../thesis/matlab_generated/pca_error_table_%s_fft512.tex',db), 'w');
fprintf(f, '%s',table_string);
fclose(f);
end