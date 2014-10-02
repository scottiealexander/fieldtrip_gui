function ClearDataset()
% FT.io.ClearDataset
%
% Description: clear the existing dataset but maintain session specific data
%
% Syntax: FT.io.ClearDataset
%
% In: 
%
% Out: 
%
% Updated: 2014-10-01
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

%grab the fields that we will still need
gui  = FT_DATA.gui;
% base = FT_DATA.path.base_directory;
template_path = FT_DATA.path.template;
template = FT_DATA.template;
study_name = FT_DATA.study_name;

%renew the FT_DATA struct
FT_DATA = [];
FT.Prepare('type','data');

%add the fields back in
FT_DATA.gui = gui;
FT_DATA.gui.display_mode = 'init'; %set display mode back to initial
% FT_DATA.path.base_directory = base;
FT_DATA.path.template = template_path;
FT_DATA.template = template;
FT_DATA.study_name = study_name;

%update the GUI
FT.UpdateGUI;

end