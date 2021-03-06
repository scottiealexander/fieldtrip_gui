function Gui(varargin)

% FT.trials.reject.Gui
%
% Description: inspect trials and mark for removal
%
% Syntax: FT.trials.reject.Gui
%
% In: 
%
% Out: 
%
% Updated: 2014-07-18
% Peter Horak
%
% See also: FT.trials.reject.Run


global FT_DATA;

if ~FT.tools.Validate('reject_trials','done',{'segment_trials'},'todo',{'average'})
    return;
end

condition_names = cellfun(@(x) x.name,FT_DATA.epoch,'uni',false);
c = {{'text','string','Condition #:'},...
     {'listbox','String',condition_names,'tag','condition'};...
     {'pushbutton','string','Continue'},...
     {'pushbutton','string','Cancel'}...
    };
win = FT.tools.Win(c,'title','Condition Selection');
uicontrol(win.GetElementProp('condition','h'));
uiwait(win.h);

if ~strcmpi(win.res.btn,'continue')
    return; % cancel
end
i = win.res.condition;

params.condition = i;
params.tr_rem = FT.tools.DataBrowser(FT_DATA.data{i}.time{1},cat(3,FT_DATA.data{i}.trial{:}),'channel',FT_DATA.data{i}.label);

if ~isempty(params.tr_rem)
    hMsg = FT.UserInput('Removing trials...',1);

    me = FT.trials.reject.Run(params);

    if ishandle(hMsg)
        close(hMsg);
    end

    FT.ProcessError(me);
end

FT.UpdateGUI;

end
