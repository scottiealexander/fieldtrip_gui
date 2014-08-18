function Load()

global FT_DATA;

%move to the analysis base dir
strDirCur = pwd;
if isdir(FT_DATA.path.base_directory)        
    cd(FT_DATA.path.base_directory);       
end

%user selects file
[strName,strPath] = uigetfile('*.template','Load Template');

%construct the file path
if isequal(strName,0) || isequal(strPath,0)
    return %user selected cancel
else
    strPath = fullfile(strPath,strName);
end

%move back to the original directory
cd(strDirCur);

%load the template
FT_DATA.path.template = strPath;
vars = load(strPath,'-mat');
FT_DATA.template = vars.template;

FT.UpdateGUI;
end