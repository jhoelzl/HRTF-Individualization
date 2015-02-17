function [id1,name1,department1,status1,anthro1,fs1,db_path1,exp_sub1] =  config_get(search_id) 

fn = ['config.xml'];

dom = xmlread(fn); 
elems = dom.getElementsByTagName('db'); 

for i = 0:elems.getLength-1 
    
  % Read child items from "db" 
  id = char(elems.item(i).getElementsByTagName('id').item(0).getTextContent);
  name = strtrim(char(elems.item(i).getElementsByTagName('name').item(0).getTextContent));
  department  = strtrim(char(elems.item(i).getElementsByTagName('department').item(0).getTextContent));
  db_path  = strtrim(char(elems.item(i).getElementsByTagName('db_path').item(0).getTextContent));
  enabled = strtrim(char(elems.item(i).getElementsByTagName('enabled').item(0).getTextContent));  
  fs = strtrim(char(elems.item(i).getElementsByTagName('fs').item(0).getTextContent));  
  anthro = strtrim(char(elems.item(i).getElementsByTagName('anthro_data').item(0).getTextContent));
  exp_sub = strtrim(char(elems.item(i).getElementsByTagName('exp_sub').item(0).getTextContent));

  if (strcmp({search_id},{id}) == 1) | (strcmp({search_id},{name}) == 1)  
  status1=str2num(char(enabled)); 
  fs1=str2num(char(fs)); 
  id1= {id};
  name1= {name};
  department1= {department}; 
  db_path1= {db_path};db_path1 = db_path1{1};
  anthro1=str2num(char(anthro)); 
  exp_sub1=str2num(char(exp_sub)); 
  end

end

end