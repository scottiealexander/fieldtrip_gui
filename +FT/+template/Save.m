function Save()
% FT.template.Save
%
% Description: save the current template to a file
%
% Updated: 2014-10-13
% Peter Horak

global FT_DATA;

if isempty(FT_DATA.template) || isempty(FT_DATA.path.template)
     FT.UserInput('No current template! Please create or load a template.',1,'title','Notice','button',{'OK'});
     return;
end

%user selects file
strPathDef = FT_DATA.path.template;%default
[strName,strPath] = uiputfile('*.template','Save Template',strPathDef);

%construct the file path
if isequal(strName,0) || isequal(strPath,0)
    return %user selected cancel
else
    strPath = fullfile(strPath,strName);
end

%save the template
save(strPath,'-struct','FT_DATA','template');
FT_DATA.path.template = strPath;

%associate the template with the current study if one is loaded
FT_DATA.organization.addnode('template',strPath);

FT.UpdateGUI;
end