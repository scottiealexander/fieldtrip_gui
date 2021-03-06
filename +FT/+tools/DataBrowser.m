function varargout = DataBrowser(time,data,group_by,lChan,lTrial)
% FT.tools.DataBrowser
%
% Description: plot time series data and allow the user to mark channels or
% trials.
%
% Syntax: marks = FT.tools.DataBrowser(time,data,group_by,lChan,lTrial)
%
% In:   time - time axis of data (in seconds)
%       data - channel x time x trial e.g. cat(3,FT_DATA.data{1}.trial{:})
%       group_by - show channels or trials on same plot ['trial']
%       n - number of additional series to show [4]
%       lChan - channel labels [{'ch1','ch2',...}]
%       lTrial - trial lebels [{'tr1','tr2',...}]
%
% Out:  marks - indices of channels (group_by = 'trial') or trials
%           (group_by = 'channels') that the user marks
%
% GUI Buttons:
%       Prev - make previous channel (or trial) the current
%       Next - make the next channel (or trial) the current
%       + V. - magnify (zoom in on) the vertical axis
%       - V. - minify (zoom out of) the vertical axis
%       + H. - magnify (zoom in on) the horizontal (time) axis
%       - H. - minify (zoom out of) the horizontal (time) axis
%         <  - scroll left  along the time axis
%         >  - scroll right along the time axis
%       Marked [] - mark the current channel (or trial)
%       Mark All - toggle all markers between on and off
%       Plot - plot the channel and trial specified in the input boxes
%       Exit - close the data browser and return the marks
%
% Updated: 2014-10-09
% Peter Horak

marks = [];

% Minimal input checking
if nargin < 3
    group_by = 'trial';
    if nargin < 2
        error('Not enough input arguments.');
    end
end

% Whether to plot multiple channels on the same figure or trials (default)
group_chan = strcmpi(group_by,'channel');

nChan = size(data,1); % total number of channels
N = size(data,2); % total number of time points
nTrial = size(data,3); % total number of trials

if (nChan == 0) || (N == 0) || (nTrial == 0)
    FT.UserInput('No data to view!',1,'title','Notice','button',{'OK'});
    return;
elseif length(time) ~= N
    FT.UserInput(['\bf[\color{red}ERROR\color{black}]: Time axis and ',...
        'number of data points are inconsistent.'],1,'title','Error','button',{'OK'});
    return;
end

chan = 1; % current channel (being plotted)
trial = 1; % current trial (being plotted)

% Initialize list of trials or channels to be marked
if group_chan
    marks = false(nTrial,1);
else
    marks = false(nChan,1);
end

% Channel labels (legend or title) default to ch1,ch2,... unless provided
if ~exist('lChan','var') || length(lChan) ~= nChan
    lChan  = cellfun(@(x) ['ch' num2str(x)],num2cell(1:nChan),'uni',false);
end
% Trial labels (legend or title) default to tr1,tr2,... unless provided
if ~exist('lTrial','var') || length(lTrial) ~= nTrial
    lTrial = cellfun(@(x) ['tr' num2str(x)],num2cell(1:nTrial),'uni',false);
end

Fs = 1/median(diff(time));
box = [];

% Create the plot (data viewer) and set its dimensions
f = figure('NumberTitle','off','Name','Data Browser');
wDims = get(0,'ScreenSize');
ww = wDims(3); wh = wDims(4);
set(f,'Position',round([ww*.25,wh*.1,ww*.7,wh*.8]));

% Set the coloring scheme for plotting multiple data series simultaneously
set(f,'DefaultAxesColorOrder',[0,0,1]);

hAx = axes; % handle to plot axis object
set(f,'DeleteFcn',@FigDeleteFcn);
set(f,'KeyPressFcn',@FigKeyFcn);

c = {% Channel Browsing
     {'text','string',' Chan:'},...
	 {'edit','string',num2str(chan),'len',floor(log10(nChan))+1,'tag','channel'},...
	 {'pushbutton','string','Prev','Callback',@(x,y) IncrementChan(-1)},...
     {'pushbutton','string','Next','Callback',@(x,y) IncrementChan(+1)};...
     % Trial Browsing
     {'text','string','Trial:'},...
	 {'edit','string',num2str(trial),'len',floor(log10(nTrial))+1,'tag','trial'},...
	 {'pushbutton','string','Prev','Callback',@(x,y) IncrementTrial(-1)},...
     {'pushbutton','string','Next','Callback',@(x,y) IncrementTrial(+1)};...
     % Amplitude Scaling
     {'text','string','Amplitude Scale:'},...
     {'text','string',''},...
     {'pushbutton','string','+','Callback',@(x,y) Zoom('y',0.8,true)},...
     {'pushbutton','string','-','Callback',@(x,y) Zoom('y',1.2,true)};...
     % Amplitude Zooming
     {'text','string',' Amplitude Zoom:'},...
     {'text','string',''},...
     {'pushbutton','string','+','Callback',@(x,y) Zoom('y',0.8,false)},...
     {'pushbutton','string','-','Callback',@(x,y) Zoom('y',1.2,false)};...
     % Time Zooming
     {'text','string','      Time Zoom:'},...
     {'text','string',''},...
     {'pushbutton','string','+','Callback',@(x,y) Zoom('x',0.8,false),'ToolTipString','Shortcut: +'},...
	 {'pushbutton','string','-','Callback',@(x,y) Zoom('x',1.2,false),'ToolTipString','Shortcut: -'};...
     % Scrolling
     {'pushbutton','string','<<','Callback',@(x,y) Scroll(-1)},...
     {'pushbutton','string','<','Callback',@(x,y) Scroll(-0.1),'ToolTipString','Shortcut: <'},...
	 {'pushbutton','string','>','Callback',@(x,y) Scroll(0.1),'ToolTipString','Shortcut: >'},...
	 {'pushbutton','string','>>','Callback',@(x,y) Scroll(1)};...
     % Marking
     {'text','string',''},...
     {'pushbutton','string',' Mark All','Callback',@Toggle},...
     {'checkbox','tag','mark','Callback',@Mark,'ToolTipString','Shortcut: Space'},...
     {'text','string',''};...
     % Main Commands
     {'text','string',''},...
     {'pushbutton','string','Plot','Callback',@Plot,'ToolTipString','Shortcut: Return'},...
     {'pushbutton','string','Close','validate',false,'ToolTipString','Shortcut: Escape'},...
	 {'pushbutton','string','Apply','validate',false}...
	};
if (nargout < 1)
    c{8,4} = {'text','string',''};
    c(7,:) = [];
end
if (nTrial == 1)
    c(2,:) = [];
end
if (nChan == 1)
    c(1,:) = [];
end

w = FT.tools.Win(c,'position',[-ww*.25-100 0],'focus','close','title','Plot Control'); % user input/control window
set(w.h,'KeyPressFcn',@FigKeyFcn);
ResetZoom();
UpdatePlot();

% Wait for the user to close the control window
uiwait(w.h);
% Close the plot if still open
if ishandle(f)
    close(f);
end

if ~strcmpi(w.res.btn,'apply')
    varargout{1} = [];
else
    varargout{1} = marks;
end

%-------------------------------------------------------------------------%
% So closing the figure closes the plot control window
function FigDeleteFcn(~,~)
    if ishandle(w.h)
        close(w.h);
        return;
    end
end
%-------------------------------------------------------------------------%

% Update the plot (data viewer)
function UpdatePlot()
    % Determine samples in time window
%     xr = find((box.t-box.dt) <= time,1,'first'):find(time <= (box.t+box.dt),1,'last');
    xr = max(1,round((box.t-box.dt-time(1))*Fs)):min(N,round((box.t+box.dt-time(1))*Fs));
    xdata = time(xr);
    
    % Plot nearby channels in the same window...
    if group_chan
        % Determine channels to show and plot visible data
        ntraces = floor(box.da/box.d);
        yr = max(1,chan-ntraces):min(nChan,chan+ntraces);
        ydata = data(yr,xr,trial)+box.d*((chan-yr)'*ones(1,numel(xr)));
        p = plot(hAx,xdata,ydata);
        if ~isempty(p), set(p(find(yr==chan,1,'first')),'Color',[1,0,0]); end

        % Plot title and legend of text boxes
        title(hAx,['Trial: ' lTrial{trial}]);
        for k = 1:numel(yr)
            text(box.t+box.dt,box.d*(chan-yr(k)),[' ' lChan{yr(k)}],'parent',hAx,'color',[yr(k)==chan,0,yr(k)~=chan]);
        end
    else % ...or nearby trials
        % Determine trials to show and plot visible data
        ntraces = floor(box.da/box.d);
        yr = max(1,trial-ntraces):min(nTrial,trial+ntraces);
        ydata = permute(data(chan,xr,yr),[3,2,1])+box.d*((trial-yr)'*ones(1,numel(xr)));
        p = plot(hAx,xdata,ydata);
        if ~isempty(p), set(p(find(yr==trial,1,'first')),'Color',[1,0,0]); end

        % Plot title and legend of text boxes
        title(hAx,['Channel: ' lChan{chan}]);
        for k = 1:numel(yr)
            text(box.t+box.dt,box.d*(trial-yr(k)),[' ' lTrial{yr(k)}],'parent',hAx,'color',[yr(k)==trial,0,yr(k)~=trial]);
        end
    end
    
    % Set the axes and axis labels
    axis(hAx,[box.t-box.dt,box.t+box.dt,-box.da,box.da]);
    xlabel(hAx,'time (sec)'); ylabel(hAx,'Amplitude (\muV)');
    
    % Update checkbox to reflect the state of the current channel or trial
    if group_chan
        w.SetElementProp('mark','Value',marks(trial));
    else
        w.SetElementProp('mark','Value',marks(chan));
    end
end

%-------------------------------------------------------------------------%
%                         TRIAL & CHANNEL BROWSING                        %
%-------------------------------------------------------------------------%

% Change the current channel
function IncrementChan(amount)
    if (1 <= chan+amount) && (chan+amount <= nChan)
        chan = chan + amount;
        % update current channel # to match
        w.SetElementProp('channel','string',num2str(chan));
        UpdatePlot();
    end
end

% Change the current trial
function IncrementTrial(amount)
    if (1 <= trial+amount) && (trial+amount <= nTrial)
        trial = trial + amount;
        % update current trial # to match
        w.SetElementProp('trial','string',num2str(trial));
        UpdatePlot();
    end
end

% Plot the trial and channel indicated by the user with the edit boxes
function Plot(~,~)
    % Read trial # input by user
    if (nTrial > 1)
        tr = w.GetElementProp('trial','string');
        tr = round(str2double(tr));

        % Make sure it is within the valid range of trials
        if (tr < 1) || (nTrial < tr)
            tr = min(max(tr,1),nTrial);
            w.SetElementProp('trial','string',num2str(tr));
        end
        trial = tr;
    end
    
    % Read channel # input by user
    if (nChan > 1)
        ch = w.GetElementProp('channel','string');
        ch = round(str2double(ch));

        % Make sure it is within the valid range of channels
        if (ch < 1) || (nChan < ch)
            ch = min(max(ch,1),nChan);
            w.SetElementProp('channel','string',num2str(ch));
        end
        chan = ch;
    end
    
    % Reset the spacing of series to the default and update the plot
    ResetZoom();
    UpdatePlot();
end

%-------------------------------------------------------------------------%
%                           WINDOW CONTROLS                               %
%-------------------------------------------------------------------------%

% Reset the plot axes
function ResetZoom()
    box.d = 10*std(data(chan,1:min(end,5000),trial)); % spacing (offset) of time series plotted in the same figure
    box.da = box.d*3; % extent of window above (and below) y=0
    box.t = min(time(1)+5,time(1)+(time(end)-time(1))/2); % time the window is centered on
    box.dt = min(5,(time(end)-time(1))/2); % extent of window left (and right) of box.t
end

% Zoom and scale controls
function Zoom(axis,scale,adjust_spacing)
    % Adjust the time scale (x axis) or amplitude scale (y axis)
    if strcmpi(axis,'x')
        box.dt = box.dt*scale;
    elseif strcmpi(axis,'y')
        box.da = box.da*scale;
        % Scale the vertical spacing of the traces
        if adjust_spacing
            box.d = box.d*scale;
        end
    end
    UpdatePlot();
end

% Scroll forward/backward along the time axis
function Scroll(amount)
    box.t = box.t + amount*2*box.dt;
    box.t = min(max(time(1),box.t),time(end));
    UpdatePlot();
end

%-------------------------------------------------------------------------%
%                               MARKING                                   %
%-------------------------------------------------------------------------%

% Mark current channel or trial
function Mark(obj,~)
    if group_chan
        marks(trial) = 1==get(obj,'Value');
    else
        marks(chan) = 1==get(obj,'Value');
    end
end

% Toggle markings of all channels or trials
function Toggle(~,~)
    if all(marks)
        marks = false(size(marks));
        w.SetElementProp('mark','Value',0);
    else
        marks = true(size(marks));
        w.SetElementProp('mark','Value',1);
    end
end

%-------------------------------------------------------------------------%
%                           KEYBOARD SHORTCUTS                            %
%-------------------------------------------------------------------------%
function FigKeyFcn(~,evt)
    switch lower(evt.Key)        
        case 'rightarrow'
            if group_chan
                IncrementTrial(+1);
            else
                IncrementChan(+1);
            end
        case 'leftarrow'
            if group_chan
                IncrementTrial(-1);
            else
                IncrementChan(-1);
            end
        case 'escape'
            uiresume(w.h);
        case 'space'
            if group_chan
                curr = trial;
            else
                curr = chan;
            end
            marks(curr) = ~marks(curr);
            w.SetElementProp('mark','Value',marks(curr));
        case 'return'
            Plot;
        otherwise
            switch (evt.Character)
                case '+'
                    Zoom('x',0.8,false);
                case '-'
                    Zoom('x',1.2,false);
                case '<'
                    Scroll(-0.1);
                case '>'
                    Scroll(0.1);
                otherwise
                    % other
            end
    end
end
%-------------------------------------------------------------------------%
end

