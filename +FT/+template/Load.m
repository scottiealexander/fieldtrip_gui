function Load(strPath)
% FT.template.Load
%
% Description: load a template from a file. If strPath is provided, it is
% taken as the path for the template file to load. If it is not provided,
% the user is asked to browse for a file.
%
% Updated: 2014-10-13
% Peter Horak

global FT_DATA;

if (nargin < 1) || ~exist(strPath,'file')
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
end

%load the template
FT_DATA.path.template = strPath;
vars = load(strPath,'-mat');
FT_DATA.template = vars.template;

%associate the template with the current study if one is loaded
FT_DATA.organization.addnode('template',strPath);

FT.UpdateGUI;
end