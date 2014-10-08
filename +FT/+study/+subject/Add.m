function Add

% FT.study.subject.Add
%
% Description: add a subject to the current studies list of subjects
%
% Syntax: FT.study.subject.Add
%
% In:
%
% Out:
%
% Updated: 2014-10-03
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;
if ~isfield(FT_DATA,'study_name') || isempty(FT_DATA.study_name)z
    msg = '[ERROR]: No study has been loaded. Please load a study before adding a subject';
    FT.UserInput(msg,0,'title','No Study Loaded','button','OK');
    return;
end

m = FT.study.SubjectMap;

c = {{'text','string','Please enter a name for the subject:'},...
     {'edit','string','','tag','name','valfun',@CheckName};...
     {'text','string','Use filename for subject name:'},...
     {'checkbox','tag','auto','Callback',@CheckBox};...
     {'pushbutton','string','Load Dataset'},...
     {'pushbutton','string','Cancel','validate',false}...
    };

w = FT.tools.Win(c,'title','Add Subject','position',[0 0],'grid',false,'focus','name');
w.Wait;

if strcmpi(w.res.btn,'cancel')
    return;
else
    %get the path to the dataset file
    FT.io.Gui;

    %add subject and file
    AddSubject(w.res.name,w.res.auto);
    
    FT.UpdateGUI;
end

%-----------------------------------------------------------------------------%
function [b,msg] = CheckName(msg)
    b = false;
    if m.IsKey(msg)        
        msg = 'A subject by that name already exists. Please choose another name.';
    elseif isempty(msg) && ~w.GetElementProp('auto','value')
        msg = 'You must enter a subject name in order to load data.';
    else
        b = true;
    end
end
%-----------------------------------------------------------------------------%
function CheckBox(obj,varargin)
    if get(obj,'Value')
        w.SetElementProp('name','enable','off');
    else
        w.SetElementProp('name','enable','on');
    end
end
%-----------------------------------------------------------------------------%
function AddSubject(name,auto)

    if isfield(FT_DATA.path,'dataset') && ~isempty(FT_DATA.path.dataset)
        filepath = FT_DATA.path.dataset;
    elseif isfield(FT_DATA.path,'raw_file') && ~isempty(FT_DATA.path.raw_file)
        filepath = FT_DATA.path.raw_file;
    else
        %user canceled from FT.io.Gui, so we can't load or add a file,
        %but we should still considered the subject as created
        filepath = '';
    end

    if auto
        if ~isempty(filepath)
            [~,name] = fileparts(filepath);
        else
            %user canceled from FT.io.Gui but wanted us to use the filename
            %for the subject's name, we have no filename so assume they don't
            %want to create this subject
            return;
        end
    end

    id = m.GenerateId;
    m.Set(name,id);
    subj_list = fullfile(FT.study.Dir,[FT.study.FormatId(id) '.txt']);
    if exist(subj_list,'file')==2
        %if a conflict exists between the subj_list and files that actually exist
        %the subj_list gets presedence as ONLY lists are stored in the subj_list
        %NO data is stored there
        delete(subj_list);
    end

    if ~isempty(filepath)
        FT.study.subject.AddFile(id,filepath);
    end

    FT_DATA.subject_name = name;

    m.Save;    
end
%-----------------------------------------------------------------------------%
end