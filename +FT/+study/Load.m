function Load

% FT.study.Load
%
% Description: load a study (which really just hangs on to the study name
%              so that subjects can be loaded / averaged)
%
% Syntax: FT.study.Load
%
% In:
%
% Out:
%
% Updated: 2014-10-03
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

studies_dir = fullfile(FT.tools.BaseDir,'assets','studies');
study_list = fullfile(studies_dir,'ids.txt');

if ~isdir(studies_dir) || exist(study_list,'file')~=2
    msg = '[ERROR]: No studies have been created. Please create a study before loading.';
    FT.UserInput(msg,0,'title','No Studies Exist','button','OK');
    return;
end

m = FT.study.StudyMap;

name = m.KeySelectionGUI('Study');

if ~isempty(name)
    if any(~FT.tools.IsEmptyField({'data','power'}))
        resp = FT.UserInput('Do you want to clear the current dataset?',...
                        0,'button',{'Yes','Cancel'},'title','Clear Dataset?');
        if strcmpi(resp,'yes')
            FT.io.ClearDataset;
        end
    end
    if ~FT.tools.IsEmptyField('study_name')
        if ~strcmp(name,FT_DATA.study_name)
            FT_DATA.subject_name = '';
        end
    end
    FT_DATA.study_name = name;    
    FT.UpdateGUI;
end
