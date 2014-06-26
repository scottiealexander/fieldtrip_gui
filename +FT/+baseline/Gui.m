function varargout = Gui(varargin)

% FT.baseline.Gui
%
% Description: get parameters for baseline correction
%
% Syntax: FT.baseline.Gui
%
% In: 
%
% Out:
%
% See also: FT.baseline.Run
%
% Updated: 2014-06-26
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

%make sure we are ready to run
if ~FT.CheckStage('baseline')
    return;
end

cfg = FT.tools.CFGDefault(struct('demean','yes','baselinewindow',[NaN NaN]));

cList = {'Event','Trial Start'};

c = {...
    {'text','String','Window Start: (seconds)'},...
    {'edit','size',5,'tag','wstart'};...
    {'text','String','Window End: (seconds)'},...
    {'edit','size',5,'tag','wend'};...
    {'text','String','Times are relative too:'},...
    {'listbox','String',cList,'tag','ref'};...
    {'pushbutton','String','Run','tag','run','valfun',@Validate},...
    {'pushbutton','String','Skip','validate',false};...
    };

win = FT.tools.Win(c,'title','Baseline Correction','grid',true,'focus','wstart');
win.Wait;

if strcmpi(win.res.btn,'cancel')
    varargout{1} = [];
else
    if ~nargout
        FT.baseline.Run(cfg);
    else
        varargout{1} = cfg;
    end
end

%-----------------------------------------------------------------------------%
function [b,val] = Validate(obj,varargin)
    tstart = str2double(win.GetElementProp('wstart','String'));
    tend = str2double(win.GetElementProp('wend','String'));
    ref  = cList{win.GetElementProp('ref','Value')};
    b = true;
    val = '';
    cfg.baselinewindow = [tstart tend];

    time = FT.tools.GetParameter('data','time');
    if iscell(time)
        time = time{1};
    end

    if isnan(tstart) || isnan(tend) || tstart >= tend
        b = false;
        val = ['\bf[\color{yellow}WARNING\color{black}]: Invalid value given.\n',...
                'Start and End times MUST be numeric,\nand Start must come before End.'];
    elseif strncmpi(ref,'trial',5) && strcmpi(FT_DATA.history.segmentation.format,'timelock')       
        %baseline is given relative to trial start but segments are
        %defined relative to an event           
        cfg.baselinewindow = cfg.baselinewindow - FT_DATA.history.segmentation.pre;     
    end

    %segments are defined relative to a timelocking event
    if b && (cfg.baselinewindow(1) < min(time) || cfg.baselinewindow(2) > max(time))
        b = false;
        val = ['\bf[\color{yellow}WARNING\color{black}]: The baseline start and/or end times that you ',...
                  'entered fall outside the time range of the trials.\n\nPlease check your input and try again.']; 
    end 
    
    val = strrep(val,'\n',char(10));
end
%-----------------------------------------------------------------------------%
end