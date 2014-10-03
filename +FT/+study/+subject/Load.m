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

cFiles = FT.study.subject.LoadFiles(m.Get(name));
nf = numel(cFiles);

if ~nf
    msg = ['No subject currently exists. Please create a ',...
           'subject before trying to load.'];
    c = {{'text','string',msg};...
         {'pushbutton','string','OK','tag','ok_btn'}...
        };
    win = FT.tools.Win(c,'title','No subjects exist','focus','ok_btn');
    win.Wait;    
else
    cNames = cell(nf,1);
    for k = 1:nf
        [~,cNames{k}] = fileparts(cFiles{k});
    end

    c = {{'text','string','Select a file to load:'},...
         {'listbox','string',cNames,'tag','file'};...
         {'pushbutton','string','Browse for file','Callback',@FileBrowser},...
         {};...
         {'pushbutton','string','Load'},...
         {'pushbutton','string','Cancel'}...
        };

    win = FT.tools.Win(c,'title','Load a file:','focus','file');
    win.Wait;

    file = cFiles{win.res.file};
    if strcmpi(win.res.btn,'load') && exist(file,'file') == 2
        study_name = FT_DATA.study_name;

        %load the data!
        FT.io.Read(file);

        %make sure the subject's filelist gets updated if the user
        %browsed for a file
        FT.study.subject.AddFile(name,cFiles);

        %make sure study name didn't get cleared        
        FT_DATA.study_name = study_name;
    end

    FT_DATA.subject_name = name;
end

FT.UpdateGUI;

%-----------------------------------------------------------------------------%
function FileBrowser(obj,varargin)
    dir_cur = pwd;
    cd('..');

    %user-selected file
    [strName,strPath] = uigetfile('*','Load File');

    % move back to the original directory
    cd(dir_cur);

    if isequal(strName,0) || isequal(strPath,0)
        return; % user selected cancel
    end

    strPath = fullfile(strPath,strName);

    cFiles{end+1,1} = strPath;
    [~,filename] = fileparts(strPath);
    cNames{end+1,1} = filename;

    win.SetElementProp('file','string',cNames);
    win.SetElementProp('file','value',numel(cNames));
    win.SetFocus('file');
end
%-----------------------------------------------------------------------------%
end