function Gui()

% FT.trials.define.Gui
%
% Description: get parameters for defining trials
%
% Syntax: FT.trials.define.Gui
%
% In: 
%
% Out: 
%
% See also: FT.trials.define.Run
%
% Updated: 2014-10-09
% Scottie Alexander
%
% Please send bug reports to: scottiealexander11@gmail.com

global FT_DATA;

%make sure we are ready to run
if ~FT.tools.Validate('define_trials','done',{'read_events'},'todo',{'segment_trials'},'warn',{'relabel_events'})
    return;
end

% Create list of types along with # occurances
events = FT.ReStruct(FT_DATA.event); % events
types = unique(events.type); % event types
strList = cellfun(@(x) [x ' (' num2str(sum(strcmpi(x,events.type))) ')'],types,'uni',false);

% Create struct array for holding trial definitions
cTmp = cell(numel(types),1); % empty placeholder
params = struct('type',cTmp,'pre',cTmp,'post',cTmp,'name',cTmp);

c = {{'text','string','Time-lock Event:'},...
     {'listbox','string',strList,'tag','type','callback',@ListCallback};...
     {'text','string','Time Before (s):'},...
     {'edit','string','','enable','on','tag','pre','valfun',@ValidateTimes};...
     {'text','string','Time After (s):'},...
     {'edit','string','','enable','on','tag','post','valfun',@ValidateTimes};...
     {'text','string','Condition Name:'},...
     {'edit','string',types{1},'tag','name','valfun',@ValidateName};...
     {'pushbutton','string','Define Condition','tag','define','validate',true,'Callback',@DefineCond},...
     {};...
     {'pushbutton','string','Done','validate',true},...
     {'pushbutton','string','Cancel','validate',false}...
	};

i = 0;
win = FT.tools.Win(c,'title','Define Trials','grid',false,'focus','type');
win.Wait;

if strcmpi('cancel',win.res.btn);
    return;
elseif strcmpi('done',win.res.btn)
    params = params(1:i);
    if (i == 0)
        return; % no trials defined
    end    
end

hMsg = FT.UserInput('Defining trials...',1);

me = FT.trials.define.Run(params);

if ishandle(hMsg)
    close(hMsg);
end

FT.ProcessError(me);

FT.UpdateGUI;

%-------------------------------------------------------------------------%
function DefineCond(obj,varargin)
    %we shouldn't have to set validate list this here...
    win.validate = true;
    b = win.FetchResult;    
    if b
        type = types{win.res.type};
        pre = win.res.pre;
        post = win.res.post;
        name = win.res.name;
        if isempty(name)
            name = type;
        end
        i = i+1;
        params(i) = struct('type',type,'pre',pre,'post',post,'name',name);

        strList(win.res.type) = [];
        types(win.res.type) = [];
        win.SetElementProp('type','String',strList);    
        win.SetElementProp('pre','Enable','off');
        win.SetElementProp('post','Enable','off');

        if isempty(types)
            CloseWin;
        else
            win.SetElementProp('name','String',types{1});
        end
    end
end
%-------------------------------------------------------------------------%
function CloseWin
    c = {{'text','string',''},...
         {'text','string','All events have trial definitions.'};...
         {'pushbutton','string','OK','tag','ok','validate',false},...
         {}};
    win.Close;
    w = FT.tools.Win(c,'title','Define Trials: Finished','grid',false,'focus','ok');
    w.Wait;
end
%-------------------------------------------------------------------------%
function ListCallback(varargin)
    k = win.GetElementProp('type','Value');
    win.SetElementProp('name','string',types{k});
end
%-------------------------------------------------------------------------%
function [b,val] = ValidateName(str,varargin)
    if ~any(strcmpi(str,{params(1:i).name}))
        b = true;
        val = str;
    else
        b = false;
        val = 'Condition name has already been used. Pick a unique condition name';
    end
end
%-------------------------------------------------------------------------%
function [b,val] = ValidateTimes(str,varargin)    
    t_pre = str2double(win.GetElementProp('pre','string'));
    t_post = str2double(win.GetElementProp('post','string'));
    
    b = false;
    if isnan(t_pre) || isnan(t_post)
        val = 'Both times must be numebers.';
    elseif ~(t_post > -t_pre)
        val = 'Trial length must be greater than zero.';
    else
        b = true;
        val = str2double(str);        
    end
end
%-------------------------------------------------------------------------%
end