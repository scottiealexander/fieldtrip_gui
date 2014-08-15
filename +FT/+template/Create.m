function Create()

global FT_DATA

FT_DATA.path.template = 'new.template';%fullfile(pwd,'new.template');
FT_DATA.template = FT_DATA.history;

FT.UpdateGUI;
end