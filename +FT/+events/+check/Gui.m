function Gui()
% FT.events.check.Gui
%
% Description: allow the user to manually check the position and value of
% events that were translated from pulses on the stimulus channel
%
% Syntax: FT.events.check.Gui()
%
% In:
%
% Out:
%
% GUI Controller:
%       Event- event number
%       Prev - make previous event the current
%       Next - make the next event the current
%       Plot - make the event given above the current
%       Del  - delete the current event
%       Type - event name
%       Value- number of pulses in event
%         +  - magnify (zoom in on) the horizontal axis
%         -  - minify (zoom out of) the horizontal axis
%         <  - scroll left  along the horizontal axis
%         >  - scroll right along the horizontal axis
%       Done - apply all changes and close the browser
%       Cancel - discard all changes and close the browser
%
% Updated: 2014-08-25
% Peter Horak

global FT_DATA;

if ~FT.tools.Validate('check_events','done',{'read_events'},'todo',{'define_trials'})
    return;
end

if ~isfield(FT_DATA,'pulse_evts')
    FT.UserInput(['\bf\color{yellow}Notice\color{black}Events did not have to be translated from pulses for this dataset!\n\color{black}'...
        'No manual event checking is needed.'],0,'title','Notice','button','OK');
    return;
end

% Stimulus channel
range = FT_DATA.data.sampleinfo;
channel = strcmpi(FT_DATA.pulse_evts.channel,FT_DATA.data.label);
data = [zeros(1,range(1)-1),FT_DATA.data.trial{1}(channel,:)]; % stimulus channel only
sample = 1:size(data,2);
%%% sample = [1:(range(1)-1),FT_DATA.data.time{1}*FT_DATA.data.fsample];

% Events
ft_events = FT_DATA.event; % FieldTrip event struct array
nEvents = numel(ft_events); % number of events
event = 1; % start with the first event as the current

% Make sure the events are in increasing order
samples = cat(1,ft_events.sample); % samples/indices at which events occur
[samples,ind] = sort(samples);
ft_events = ft_events(ind);

% Create the plot and set its dimensions
f = figure('NumberTitle','off','MenuBar','none');
wDims = get(0,'ScreenSize');
ww = wDims(3); wh = wDims(4);
set(f,'Position',round([ww*.25,wh*.1,ww*.5,wh*.8]));
set(f,'DeleteFcn',@FigDeleteFcn); % close the controller window if the plot closes
set(f,'KeyPressFcn',@FigKeyFcn); % function to handle keystrokes

% Create axes object and plot the data
hAx = axes;
hPl = plot(hAx,sample(range(1):range(2)),data(range(1):range(2)));
xlabel(hAx,'Sample'); ylabel(hAx,'LFP');

% Make it so clicking on the plot will create a new event at that location
set(hPl,'HitTest','off');
set(hAx,'ButtonDownFcn',@AddEvent);

% Init ylim so as to encompass the full range of the data
ylimits = mean(data) + std(data)*10*[-1,1];%[min(data),max(data)];
ylim(hAx,ylimits);

% Init xlim so as to be able to view the longest expected pulse series
pulse_width = (FT_DATA.pulse_evts.width/1000)*FT_DATA.data.fsample;
pulse_int   = (FT_DATA.pulse_evts.interval/1000)*FT_DATA.data.fsample;
cent_init = (pulse_width+pulse_int)*(FT_DATA.pulse_evts.max_pulse+2);
xlim(hAx,cent_init*[-1,1]+ft_events(event).sample);

% Add a handle field to the events structure for lines in the figure
events = FT.ReStruct(ft_events);
events.h = zeros(size(ft_events));
for i = 1:nEvents
    events.h(i) = line(ft_events(i).sample*[1,1],ylimits,'Color',[0 0 0],'LineWidth',2,'Parent',hAx);
end
ft_events = FT.ReStruct(events);

c = {% Event Browsing
     {'text','string','Event:'},...
     {'edit','string',num2str(event),'tag','event','Callback',@(varargin) UpdatePlot('update')};...
     {'pushbutton','string','Prev','Callback',@(varargin) UpdatePlot('prev'),       'ToolTipString','Shortcut: Backspace'},...
     {'pushbutton','string','Next','Callback',@(varargin) UpdatePlot('next'),       'ToolTipString','Shortcut: Space'};...
     {'pushbutton','string','Plot','Callback',@(varargin) UpdatePlot('update'),     'ToolTipString','Shortcut: Return'},...
     {'pushbutton','string','Del ','Callback',@(varargin) UpdatePlot('del'),        'ToolTipString','Shortcut: Delete '};...
     {'pushbutton','string','<del','Callback',@(varargin) UpdatePlot('dels'),       'ToolTipString','Shortcut: Home'},...
     {'pushbutton','string','del>','Callback',@(varargin) UpdatePlot('dele'),       'ToolTipString','Shortcut: End'};...
     % Edit Events
     {'text','string','Type:'},...
     {'edit','string','','tag','type','Callback',@(varargin) UpdatePlot('')};...
     {'text','string','Value:'},...
     {'edit','size',5,'string',num2str(ft_events(event).value),'tag','val','Callback',@(varargin) UpdatePlot('')};...
     % Navigation
     {'text','string',' Navigation'},{'text','string',''};...
     {'pushbutton','string','+','Callback',@(varargin) UpdatePlot('mag'),           'ToolTipString','Shortcut: +'},...
     {'pushbutton','string','-','Callback',@(varargin) UpdatePlot('min'),           'ToolTipString','Shortcut: -'};...
     {'pushbutton','string','<','Callback',@(varargin) UpdatePlot('backward'),      'ToolTipString','Shortcut: <'},...
	 {'pushbutton','string','>','Callback',@(varargin) UpdatePlot('forward'),       'ToolTipString','Shortcut: >'};...
     {'pushbutton','string','Done'},...
     {'pushbutton','string','Cancel',                                               'ToolTipString','Shortcut: Escape'}...
	};

% User input/control window
w = FT.tools.Win(c,'position',[-ww*.25-100 0],'focus','cancel');
w.SetElementProp('type','string',ft_events(event).type);
set(w.h,'KeyPressFcn',@FigKeyFcn);
UpdatePlot('update');

% Wait for the control window to close
uiwait(w.h);
% Close the plot if still open
if ishandle(f)
    close(f);
end

% The user selected cancel
if ~strcmpi(w.res.btn,'done')
    return;
end

hMsg = FT.UserInput('Applying changes...',1);

% Crop the data
FT_DATA.data.trial{1} = FT_DATA.data.trial{1}(:,(range(1):range(2))-FT_DATA.data.sampleinfo(1)+1);
FT_DATA.data.time{1} = FT_DATA.data.time{1}((range(1):range(2))-FT_DATA.data.sampleinfo(1)+1);
%%% FT_DATA.data.sampleinfo = range;

% Adjust sample information to account for shift in starting index
FT_DATA.data.sampleinfo = [1 length(FT_DATA.data.time{1})];
for i = 1:nEvents
    ft_events(i).sample = ft_events(i).sample - range(1) + 1;
end

% Write the modified events into FT_DATA
FT_DATA.event = rmfield(ft_events,'h');
% Mark data as unsaved
FT_DATA.saved = false;
% Don't add history because meaningless to automated template at this point
FT_DATA.done.check_events = true;

if ishandle(hMsg)
    close(hMsg);
end

FT.UpdateGUI;

%-------------------------------------------------------------------------%
% Close the controller window if the plot closes
function FigDeleteFcn(~,~)
    if ishandle(w.h)
        close(w.h);
        return;
    end
end
%-------------------------------------------------------------------------%
% Create a new event where the user clicked on the plot
function AddEvent(~,~)
    click_type = get(f,'SelectionType');
    
    % Make sure it's a left mouse click
    if strcmp(click_type,'normal')
        pt = get(hAx,'CurrentPoint');
        idx = round(pt(1,1));
        
        % Make sure the location lies within the data extent
        if (range(1) <= idx) && (idx <= range(2))
            % Copy fields from the current event
            evt = ft_events(event);
            % Use the click location as the event sample/index
            evt.sample = idx;
            % Set the color of the current event marker to black
            set(evt.h,'Color',[0 0 0]);
            % Crate a marker for the new event
            evt.h = line([idx,idx],ylimits,'Color',[0 0 0],'LineWidth',2,'Parent',hAx);
            
            % Append the new event to the event struct array
            ft_events(end+1) = evt;
            nEvents = numel(ft_events);
            samples = cat(1,ft_events.sample);
            
            % Make sure the events are in order of increasing sample index
            [samples,ind] = sort(samples);
            ft_events = ft_events(ind);

            UpdatePlot('add');
        end
    end
end
%-------------------------------------------------------------------------%
% Crop data when all preceding or trailing events are deleted
function Crop(side)
    if strcmpi(side,'end') && (event < nEvents)
        % Remove trailing data
        range(2) = ft_events(event+1).sample;
    elseif strcmpi(side,'start') && (1 < event)
        % Remove preceding data
        range(1) = ft_events(event-1).sample;
    else return;
    end
    set(hPl,'XData',sample(range(1):range(2)),'YData',data(range(1):range(2)));
end
%-------------------------------------------------------------------------%
% Update the data and input/control graphical displays
function UpdatePlot(action)
    % Initialize some parameters/defaults
    evt = NaN; % invalid new event
    limits = xlim(hAx);
    newlims = limits;
    
    % Set the current event marker to black because another event may become current
    set(ft_events(event).h,'color',[0 0 0]);
    
    % Set the current event parameters based on the user input (if any)
    ft_events(event).type = w.GetElementProp('type','string');
    val = str2double(w.GetElementProp('val','string'));
    if val > 0
        ft_events(event).value = val;
    else % invalid input, restore what is displayed to the previous value
        w.SetElementProp('val','string',ft_events(event).value);
    end
    
    % Perform operations that depend on the specified action
    switch lower(action)
        case 'update' % go to the event number specified by the user
            evt = w.GetElementProp('event','string');
            evt = round(str2double(evt));
        case 'prev' % go to the previous event
            evt = event-1;
        case 'next' % go to the next event
            evt = event+1;
        case 'mag' % magnify the plot (along the x-axis)
            newlims = limits+diff(limits)*[.1,-.1];
        case 'min' % minify the plot (along the x-axis)
            newlims = limits+diff(limits)*[-.1,.1];
        case 'backward' % scroll backward (along the x-axis)
            newlims = limits-diff(limits)*.1;
        case 'forward' % scroll forward (along the x-axis)
            newlims = limits+diff(limits)*.1;
        case 'del' % remove the current event
            if (nEvents > 1)
                rm_evt = event;
            else % don't delete the last event
                warndlg('Cannot delete event because only one remains.','Failed Delete');
                rm_evt = [];
            end
        case 'dels' % remove all previous events (to start)
            Crop('start');
            rm_evt = 1:(event-1);
            event = 1;
        case 'dele' % remove all subsequent events (to end)
            Crop('end');
            rm_evt = (event+1):nEvents;
    end
    
    % Remove events
    if ismember(action,{'del','dels','dele'}) && ~isempty(rm_evt)
        delete(ft_events(rm_evt).h)
        keep = setdiff(1:nEvents,rm_evt);
        ft_events = ft_events(keep);
        samples = samples(keep);
        nEvents = numel(ft_events);
    end
    
    % The user didn't request a specific event, make the current event the
    % one which lies closest to the center of the plot
    if ismember(action,{'mag','min','forward','backward','add','del'})
        xlim(hAx,newlims);
        [~,event] = min(abs(samples-mean(newlims)));
    end
    
    % Change the current event index to a new one if it is valid
    if ~isnan(evt)
        event = evt;
    end
    % Make sure the event index lies within the number of events
    if (event < 1) || (nEvents < event)
        event = min(max(event,1),nEvents);
    end
    
    % Set the new current event's marker color to green
    tmp_evt = ft_events(event);
    set(tmp_evt.h,'color',[0 1 0]);
    
    % If the user requested to see an event, center the plot on it
    if ismember(action,{'update','prev','next'})
        xlim(hAx,limits-mean(limits)+tmp_evt.sample);
    end

    % Update the event parameters displayed in the control and plot figures
    w.SetElementProp('event','string',num2str(event));
    w.SetElementProp('type','string',tmp_evt.type);
    w.SetElementProp('val','string',num2str(tmp_evt.value));
    title(hAx,sprintf('Event %d/%d: %s (%d pulses)',event,nEvents,tmp_evt.type,tmp_evt.value));
end
%-------------------------------------------------------------------------%
function Shift(direction)
    incr = ceil(diff(xlim(hAx))/400);
    evt = ft_events(event);
    if strcmpi(direction,'left') && (range(1) < evt.sample)
        evt.sample = evt.sample - incr;
        if 1 < event
            evt.sample = max(evt.sample,ft_events(event-1).sample+1);
        end
    elseif strcmpi(direction,'right') && (evt.sample < range(2))
        evt.sample = evt.sample + incr;
        if event < nEvents
            evt.sample = min(evt.sample,ft_events(event+1).sample-1);
        end
    end
    set(evt.h,'XData',evt.sample*[1,1]);
    ft_events(event) = evt;
end
%-------------------------------------------------------------------------%
function FigKeyFcn(~,evt)
    switch lower(evt.Key)        
        case 'space'
            UpdatePlot('next');
        case 'backspace'
            UpdatePlot('prev');
        case 'escape'
            uiresume(w.h);
        case 'leftarrow'
            Shift('left');
        case 'rightarrow'
            Shift('right');
        case 'delete'
            UpdatePlot('del');
        case 'home'
            UpdatePlot('dels');
        case 'end'
            UpdatePlot('dele');
        case 'return'
            UpdatePlot('update');
        otherwise
            switch (evt.Character)
                case '+'
                    UpdatePlot('mag');
                case '-'
                    UpdatePlot('min')
                case '<'
                    UpdatePlot('backward')
                case '>'
                    UpdatePlot('forward');
                otherwise
                    % other
            end
    end
end
%-------------------------------------------------------------------------%
end
