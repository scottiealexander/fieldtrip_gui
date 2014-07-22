function Gui(varargin)

% FT.remove.Gui
%
% Description: inspect channels and mark for removal
%
% Syntax: FT.remove.Gui
%
% In: 
%
% Out: 
%
% Updated: 2014-07-18
% Peter Horak
%
% See also: FT.remove.Run

global FT_DATA;

%make sure we are ready to run
if ~FT.tools.Validate('remove_channel','todo',{'tfd'})
    return;
end

if ~FT_DATA.done.segment_trials %~iscell(FT_DATA.data)
    params.segmented = false;
    params.ch_rem = FT.tools.DataBrowser(FT_DATA.data.time{1},FT_DATA.data.trial{1},'trial',4,FT_DATA.data.label);
else
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
    
    params.segmented = true;
    params.ch_rem = FT.tools.DataBrowser(FT_DATA.data{i}.time{1},cat(3,FT_DATA.data{i}.trial{:}),'trial',4,FT_DATA.data{i}.label);
end

hMsg = FT.UserInput('Removing channels...',1);

me = FT.remove.Run(params);

if ishandle(hMsg)
    close(hMsg);
end

FT.ProcessError(me);

FT.UpdateGUI;

end
