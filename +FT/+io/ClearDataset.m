function ClearDataset()

global FT_DATA;

%grab the fields that we will still need
gui  = FT_DATA.gui;
% base = FT_DATA.path.base_directory;
template_path = FT_DATA.path.template;
template = FT_DATA.template;

%renew the FT_DATA struct
FT_DATA = [];
FT.Prepare('type','data');

%add the fields back in 
gui.display_mode = 'init'; %set display mode back to initial
FT_DATA.gui = gui;
% FT_DATA.path.base_directory = base;
FT_DATA.path.template = template_path;
FT_DATA.template = template;

%update the GUI
FT.UpdateGUI;

end