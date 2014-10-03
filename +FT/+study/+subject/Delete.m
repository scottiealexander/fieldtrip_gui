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

m = FT.study.SubjectMap;
study = m.KeySelectionGUI('Subject','btn1','Delete');

if ~isempty(study)
    msg = ['Are you sure you want to delete the study: "' study '"?\n',...
           '[NOTE]: No data will be deleted, just the internal record of the study.']
    resp = FT.UserInput(msg,1,'title','Delete study?','button',{'Yes','Cancel'});
    if strcmpi(resp,'yes')        
        study_dir = FT.study.Dir(study);
        if isdir(study_dir)
            rmdir(study_dir,'s');
        end
        m.Remove(study);
        m.Save;
        if isfield(FT_DATA,'study_name') && strcmp(FT_DATA.study_name,study)
            if any(~FT.tools.IsEmptyField({'data','power'}))
                msg = 'Do you want to clear the current dataset?';
                resp = FT.UserInput(msg,0,'button',{'Yes','Cancel'},'title','Clear Dataset?');
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
