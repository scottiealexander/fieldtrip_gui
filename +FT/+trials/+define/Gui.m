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
% See also: FT.filter.Run
%
% Updated: 2014-08-19
% Peter Horak

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
     {'listbox','string',strList,'size',[3,1],'tag','type'};...
     {'text','string','Time Before (s):'},...
     {'edit','size',5,'string','','enable','on','tag','pre','valfun',@ValidateTimes};...
     {'text','string','Time After (s):'},...
     {'edit','size',5,'string','','enable','on','tag','post','valfun',@ValidateTimes};...
     {'text','string','Condition Name:'},...
     {'edit','size',5,'string','','tag','name'};...
     {'pushbutton','string','Define Condition','tag','define','validate',true},...
     {'text','string',''};...
     {'pushbutton','string','Done','validate',true},...
     {'pushbutton','string','Cancel','validate',false}...
	};

i = 0;
while true
    win = FT.tools.Win(c,'title','Define Trials','grid',false,'focus','type');
    win.Wait;
    
    if strcmpi('cancel',win.res.btn);
        return;
    elseif strcmpi('done',win.res.btn)
        params = params(1:i);
        break;
    else
        % Get trial parameters for an event
        type = types{win.res.type};
        pre = win.res.pre;
        post = win.res.post;
        name = win.res.name;
        if isempty(name)
            name = type;
        end
        i = i+1;
        params(i) = struct('type',type,'pre',pre,'post',post,'name',name);
        
        % Remove the event from the list of available ones
        c{1,2}{3} = setdiff(c{1,2}{3},c{1,2}{3}(win.res.type)); % (listbox->string)
        types = setdiff(types,types(win.res.type));

        % Use parameters from this event as the default for the next
        c{2,2}{5} = num2str(pre); % (pre->string)
        c{3,2}{5} = num2str(post); % (post->string)
        c{2,2}{7} = 'off';
        c{3,2}{7} = 'off';
        
        % No more trials to define, either return the paremters or cancel
        if isempty(types)
            c = {{'text','string',''},...
                 {'text','string','All events have trial definitions.'};...
                 {'pushbutton','string','Done','tag','type','validate',true},...
                 {'pushbutton','string','Cancel','validate',false}};
        end
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