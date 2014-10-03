function study_dir = Dir(varargin)

% FT.study.Dir
%
% Description: returns the study directory for the current study
%
% Syntax: study_dir = FT.study.Dir([study_name]=current_study)
%
% In:
%       [study_name] - the name of the study, omit to use the currently loaded
%                      study
%
% Out:
%       study_dir - the full path to the current studies 'study' directory
%
% Updated: 2014-10-03
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

study_dir = '';

if isempty(varargin)
    if isfield(FT_DATA,'study_name') && ~isempty(FT_DATA.study_name)
        study = FT_DATA.study_name;
    end
elseif ischar(varargin{1}) && ~isempty(varargin{1})
    study = varargin{1};
else    
    return;
end

m = FT.study.StudyMap;
if m.IsKey(study)
    id = m.Get(study);
    study_dir = fullfile(FT.tools.BaseDir,'assets','studies',FT.study.FormatId(id));
end