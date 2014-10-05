function name = Select

% FT.study.subject.Select
%
% Description:
%
% Syntax: name = FT.study.subject.Select
%
% In:
%
% Out:
%
% Updated: 2014-10-04
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

name = '';

if FT.tools.IsEmptyField('study_name')
    msg = '[ERROR]: No study has been loaded. Please load a study before loading a subject.';
    FT.UserInput(msg,0,'title','No Study Loaded','button','OK');
    return;
end

m = FT.study.SubjectMap;
name = m.KeySelectionGUI('Subject');