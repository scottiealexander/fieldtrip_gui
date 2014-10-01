function m = StudyMap

% StudyMap
%
% Description: construct a study map, mapping all study names to their ids
%
% Syntax: m = StudyMap
%
% In:
%
% Out:
%       m - a study map, mapping study names to ids
%
% Updated: 2014-10-01
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

studies_dir = fullfile(FT.tools.BaseDir,'assets','studies');
study_list = fullfile(studies_dir,'ids.txt');

m = FT.study.Map(study_list);