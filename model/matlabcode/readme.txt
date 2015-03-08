
Matlab Functions for HRTF Analysis and Adjustment

Implementations by Josef Hšlzl and Georgios Marentakis (IEM)

--------------------------------------------------------------------------------
IMPORTANT PATHS and FILES
--------------------------------------------------------------------------------
config.xml			XML-File to specify HRTF databases for the GUIs
--------------------------------------------------------------------------------
Graphical Interfaces
gui/view/gui.m			GUI for HRTF Databases
gui/model/gui_model.m		GUI for the HRTF Model
gui/exp/gui_task11.m		GUI for Listening Test / HRTF discrimination test
gui/exp/gui_task22.m		GUI for Listening Test / HRTF localization test
gui/anthro/gui_cor_model.m	GUI to obtain correlation between PCWs and anthropometric dimensions (in CIPIC database)
--------------------------------------------------------------------------------
Important Functions
functions/core/			Main Functions for the HRTF Model, e.g. use core_calc.m to compute the whole model
functions/core/test/		Input Matrix Parameter Testing (perform_test.m) that saves the results in a .mat file
functions/core/test/plot/	Plot functions that use the computed mat-Files
functions/exp/exp_create_data.m	Create Experiment Data for the Listening Tests
functions/db_analysis/		Several analysis functions
--------------------------------------------------------------------------------