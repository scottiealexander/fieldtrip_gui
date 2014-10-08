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
            strDir = fileparts(strPathOut);
        else
            strDir = FT_DATA.path.base_directory;
        end

        % get the filepath the user wants
        strPathDef = fullfile(strDir,[FT_DATA.current_dataset '.set']);
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
[~,FT_DATA.current_dataset] = fileparts(strPathOut);

% remove template and gui fields as these can change
gui = FT_DATA.gui;
FT_DATA.gui = rmfield(FT_DATA.gui,{'hAx','hText','sizText'});
template = FT_DATA.template;
FT_DATA = rmfield(FT_DATA,'template');
template_path = FT_DATA.path.template;
FT_DATA.path = rmfield(FT_DATA.path,'template');

FT_DATA.saved = true;

% save data
hMsg = FT.UserInput('Saving dataset, plese wait...',1);

FT.io.WriteDataset(strPathOut);

if ishandle(hMsg)
    close(hMsg);
end

% restore template and gui fields
FT_DATA.gui = gui;
FT_DATA.template = template;
FT_DATA.path.template = template_path;

%if a 'study' and a 'subject' is loaded, add the output path to that subject's file list
if isfield(FT_DATA,'study_name') && ~isempty(FT_DATA.study_name)
    if isfield(FT_DATA,'subject_name') && ~isempty(FT_DATA.subject_name)
        FT.study.subject.AddFile(FT_DATA.subject_name,strPathOut);
    end
end

FT.UpdateGUI;

end