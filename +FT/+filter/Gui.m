function Gui(varargin)

% FT.filter.Gui
%
% Description: get filtering parameters from user via a GUI
%
% Syntax: FT.filter.Gui
%
% In: 
%
% Out: 
%
% Updated: 2014-06-20
% Scottie Alexander
%
% See also: FT.filter.Run
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

%make sure we are ready to run
if ~FT.CheckStage('filter')
    return;
end

cfg = FT.tools.CFGDefault;
cfg.continuous       = 'yes';
cfg.channel          = 'all';
cfg.lpfilttype       = 'but';     %butterworth type filter
cfg.hpfilttype       = 'but';
cfg.hpfiltdir        = 'twopass'; %forward+reverse filtering
cfg.lpfiltdir        = 'twopass';
cfg.hpfiltord        = 6;
cfg.hpinstabilityfix = 'reduce';  %deal with filter instability
cfg.lpinstabilityfix = 'reduce';

fnyq = FT_DATA.data.fsample/2;

c = {...
    {'text','String','Select Channels to filter: (default: all)'},...
    {'pushbutton','String','Select','Callback',@SelectChannels};...
    {'text','String','Highpass Filter Frequency [Hz]:'},...
    {'edit','size',5,'tag','hp','valfun',{'inrange',.01,fnyq,false}};...
    {'text','String','Lowpass Filter Frequency [Hz]:'},...
    {'edit','size',5,'tag','lp','valfun',{'inrange',.01,fnyq,false}};...
    {'text','String','Notch Filter [Hz]:'},...
    {'edit','size',5,'tag','notch','valfun',{'inrange',.01,fnyq,false}};...
    {'pushbutton','String','Run'},...
    {'pushbutton','String','Cancel','validate',false};...
    };

win = FT.tools.Win(c);
uiwait(win.h);

if strcmpi(win.res.btn,'cancel')
    return;
else
    cfg.hpfilter = FT.tools.Ternary(isempty(win.res.hp),'no','yes');
    cfg.lpfilter = FT.tools.Ternary(isempty(win.res.lp),'no','yes');
    cfg.hpfreq   = win.res.hp;
    cfg.lpfreq   = win.res.lp;
    if ~isempty(win.res.notch)
        cfg.dftfilter = 'yes';
        cfg.dftfreq = win.res.notch;
    else
        cfg.dftfilter = 'no';
    end
end

hMsg = FT.UserInput('Filtering data...',1);

me = FT.filter.Run(cfg);

if ishandle(hMsg)
    close(hMsg);
end

if isa(me,'MException')
    FT.ProcessError(me);
end

FT.UpdateGUI;

%------------------------------------------------------------------------------%
function SelectChannels(obj,evt)
%allow user to select specific channels
    %set the height of the figure
    nChan = numel(FT_DATA.data.label);
    if nChan < 40
        hFig = FT.tools.Inch2Px(0.171)*nChan;
    else
        hFig = FT.tools.Inch2Px(5);
    end
    wFig = FT.tools.Inch2Px(2.5);

    %get the users selection
    [kChan,b] = listdlg('Name','Select Channels',...
       'ListString',FT_DATA.data.label,'ListSize',[wFig,hFig]);
    
   if b && ~isempty(kChan)
        cfg.channel = FT_DATA.data.label(kChan);
        set(obj,'String','Done');        
   end
end
%------------------------------------------------------------------------------%
end
