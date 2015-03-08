function [gender,hairstyle,descr] = ircam_xml(subject) 

% Get File name by subject

subject = sprintf('%02.0f',subject);

fn = ['../../db/IRCAM/INFO/IRC_10',subject,'.xml'];



% Den DOM-Baum auslesen 
dom = xmlread(fn); 

% Alle PhysValue-Elemente ermitteln 
elems = dom.getElementsByTagName('Subject'); 


% Alle gefundenen Elemente durchlaufen 
for i = 0:elems.getLength-1 
  % Den Wert des Values auslesen 
  id = char(elems.item(i).getElementsByTagName('ID').item(0).getTextContent);
  
  gender = strtrim(char(elems.item(i).getElementsByTagName('Sex').item(0).getTextContent));
  
  hairstyle = strtrim(char(elems.item(i).getElementsByTagName('Hairstyle').item(0).getTextContent));
  
  descr = strtrim(char(elems.item(i).getElementsByTagName('Description').item(0).getTextContent));
  
  
  
  % Die Einheit des Values auslesen
  %c{i+1, 2} = char(elems.item(i).getAttribute('ID'));
end





end