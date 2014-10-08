function Delete(item_type)

% FT.study.Delete
%
% Description: delete a study from the master list of studies or delete a
%              subject from the current studies lists of subjects
%
% Syntax: FT.study.Delete(item_type)
%
% In:
%       item_type - the type of construct to delete, one of:
%                      'study': delete the internal record of a study
%                      'subject': delete the internal record of a subject
%
% Out:
%
% Updated: 2014-10-03
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

item_type = [upper(item_type(1)) item_type(2:end)];
del_study = strcmpi(item_type,'study');

if del_study
    studies_dir = fullfile(FT.tools.BaseDir,'assets','studies');
    if ~isdir(studies_dir)
        mkdir(studies_dir);
    end
    m = FT.study.StudyMap;
else
    m = FT.study.SubjectMap;
end

item = m.KeySelectionGUI(item_type,'btn1','Delete');

if ~isempty(item)
    msg = ['\bfAre you sure you want to delete the ' lower(item_type) ': "' item '"?\n',...
           '[NOTE]: No data will be deleted, just the internal record of the ' lower(item_type) '.'];
    resp = FT.UserInput(msg,1,'title',['Delete ' item_type '?'],'button',{'Yes','Cancel'});
    if strcmpi(resp,'yes')
        if del_study
            study_dir = FT.study.Dir(item);
            if isdir(study_dir)
                rmdir(study_dir,'s');
            end
        else
            subj_file = FT.study.subject.File(m.Get(item));
            if exist(subj_file,'file') == 2
                delete(subj_file);
            end
        end
        m.Remove(item);
        m.Save;
        field = [lower(item_type) '_name'];
        if isfield(FT_DATA,field) && strcmp(FT_DATA.(field),item)
            if any(~FT.tools.IsEmptyField({'data','power'}))
                msg = 'Do you want to clear the current dataset?';
                resp = FT.UserInput(msg,0,'button',{'Yes','Cancel'},'title','Clear Dataset?');
                if strcmpi(resp,'yes')
                    FT.io.ClearDataset;
                end
            end
            if del_study
                FT_DATA.study_name = '';
                FT_DATA.template = [];
                FT_DATA.path.template = '';
            end
            FT_DATA.subject_name = '';
        end
    end
end

FT.UpdateGUI;
