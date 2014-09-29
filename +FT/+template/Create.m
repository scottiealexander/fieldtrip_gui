function Create()

global FT_DATA

% Find step when last file was read and start template there
kStart = find(cellfun(@(x) strcmpi(x.operation,'io'),FT_DATA.history),1,'first');

% Could not find step when data was loaded
if isempty(kStart)
    FT.UserInput('\bf[\color{red}ERROR\color{black}]: Cannot create template from history that does not include loading data.',1,'title','Error','button',{'OK'});
else
    FT_DATA.template = FT_DATA.history(kStart:end);
    FT_DATA.path.template = 'new.template';
end

FT.UpdateGUI;
end