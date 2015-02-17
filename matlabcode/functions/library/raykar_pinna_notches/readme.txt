%--------------------------------------------------------------------------------------------------- 
% EXTRACTING THE FREQUENCIES OF THE PINNA SPECTRAL NOTCHES 
%--------------------------------------------------------------------------------------------------- 
%--------------------------------------------------------------------------------------------------- 
% Author     :     Vikas.C.Raykar 
% Date       :     24 Feb 2005
% Contact    :     vikas@umiacs.umd.edu
%--------------------------------------------------------------------------------------------------- 

%--------------------------------------------------------------------------------------------------- 
% REFERENCE :
%--------------------------------------------------------------------------------------------------- 

 "Extracting the frequencies of the pinna spectral notches in measured head related impulse responses"
 Vikas C. Raykar, Ramani Duraiswami, and B. Yegnanarayana, The Journal of the Acoustical Society of 
 America, Volume 118, Issue 1, pp. 364-374,  July 2005.   

 [A more detailed version available as CS-TR-4609]

 Can be downloaded from:
 
 http://cvl.umiacs.umd.edu/users/vikas/publications/papers.html
 
%--------------------------------------------------------------------------------------------------- 
% DIRECTORY CONTENTS :
%--------------------------------------------------------------------------------------------------- 

readme.txt    
Algorithm_1.m 
Algorithm_1_driver.m 
lmin.m        
CIPIC_database_path.m 
get_CIPIC_HRIR.m        
get_CIPIC_HRIR_onset.m  
cipic

%--------------------------------------------------------------------------------------------------- 
% DESCRIPTION OF THE FILES
%--------------------------------------------------------------------------------------------------- 

Algorithm_1.m

%--------------------------------------------------------------------------------------------------- 
%This function returns the frequencies of the pinna spectral notches.
%--------------------------------------------------------------------------------------------------- 

Algorithm_1_driver.m

%--------------------------------------------------------------------------------------------------- 
%This script shows how to use the fucntion Algorithm_1.m.
%--------------------------------------------------------------------------------------------------- 

lmin.m ( by Serge Koptenko, Guigne International Ltd.)

Fucntion to find the local minima.

%--------------------------------------------------------------------------------------------------- 
%FUNCTIONS TO ACCESS THE CIPIC DATABASE.
%--------------------------------------------------------------------------------------------------- 

The CIPIC database can be downloaded from http://interface.cipic.ucdavis.edu/CIL_html/CIL_HRTF_database.htm
A sample HRIR for subject 10 has been included in the directory cipic.

CIPIC_database_path.m
%--------------------------------------------------------------------------------------------------- 
% This is the diectory which contains the CIPIC HRIR database.
% Modify this to point to your database.
%--------------------------------------------------------------------------------------------------- 

get_CIPIC_HRIR.m

%--------------------------------------------------------------------------------------------------- 
% This function returns the Head Related Impulse Response (HRIR) and the
% Head Related Transfer Function (HRTF) of a particular pinna for a given
% elevation and azimuth in the CIPIC HRIR database.
%--------------------------------------------------------------------------------------------------- 

get_CIPIC_HRIR_onset.m

%--------------------------------------------------------------------------------------------------- 
% This function returns the onset time of the Head Related Impulse Response (HRIR) of a particular
% pinna for a given elevation and azimuth in the CIPIC HRIR database.
%--------------------------------------------------------------------------------------------------- 
