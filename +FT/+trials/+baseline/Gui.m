function varargout = Gui(varargin)

% FT.trials.baseline.Gui
%
% Description: get parameters for baseline correction
%
% Syntax: FT.trials.baseline.Gui
%
% In: 
%
% Out:
%
% See also: FT.trials.baseline.Run
%
% Updated: 2014-06-27
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;
varargout{1} = [];

%make sure we are ready to run
if ~FT.tools.Validate('baseline_trials','todo',{'average'})%,'done',{'segment_trials'})
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

if strcmpi(win.res.btn,'run') && ~any(isnan(cfg.baselinewindow))
    if ~nargout
        
        hMsg = FT.UserInput('Running baseline correction...',1);

        me = FT.trials.baseline.Run(cfg);
        
        if ishandle(hMsg)
            close(hMsg);
        end
        
        FT.ProcessError(me);
        FT.UpdateGUI;
    else
        varargout{1} = cfg;
    end    
else
    varargout{1} = []; 
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
    validwin = [min(time),max(time)];
    
    if isnan(tstart) || isnan(tend) || tstart >= tend
        b = false;
        val = ['\bf[\color{yellow}WARNING\color{black}]: Invalid value given.\n\n',...
                'Start and End times MUST be numeric, and Start must come before End.'];
% *** TODO: Fix? ***
    elseif strncmpi(ref,'trial',5) && strcmpi(FT_DATA.epoch{1}.ifo.format,'timelock')
        %baseline is given relative to trial start but segments are
        %defined relative to an event           
        cfg.baselinewindow = cfg.baselinewindow - FT_DATA.epoch{1}.ifo.pre;
        validwin = validwin + FT_DATA.epoch{1}.ifo.pre;
    end

    %segments are defined relative to a timelocking event
    if b && (cfg.baselinewindow(1) < min(time) || cfg.baselinewindow(2) > max(time))
        b = false;
        val = ['\bf[\color{yellow}WARNING\color{black}]: Invalid time range.\n\n',...
                  'The baseline start and/or end times that you ',...
                  'entered fall outside the time range of the trials [',...
                  num2str(validwin(1)) ',' num2str(validwin(2)) '].']; 
    end 
    
    %make cfg invalid if fail (so will not run if user closes the window)
    if ~b
        cfg.baselinewindow = [NaN,NaN];
    end
    val = strrep(val,'\n',char(10));
end
%-----------------------------------------------------------------------------%
end