function ClearDataset(varargin)
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
% Updated: 2014-10-06
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

opt = FT.ParseOpts(varargin,...
    'cleartemplate' , false ...
    );

% if any(~FT.tools.IsEmptyField({'data','power'})) && ~FT_DATA.saved
%     msg = 'The current dataset has unsaved changes, would you like to save them?';
%     resp = FT.UserInput(msg,1,'title','Usaved changes','button',{'Yes','No'});
%     if strcmpi(resp,'yes')
%         FT.io.SaveDataset(true);
%     end
% end

%grab the fields that we will still need
gui  = FT_DATA.gui;
base = FT_DATA.path.base_directory;
if ~opt.cleartemplate
    template_path = FT_DATA.path.template;
    template = FT_DATA.template;
end
organization = FT_DATA.organization;

%renew the FT_DATA struct
FT_DATA = [];
FT.Prepare('type','data');

%add the fields back in
FT_DATA.gui = gui;
FT_DATA.gui.display_mode = 'init'; %set display mode back to initial
FT_DATA.path.base_directory = base;
if ~opt.cleartemplate
    FT_DATA.path.template = template_path;
    FT_DATA.template = template;
end
FT_DATA.organization = organization;

%update the GUI
FT.UpdateGUI;

end