function Load

% Load
%
% Description:
%
% Syntax: Load
%
% In:
%
% Out:
%
% Updated: 2014-10-01
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

m = FT.study.StudyMap;

name = m.KeySelectionGUI('Study');

if ~isempty(name)
    FT_DATA.study_name = name;
    FT.UpdateGUI;
end