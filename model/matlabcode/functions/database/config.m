function [ids,names] =  config(mode) 

% Return list of HRTF databases

% INPUT
% mode: optional: 'exp': load only HRTF databases that are useful for experiment

if (nargin == 0)
    mode = '';
end

fn = ['config.xml'];

dom = xmlread(fn); 
elems = dom.getElementsByTagName('db');

c=0;
for i = 0:elems.getLength-1 

  % Read child items from "db"  
  id = char(elems.item(i).getElementsByTagName('id').item(0).getTextContent);
  name = strtrim(char(elems.item(i).getElementsByTagName('name').item(0).getTextContent));
  enabled = strtrim(char(elems.item(i).getElementsByTagName('enabled').item(0).getTextContent));
  exp_enable = strtrim(char(elems.item(i).getElementsByTagName('exp_enable').item(0).getTextContent));
  
  
  if (strcmp(mode,'exp') == 1)
      
      if (str2num(char(enabled)) == 1) && (str2num(char(exp_enable)) == 1)
      c=c+1;    
      ids(c)= {id};
      names(c)= {name}; 
      end
      
  else
  
      if (str2num(char(enabled)) == 1)  
      c=c+1;    
      ids(c)= {id};
      names(c)= {name}; 
      end
  
  end

end

end
