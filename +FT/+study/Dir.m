function study_dir = Dir

% FT.study.Dir
%
% Description: returns the study directory for the current study
%
% Syntax: study_dir = FT.study.Dir
%
% In:
%
% Out:
%       study_dir - the full path to the current studies 'study' directory
%
% Updated: 2014-10-01
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

if isfield(FT_DATA,'study_name')
    m = FT.study.StudyMap;
    id = m.Get(FT_DATA.study_name);
    study_dir = fullfile(FT.tools.BaseDir,'assets','studies',FT.study.FormatId(id));
else
    study_dir = '';
end