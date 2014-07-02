function ReadSetFile(strPath)
% ReadSetFile
%
% Description: read a FT dataset file
%
% Syntax: ReadSetFile(strPath)
%
% In:
%		strPath - the path to s FT .set file 
%
% Out: 
%
% Updated: 2014-06-27
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA

%load FiledTripGUI dataset file
sTmp = load(strPath,'-mat');
cFields = fieldnames(sTmp);

%save GUI params that are unique to the graphical session
tmp_gui = FT_DATA.gui;

%merge with the FT_DATA struct
for k = 1:numel(cFields)
    FT_DATA.(cFields{k}) = sTmp.(cFields{k});
end

%replace GUI params
FT_DATA.gui.hAx = tmp_gui.hAx;
FT_DATA.gui.hText = tmp_gui.hText;
FT_DATA.gui.sizText = tmp_gui.sizText;
FT_DATA.gui.screen_size = tmp_gui.screen_size;
FT_DATA.gui.display_fields = tmp_gui.display_fields;