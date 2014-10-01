function Add

% FT.study.subject.Add
%
% Description:
%
% Syntax: FT.study.subject.Add
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
    msg = '[ERROR]: No study has been loaded. Please load a study before adding a subject';
    FT.UserInput(msg,0,'title','No Study Loaded','button','OK');
    return;
end

m = FT.study.SubjectMap;

c = {{'text','string','Please enter a name for the subject:'},...
     {'edit','string','','tag','name','valfun',@CheckName};...
     {'pushbutton','string','Load Dataset'},...
     {'pushbutton','string','Cancel','validate',false}...
    };

w = FT.tools.Win(c,'title','Add Subject','position',[0 0],'grid',false,'focus','name');
w.Wait;

if strcmpi(w.res.btn,'cancel')
    return;
elseif ~isempty(w.res.name)
    id = m.GenerateId;
    m.Set(w.res.name,id);
    subj_list = fullfile(FT.study.Dir,[FT.study.FormatId(id) '.txt']);
    if exist(subj_list,'file')==2
        %if a conflict exists between the subj_list and files that actually exist
        %the subj_list gets presedence as ONLY lists are stored in the subj_list
        %NO data is stored there
        delete(subj_list);
    end    
    m.Save;
    FT_DATA.subject_name = w.res.name;

    %now get the path to the dataset file
    FT.io.Gui;

    if isfield(FT_DATA.path,'dataset') && ~isempty(FT_DATA.path.dataset)
        FT.study.subject.AddFile(id,FT_DATA.path.dataset);
    end

    FT.UpdateGUI;
end

%-----------------------------------------------------------------------------%
function [b,msg] = CheckName(msg)
    if m.IsKey(msg)
        b = false;
        msg = 'A subject by that name already exists. Please choose another name.';
    else
        b = true;
    end
end
%-----------------------------------------------------------------------------%
end