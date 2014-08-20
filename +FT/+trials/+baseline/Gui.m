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

%make sure we are ready to run
if ~FT.tools.Validate('baseline_trials','todo',{'average'},'done',{'segment_trials'})
    return;
end

varargout{1} = [];
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

% If ths user presses run, it fails on invalid input, and then the windows
% is closed it will look like run was pressed (thus the second condition)
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
end

%-----------------------------------------------------------------------------%
function [b,val] = Validate(~,varargin)
    % Is the baseline window relative to an event or trial start
    ref  = cList{win.GetElementProp('ref','Value')};

    % Get the baseline time window
    tstart = str2double(win.GetElementProp('wstart','String'));
    tend = str2double(win.GetElementProp('wend','String'));
    baselinewin = [tstart tend];
    
    % Get the trial time window
    time = FT.tools.GetParameter('data','time');
    if iscell(time)
        time = time{1};
    end
    validwin = [min(time),max(time)];
    
    % Baseline is given relative to trial start but segments are defined relative to an event           
    if strcmpi('trial start',ref)
        baselinewin = baselinewin + min(time);
        validwin = validwin - min(time);
    end
    
    % Invalid baseline window
    if any(isnan(baselinewin)) || baselinewin(1) > baselinewin(2)
        b = false;
        val = ['\bf[\color{yellow}WARNING\color{black}]: Invalid value(s) given.\n\n',...
            'Start and end times MUST be numeric, and Start must come before End.'];
    % Baseline window extends beyond the trial window
    elseif (baselinewin(1) < min(time) || baselinewin(2) > max(time))
        b = false;
        val = ['\bf[\color{yellow}WARNING\color{black}]: Invalid time range.\n\n',...
            'The baseline start and/or end times entered fall outside the ',...
            'time range of the trials [' num2str(validwin) '].']; 
    % Valid baseline window
    else
        b = true;
        val = '';
        cfg.baselinewindow = baselinewin;
    end

    val = strrep(val,'\n',char(10));
end
%-----------------------------------------------------------------------------%
end