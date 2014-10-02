function subj_file = File(id)

% FT.study.subject.File
%
% Description: returns the full path to the current subject's file list
%
% Syntax: subj_file = FT.study.subject.File(id)
%
% In:
%       id - the current subject's id or name
%
% Out:
%       subj_file - the full path to the current subject's file list
%
% Updated: 2014-10-01
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

if ischar(id)
    m = FT.study.SubjectMap;
    tmp = m.Get(id);
    if isempty(tmp)
        error('No subject with name %s can be found',id);
    else
        id = tmp;
    end
end
subj_file = fullfile(FT.study.Dir,[FT.study.FormatId(id) '.txt']);