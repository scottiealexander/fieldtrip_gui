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
% Updated: 2014-10-07
% Scottie Alexander

global FT_DATA;

%make sure we are ready to run
if ~nargout
    if ~FT.tools.Validate('baseline_trials','todo',{'average'},'done',{'segment_trials'})
        return;
    end
end

varargout{1} = [];
cfg = FT.tools.CFGDefault(struct('demean','yes','baselinewindow',[NaN NaN]));
cList = {'Event','Trial Start'};

c = {...
    {'text','String','Window Start: (seconds)'},...
    {'edit','size',5,'tag','wstart'};...
    {'text','String','Window End: (seconds)'},...
    {'edit','size',5,'tag','wend'};...
    {'text','String','Times are relative to:'},...
    {'listbox','String',cList,'tag','ref'};...
    {'pushbutton','String','Run','tag','run','valfun',@Validate},...
    {'pushbutton','String','Don''t Run','validate',false};...
    };

title = 'Baseline Correction'; % default title
if ~isempty(varargin) && ~isempty(varargin{1}) && ischar(varargin{1})
    title = varargin{1};
end

win = FT.tools.Win(c,'title',title,'grid',true,'focus','wstart');
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
    if iscell(FT_DATA.data)
        time = FT_DATA.data{1}.time;
    else
        time = FT_DATA.data.time;
    end
    
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
            'Start and end times must be numeric, and Start must come before End.'];
    % Baseline window extends beyond the trial window
    elseif (baselinewin(1) < min(time) || baselinewin(2) > max(time))
        b = false;
        val = ['\bf[\color{yellow}WARNING\color{black}]: Invalid time range.\n\n',...
            'The start and/or end times entered fall outside the ',...
            'time range of the trials [' num2str(validwin(1)) ' ' num2str(validwin(2)) '].']; 
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