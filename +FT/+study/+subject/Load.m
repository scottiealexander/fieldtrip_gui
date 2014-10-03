function Load

% FT.study.subject.Load
%
% Description: load a subject and possibly a dataset from that subject
%
% Syntax: FT.study.subject.Load
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

if ~isfield(FT_DATA,'study_name') || isempty(FT_DATA.study_name)
    msg = '[ERROR]: No study has been loaded. Please load a study before loading a subject.';
    FT.UserInput(msg,0,'title','No Study Loaded','button','OK');
    return;
end

m = FT.study.SubjectMap;
name = m.KeySelectionGUI('Subject');

if isempty(name)
    return;
end

%i'm not totally sure we want to do this... but if we are to be consistent
%loading a subject *SHOULD* clear the current subject / dataset, it might
%get confusing if a dataset were loaded without a subject and then the user
%tried to load a subject, but i think it's still more consistent to clear
%the dataset in that case
FT.io.ClearDataset;

c = FT.study.subject.LoadFiles(m.Get(name));
cNames = cell(numel(c),1);
for k = 1:numel(c)
    [~,cNames{k}] = fileparts(c{k});
end

%we use a null file to aviod reading and writing to a real file
%this way we can use the KeySelectionGUI method to have our user'
%select a file name
mf = FT.study.Map('null');

%we are mapping filenames to full filepath for easy extraction below
mf.Set(cNames,c);

file = mf.KeySelectionGUI('File','btn2','Skip');
if ~isempty(file)
    %use our map to get the full path
    file = mf.Get(file);

    study_name = FT_DATA.study_name;

    %load the data!
    FT.io.Read(file);

    %make sure subject and study info are not cleared
    FT_DATA.subject_name = name;
    FT_DATA.study_name = study_name;
end

FT_DATA.subject_name = name;
FT.UpdateGUI;
