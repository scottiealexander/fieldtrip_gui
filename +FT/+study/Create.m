function Create

% Create
%
% Description:
%
% Syntax: Create
%
% In:
%
% Out:
%
% Updated: 2014-09-29
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

studies_dir = fullfile(FT.tools.BaseDir,'assets','studies');
if ~isdir(studies_dir)
    mkdir(studies_dir);
end

m = FT.study.StudyMap;

c = {{'text','string','Please enter a name for the study:'},...
     {'edit','string','','tag','name','valfun',@CheckName};...
     {'pushbutton','string','Create'},...
     {'pushbutton','string','Cancel','validate',false}...
    };

w = FT.tools.Win(c,'title','Create Study','position',[0 0],'grid',false,'focus','name');
w.Wait;

if strcmpi(w.res.btn,'cancel')
    return;
elseif ~isempty(w.res.name)
    id = m.GenerateId;
    m.Set(w.res.name,id);
    study_dir = fullfile(FT.tools.BaseDir,'assets','studies',FT.study.FormatId(id));
    if isdir(study_dir)
        %if a conflict exists between the study_list and directories that actually exist
        %the study_list gets presedence as ONLY lists are stored in the study_dir
        %NO data is stored there
        rmdir(study_dir,'s');
    end
    mkdir(study_dir);
    m.Save;
    FT_DATA.study_name = w.res.name;

    FT.UpdateGUI;
end

%-----------------------------------------------------------------------------%
function [b,msg] = CheckName(msg)
    if m.IsKey(msg)
        b = false;
        msg = 'A study by that name already exists. Please choose another name.';
    else
        b = true;
    end
end
%-----------------------------------------------------------------------------%
end