function [path_file, all_files] = SelectFile(name)

% FT.study.subject.SelectFile
%
% Description: GUI to select a dataset file from a subject's filelist
%              and/or browse for a file to add/load
%
% Syntax: [path_file, all_files] = FT.study.subject.SelectFile(name)
%
% In:
%       name - the subject's name
%
% Out:
%
% Updated: 
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

path_file = '';
all_files = {};

m = FT.study.SubjectMap;
all_files = FT.study.subject.LoadFiles(m.Get(name));
nf = numel(all_files);

if ~nf
    msg = ['No subject currently exists. Please create a ',...
           'subject before trying to load.'];
    c = {{'text','string',msg};...
         {'pushbutton','string','OK','tag','ok_btn'}...
        };
    win = FT.tools.Win(c,'title','No subjects exist','focus','ok_btn');
    win.Wait;    
else
    all_names = cell(nf,1);
    for k = 1:nf
        [~,all_names{k}] = fileparts(all_files{k});
    end

    tmp_files = all_files;    

    c = {{'text','string','Select a file to load:'},...
         {'listbox','string',all_names,'tag','file'};...
         {'pushbutton','string','Browse for file','Callback',@FileBrowser},...
         {};...
         {'pushbutton','string','Load'},...
         {'pushbutton','string','Cancel'}...
        };

    win = FT.tools.Win(c,'title','Load a file:','focus','file');
    win.Wait;

    %only add browsed for files to all_files if the user selects load
    %as cancel should not result in files being added to the subject's
    %file list
    if strcmpi(win.res.btn,'load')
        path_file = tmp_files{win.res.file};
        all_files = tmp_files;
    end
end

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

    tmp_files{end+1,1} = strPath;
    [~,filename] = fileparts(strPath);
    all_names{end+1,1} = filename;

    win.SetElementProp('file','string',all_names);
    win.SetElementProp('file','value',numel(all_names));
    win.SetFocus('file');
    drawnow;
end
%-----------------------------------------------------------------------------%
end