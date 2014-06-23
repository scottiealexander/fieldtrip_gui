function Gui(varargin)

% FT.resample.Gui
%
% Description: get resampling parameters from user via a GUI
%
% Syntax: FT.resample.Gui
%
% In: 
%
% Out: 
%
% Updated: 2014-06-23
% Peter Horak
%
% See also: FT.resample.Run
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

%make sure we are ready to run
if ~FT.CheckStage('resample')
    return;
end

cfg = FT.tools.CFGDefault;
cfg.detrend = 'no'; %we'll have to check on these
cfg.demean  = 'no';

c = {...
    {'text','String','New Sampling Rate [Hz]:'},...
    {'edit','size',5,'tag','fr','valfun',{'inrange',1,FT_DATA.data.fsample-1,false}};...
    {'pushbutton','String','Run'},...
    {'pushbutton','String','Cancel'};...
    };

win = FT.tools.Win(c);
uiwait(win.h);

if strcmpi(win.res.btn,'cancel')
    return;
elseif ~isempty(win.res.fr)
    cfg.resamplefs = win.res.fr;

    if numel(FT_DATA.data.trial)~=1
        FT.UserInput('Cannot resample segmented data.',0);
        return;
    end
else
    return;
end

hMsg = FT.UserInput('Resampling data...',1,'button',false);

%resample data
me = FT.resample.Run(cfg);

if ishandle(hMsg)
    close(hMsg);
end

if isa(me,'MException')
    FT.ProcessError(me);
end

FT.UpdateGUI;

end
