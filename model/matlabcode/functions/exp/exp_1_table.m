function exp_1_table(d_sub)
% Construct Table for Latex
head_str = ''; head_col = '';

for sub=1:size(d_sub,1)
    head_str = sprintf('%s &S%i',head_str,sub);
    head_col = [head_col 'l|'];
end

% Table first head
table_string = sprintf('\\tablefirsthead{\\hline  %s \\\\ } \n',head_str);

% Table Head
table_string = [table_string sprintf('\\tablehead{\\hline\\multicolumn{%i}{|r|}{\\small\\sl continued from previous page}\\\\ \\hline %s \\\\} \n',size(d_sub,1)+1,head_str)];

% Table Tail
table_string = [table_string sprintf('\\tabletail{\\hline\\multicolumn{%i}{|r|}{\\small\\sl continued on next page}\\\\ \\hline} \n',size(d_sub,1)+1)];

% Table Last Tail
table_string = [table_string sprintf('\\tablelasttail{\\hline} \n',0)];

% Bottom Caption
table_string = [table_string sprintf('\\bottomcaption{Sensitivity values for each subject, PC, position and adaption value.} \n',0)];

% Define Column Alignment
table_string = [ table_string sprintf('\\begin{supertabular}{|l|%s}\\hline \n',head_col)];

% Get Data
for pos = 1:size(d_sub,2)
    for pc = 1:size(d_sub,3)
        for adapt = 1:size(d_sub,4)            
        table_string = [table_string sprintf('D%iP%iA%i',pos,pc,adapt)];
            for sub = 1:size(d_sub,1)          
            table_string = [table_string sprintf('& %2.2f',d_sub(sub,pos,pc,adapt))];          
            end
        table_string = [table_string sprintf('\\\\ \\hline \n',0)];
        end
    end    
end

% Store als tex-File
table_string = [table_string sprintf('\\end{supertabular} \n',0)];
f = fopen('../thesis/matlab_generated/exp1_sen.tex', 'w');
fprintf(f, '%s',table_string);
fclose(f);
end