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
% Updated: 2014-10-09
% Scottie Alexander
%
% See also: FT.resample.Run
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

%make sure we are ready to run
if ~FT.tools.Validate('resample','todo',{'define_trials'},'warn',{'read_events'})
    return;
end

params = struct;

c = {...
    {'text','String','New Sampling Rate [Hz]:'},...
    {'edit','tag','fr','valfun',{'inrange',1,FT_DATA.data.fsample-1,true}};...
    {'pushbutton','String','Run'},...
    {'pushbutton','String','Cancel','validate',false};...
    };

win = FT.tools.Win(c,'title','Resampling Parameters','grid',false);
uicontrol(win.GetElementProp('fr','h'));
uiwait(win.h);

if strcmpi(win.res.btn,'cancel')
    return;
else
    params.resamplefs = win.res.fr;

    if numel(FT_DATA.data.trial)~=1
        FT.UserInput('Cannot resample segmented data.',0);
        return;
    end
end

hMsg = FT.UserInput('Resampling data...',1,'button',false);

%resample data
me = FT.resample.Run(params);

if ishandle(hMsg)
    close(hMsg);
end

FT.ProcessError(me);

FT.UpdateGUI;

end
