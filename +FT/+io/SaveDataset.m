function SaveDataset(saveas,saveasfile)

% FT.io.SaveDataset
%
% Description:
%
% Syntax: FT.io.SaveDataset(saveas)
%
% In:
%       saveas - true to prompt the user for a filepath, false to use the
%                current dataset's filepath
%
% Out:
%
% Updated: 2014-10-06
% Scottie Alexander

%URRGGG... this needs some serious work...
global FT_DATA;

strPathOut = FT_DATA.path.dataset;

% user selected 'save as', data already saved, or no current .set file exists
if saveas || FT_DATA.saved || isempty(strPathOut)
    if (nargin >= 2) && ~isempty(saveasfile) && ischar(saveasfile)
        strPathOut = saveasfile;
    else % let the user select the filepath with a GUI
        % the directory of the current .set file or the base directory
        if ~isempty(strPathOut)
            strPathDef = strPathOut;
        elseif ~isempty(FT_DATA.path.raw_file)
            [strDir,strName] = fileparts(FT_DATA.path.raw_file);
            strPathDef = fullfile(strDir,[strName '.set']);
        else
            strPathDef = fullfile(FT_DATA.path.base_directory,'datset.set');
        end

        % get the filepath the user wants
        [strName,strPath] = uiputfile('*.set','Save Dataset As...',strPathDef);

        % construct the file path
        if ~isequal(strName,0) && ~isequal(strPath,0)
            strPathOut = fullfile(strPath,strName);            
        else
            return; % user selected cancel
        end
    end
end

% force extension to be '.set'
strPathOut = regexprep(strPathOut,'\.[\w\-\+\.]+$','.set');

% get the new dataset path and name
FT_DATA.path.dataset = strPathOut;

% remove gui ,organization, and template fields as these can change
gui = FT_DATA.gui;
FT_DATA.gui = rmfield(FT_DATA.gui,{'hAx','hText','sizText'});
org = FT_DATA.organization;
FT_DATA = rmfield(FT_DATA,'organization');
template = FT_DATA.template;
FT_DATA = rmfield(FT_DATA,'template');
template_path = FT_DATA.path.template;
FT_DATA.path = rmfield(FT_DATA.path,'template');

FT_DATA.saved = true;

% save data
hMsg = FT.UserInput('Saving dataset, please wait...',1);

FT.io.WriteDataset(strPathOut);

if ishandle(hMsg)
    close(hMsg);
end

% restore gui ,organization, and templat
FT_DATA.gui = gui;
FT_DATA.organization = org;
FT_DATA.template = template;
FT_DATA.path.template = template_path;

FT_DATA.organization.addnode('dataset',strPathOut);

FT.UpdateGUI;

end