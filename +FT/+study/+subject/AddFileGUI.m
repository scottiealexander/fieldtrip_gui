function AddFileGUI(varargin)

% FT.study.subject.AddFileGUI
%
% Description: graphically select a file to load / add to a subject's file list
%              if no subject has been loaded this just calls FT.io.Gui and exits
%
% Syntax: FT.study.subject.AddFileGUI
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

if ~isfield(FT_DATA,'subject_name') || isempty(FT_DATA.subject_name)
    % no subject has been loaded, assume the user justs wants to load some data
    % that will not be associtated with a subject / study
    FT.io.Gui;
    return;
end

name = FT_DATA.subject_name;
study = FT_DATA.study_name;

FT.io.Gui;

FT.study.subject.AddFile(name,FT_DATA.path.dataset);

FT_DATA.subject_name = name;
FT_DATA.study_name = study;

FT.UpdateGUI;