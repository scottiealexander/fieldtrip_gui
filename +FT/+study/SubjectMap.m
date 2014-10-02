function m = SubjectMap

% FT.study.SubjectMap
%
% Description: construct a subject map, mapping all subject names to their ids
%
% Syntax: m = FT.study.SubjectMap
%
% In:
%
% Out:
%       m - a subject map, mapping subject names to ids
%
% Updated: 2014-10-01
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

subj_list = fullfile(FT.study.Dir,'ids.txt');
m = FT.study.Map(subj_list);