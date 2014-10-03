function Delete

% FT.study.Delete
%
% Description: delete a study from the master list of studies
%
% Syntax: FT.study.Delete
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
if ~isdir(studies_dir)
    mkdir(studies_dir);
end

m = FT.study.StudyMap;
study = m.KeySelectionGUI('Study','btn1','Delete');

if ~isempty(study)
    resp = FT.UserInput(['Are you sure you want to delete the study "' study '"?'],1,...
        'title','Delete study?','button',{'Yes','Cancel'});
    if strcmpi(resp,'yes')        
        study_dir = FT.study.Dir(study);
        if isdir(study_dir)
            rmdir(study_dir,'s');
        end
        m.Remove(study);
        m.Save;
        if isfield(FT_DATA,'study_name') && strcmp(FT_DATA.study_name,study)
            if any(~FT.tools.IsEmptyField({'data','power'}))
                resp = FT.UserInput('Do you want to clear the current dataset?',...
                                0,'button',{'Yes','Cancel'},'title','Clear Dataset?');
                if strcmpi(resp,'yes')
                    FT.io.ClearDataset;
                end
            end
            FT_DATA.study_name = '';
            FT_DATA.subject_name = '';
        end
    end
end

FT.UpdateGUI;
