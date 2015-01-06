function varargout = DataBrowser(time,data,group_by,n,lChan,lTrial)
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

%Updates
%   2014-10-09: give the figure a better title than 'figure 2', make figure wider

marks = [];

% Minimal input checking
if nargin < 4
    n = 4; % number of additional time series to plot on either side of current
    if nargin < 3
        group_by = 'trial';
        if nargin < 2
            error('Not enough input arguments.');
        end
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

std_avg = 0; % std. dev. of data averaged over all trials and channels

% De-mean each time series
for i = 1:size(data,1)
    for j = 1:size(data,3)
%         data(i,:,j) = data(i,:,j) - mean(data(i,:,j));
        std_avg = std_avg + std(data(i,:,j));
    end
end
std_avg = std_avg/numel(data(:,1,:));

span = 4*std_avg; % spacing (offset) of time series plotted in the same figure

% Create the plot (data viewer) and set its dimensions
f = figure('NumberTitle','off','Name','Data Browser');
wDims = get(0,'ScreenSize');
ww = wDims(3); wh = wDims(4);
set(f,'Position',round([ww*.25,wh*.1,ww*.7,wh*.8]));

% Set the coloring scheme for plotting multiple data series simultaneously
% set(f,'DefaultAxesColorOrder',[0,0,1;0,.5,0;1,0,0;0,.75,.75;.75,0,.75;.75,.75,0;.25,.25,.25;1,.5,0;0,1,0]);

hAx = axes; % handle to plot axis object
set(f,'DeleteFcn',@FigDeleteFcn);
set(f,'KeyPressFcn',@FigKeyFcn);

c = {% Channel Browsing
     {'text','string',' Chan:'},...
	 {'edit','string',num2str(chan),'len',floor(log10(nChan))+1,'tag','channel'},...
	 {'pushbutton','string','Prev','Callback',@PrevC},...
     {'pushbutton','string','Next','Callback',@NextC};...
     % Trial Browsing
     {'text','string','Trial:'},...
	 {'edit','string',num2str(trial),'len',floor(log10(nTrial))+1,'tag','trial'},...
	 {'pushbutton','string','Prev','Callback',@PrevT},...
     {'pushbutton','string','Next','Callback',@NextT};...
     % Amplitude Zooming
     {'text','string','Amplitude Zoom:'},...
     {'text','string',''},...
     {'pushbutton','string','+','Callback',@MagV},...
     {'pushbutton','string','-','Callback',@MinV};...
     % Time Zooming
     {'text','string','     Time Zoom:'},...
     {'text','string',''},...
     {'pushbutton','string','+','Callback',@MagH,'ToolTipString','Shortcut: +'},...
	 {'pushbutton','string','-','Callback',@MinH,'ToolTipString','Shortcut: -'};...
     % Scrolling
     {'pushbutton','string','<<','Callback',@(x,y) Backward(x,y,1)},...
     {'pushbutton','string','<','Callback',@(x,y) Backward(x,y,.1),'ToolTipString','Shortcut: <'},...
	 {'pushbutton','string','>','Callback',@(x,y) Forward(x,y,.1),'ToolTipString','Shortcut: >'},...
	 {'pushbutton','string','>>','Callback',@(x,y) Forward(x,y,1)};...
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
    c{7,4} = {'text','string',''};
    c(6,:) = [];
end
if (nTrial == 1)
    c(2,:) = [];
end
if (nChan == 1)
    c(1,:) = [];
end

w = FT.tools.Win(c,'position',[-ww*.25-100 0],'focus','close','title','Plot Control'); % user input/control window
set(w.h,'KeyPressFcn',@FigKeyFcn);
ResetLimits();
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
function ResetLimits()
%     span = 4*std_avg; % reset the spacing of the series
    ylim(hAx,[-(n+.5)*span,(n+.5)*span]);
    xlim(hAx,[time(1),min(time(end),time(1)+10)]);
end
%-------------------------------------------------------------------------%

% Update the plot (data viewer)
function UpdatePlot()
    atmp = axis(hAx); % remember the current plot limits
    
    % Plot nearby channels on the same plot...
    if group_chan
        % Don't attempt to plot channels outside the valid range
        pred = -min(n,chan-1);
        succ = min(n,nChan-chan);
        range = pred:succ;
        
        % Color all channels blue except the current, which is red
        defColOrd = zeros(numel(range),3);
        defColOrd(:,3) = 1;
        defColOrd(range == 0,:) = [1,0,0];
        set(f,'DefaultAxesColorOrder',defColOrd);
        
        % Plot the channels spaced along the y-axis of a single plot
        plot(hAx,time,data(range+chan,:,trial)-span*range'*ones(1,N));
        title(hAx,['Trial: ' lTrial{trial}]);
        
        % Add a legend of text boxes
        xlegend = atmp(2);
        for kR = 1:numel(range)
            text(xlegend,-span*range(kR),[' ' lChan{range(kR)+chan}],'parent',hAx,'color',defColOrd(kR,:));
        end
    else % ...or nearby trials
        % Don't attempt to plot trials outside the valid range
        pred = -min(n,trial-1);
        succ = min(n,nTrial-trial);
        range = pred:succ;
        
        % Color all trials blue except the current, which is red
        defColOrd = zeros(numel(range),3); defColOrd(:,3) = 1;
        defColOrd(range == 0,:) = [1,0,0];
        set(f,'DefaultAxesColorOrder',defColOrd);
        
        % Plot the trials spaced along the y-axis of a single plot
        plot(hAx,time,permute(data(chan,:,range+trial),[3,2,1])-span*range'*ones(1,N));
        title(hAx,['Channel: ' lChan{chan}]);
        
        % Add a legend of text boxes
        xlegend = atmp(2);
        for kR = 1:numel(range)
            text(xlegend,-span*range(kR),[' ' lTrial{range(kR)+trial}],'parent',hAx,'color',defColOrd(kR,:));
        end
    end
    
    % Plot labels and restore the current plot limits
    xlabel(hAx,'time'); ylabel(hAx,'Amplitude (\muV)');
    axis(hAx,atmp);
    
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

% Plot the previous channel if there is one
function PrevC(~,~)
    if (1 < chan)
        chan = chan-1;
        % update current channel # to match
        w.SetElementProp('channel','string',num2str(chan));
        UpdatePlot();
    end
end

% Plot the next channel if there is one
function NextC(~,~)
    if (chan < nChan)
        chan = chan+1;
        % update current channel # to match
        w.SetElementProp('channel','string',num2str(chan));
        UpdatePlot();
    end
end

% Plot the previous trial if there is one
function PrevT(~,~)
    if (1 < trial)
        trial = trial-1;
        % update current trial # to match
        w.SetElementProp('trial','string',num2str(trial));
        UpdatePlot();
    end
end

% Plot the next trial if there is one
function NextT(~,~)
    if (trial < nTrial)
        trial = trial+1;
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
    ResetLimits();
    UpdatePlot();
end

%-------------------------------------------------------------------------%
%                              NAVIGATION                                 %
%-------------------------------------------------------------------------%

% Magnify the vertical axis
function MagV(~,~)
    limits = ylim(hAx);
    ylim(hAx,limits+diff(limits)*[.1,-.1]);
    UpdatePlot
end

% Minify the vertical axis
function MinV(~,~)
    limits = ylim(hAx);
    ylim(hAx,limits+diff(limits)*[-.1,.1]);
    UpdatePlot
end

% Magnify the time axis
function MagH(~,~)
    limits = xlim(hAx);
    xlim(hAx,limits+diff(limits)*[.1,-.1]);
    UpdatePlot;
end

% Minify the time axis
function MinH(~,~)
    limits = xlim(hAx);
    xlim(hAx,limits+diff(limits)*[-.1,.1]);
    UpdatePlot;
end

% Scroll backward along the time axis
function Backward(~,~,amount)
    limits = xlim(hAx);
    xlim(hAx,limits-diff(limits)*amount);
    UpdatePlot
end

% Scroll forward along the time axis
function Forward(~,~,amount)
    limits = xlim(hAx);
    xlim(hAx,limits+diff(limits)*amount);
    UpdatePlot
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
function FigKeyFcn(obj,evt)
    switch lower(evt.Key)        
        case 'rightarrow'
            if group_chan
                NextT;
            else
                NextC;
            end
        case 'leftarrow'
            if group_chan
                PrevT;
            else
                PrevC;
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
                    MagH;
                case '-'
                    MinH;
                case '<'
                    Backward(obj,evt,.1);
                case '>'
                    Forward(obj,evt,.1);
                otherwise
                    % other
            end
    end
end
%-------------------------------------------------------------------------%
end

