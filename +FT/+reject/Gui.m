function Gui(varargin)

% FT.reject.Gui
%
% Description: inspect trials and mark for removal
%
% Syntax: FT.reject.Gui
%
% In: 
%
% Out: 
%
% Updated: 2014-07-18
% Peter Horak
%
% See also: FT.reject.Run


global FT_DATA;

if ~FT.CheckStage('reject_trials')
    return;
end

if ~FT_DATA.done.segmentation
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
params.tr_rem = FT.tools.DataBrowser(FT_DATA.data{i}.time{1},cat(3,FT_DATA.data{i}.trial{:}),'channel',4,FT_DATA.data{i}.label);

hMsg = FT.UserInput('Removing trials...',1);

me = FT.reject.Run(params);

if ishandle(hMsg)
    close(hMsg);
end

FT.ProcessError(me);

FT.UpdateGUI;

end
