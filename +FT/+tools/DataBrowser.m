function [marks] = DataBrowser(time,data,group_by,n,lChan,lTrial)
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
% Updated: 2014-07-18
% Peter Horak

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

if length(time) ~= N
    error('Time axis and number of data points are inconsistent.');
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
        data(i,:,j) = data(i,:,j) - mean(data(i,:,j));
        std_avg = std_avg + std(data(i,:,j));
    end
end
std_avg = std_avg/numel(data(:,1,:));

span = 4*std_avg; % spacing (offset) of time series plotted in the same figure

% Create the plot (data viewer) and set its dimensions
f = figure();
wDims = get(0,'ScreenSize');
ww = wDims(3); wh = wDims(4);
set(f,'Position',round([ww*.25,wh*.1,ww*.5,wh*.8]));

% Set the coloring scheme for plotting multiple data series simultaneously
set(f,'DefaultAxesColorOrder',[0,0,1;0,.5,0;1,0,0;0,.75,.75;.75,0,.75;.75,.75,0;.25,.25,.25;1,.5,0;0,1,0]);
% set(f,'DefaultAxesColorOrder',[0,0,1]);

hAx = axes; % handle to plot axis object

c = {% Channel Browsing
     {'text','string','Chan:'},...
	 {'edit','string',num2str(chan),'tag','channel'};...
	 {'pushbutton','string','Prev','Callback',@PrevC},...
     {'pushbutton','string','Next','Callback',@NextC};...
     % Trial Browsing
     {'text','string','Trial:'},...
	 {'edit','string',num2str(trial),'tag','trial'};...
	 {'pushbutton','string','Prev','Callback',@PrevT},...
     {'pushbutton','string','Next','Callback',@NextT};...
     % Navigation
     {'text','string',' Navigation'},{'text','string',''};...
     {'pushbutton','string','+ V.','Callback',@MagV},...
     {'pushbutton','string','- V.','Callback',@MinV};...
     {'pushbutton','string','+ H.','Callback',@MagH},...
	 {'pushbutton','string','- H.','Callback',@MinH};...
     {'pushbutton','string','<','Callback',@Backward},...
	 {'pushbutton','string','>','Callback',@Forward};...
     % Marking
     {'text','string','Marked:'},...
     {'checkbox','tag','mark','Callback',@Mark};...
	 {'pushbutton','string',' Mark All','Callback',@Toggle},...
     {'text','string',''};...
     % Plot & Exit
     {'pushbutton','string','Plot','Callback',@Plot},...
	 {'pushbutton','string','Exit','validate',false}...
	};

w = FT.tools.Win(c,'position',[-ww*.25-100 0]); % user input/control window
UpdatePlot();

% Wait for the user to close the control window
uiwait(w.h);
% Close the plot if still open
if ishandle(f)
    close(f);
end

%-------------------------------------------------------------------------%

% Update the plot (data viewer)
function UpdatePlot()
    % If the plot was manually close, quit
    if ~ishandle(hAx)
        close(w.h);
        return;
    end
    
    % Plot nearby channels on the same plot...
    if group_chan
        
        % Don't attempt to plot channels outside the valid range
        pred = -min(n,chan-1);
        succ = min(n,nChan-chan);
        range = pred:succ;
        
        % Plot the channels spaced along the y-axis of a single plot
        plot(hAx,time,data(range+chan,:,trial)-span*range'*ones(1,N));
        title(hAx,['Trial: ' lTrial{trial}]);
        legend(hAx,lChan{range+chan});
    else % ...or nearby trials
        
        % Don't attempt to plot trials outside the valid range
        pred = -min(n,trial-1);
        succ = min(n,nTrial-trial);
        range = pred:succ;
        
        % Plot the trials spaced along the y-axis of a single plot
        plot(hAx,time,permute(data(chan,:,range+trial),[3,2,1])-span*range'*ones(1,N));
        title(hAx,['Channel: ' lChan{chan}]);
        legend(hAx,lTrial{range+trial});
    end
    
    % Plot labels & apply default y-axis limits
    ylim(hAx,[-(n+.5)*span,(n+.5)*span]);
    xlim(hAx,[time(1),min(time(end),time(1)+10)]);
    xlabel(hAx,'time'); ylabel(hAx,'LFP (volt)');
    
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
        span = 4*std_avg; % reset the spacing of the series
        UpdatePlot();
    end
end

% Plot the next channel if there is one
function NextC(~,~)
    if (chan < nChan)
        chan = chan+1;
        % update current channel # to match
        w.SetElementProp('channel','string',num2str(chan));
        span = 4*std_avg; % reset the spacing of the series
        UpdatePlot();
    end
end

% Plot the previous trial if there is one
function PrevT(~,~)
    if (1 < trial)
        trial = trial-1;
        % update current trial # to match
        w.SetElementProp('trial','string',num2str(trial));
        span = 4*std_avg; % reset the spacing of the series
        UpdatePlot();
    end
end

% Plot the next trial if there is one
function NextT(~,~)
    if (trial < nTrial)
        trial = trial+1;
        % update current trial # to match
        w.SetElementProp('trial','string',num2str(trial));
        span = 4*std_avg; % reset the spacing of the series
        UpdatePlot();
    end
end

% Plot the trial and channel indicated by the user with the edit boxes
function Plot(~,~)
    % Read trial # input by user
    tr = w.GetElementProp('trial','string');
    tr = round(str2double(tr));
    
    % Make sure it is within the valid range of trials
    if (tr < 1) || (nTrial < tr)
        tr = min(max(tr,1),nTrial);
        w.SetElementProp('trial','string',num2str(tr));
    end
    trial = tr;
    
    % Read channel # input by user
    ch = w.GetElementProp('channel','string');
    ch = round(str2double(ch));
    
    % Make sure it is within the valid range of channels
    if (ch < 1) || (nChan < ch)
        ch = min(max(ch,1),nChan);
        w.SetElementProp('channel','string',num2str(ch));
    end
    chan = ch;
    
    % Reset the spacing of series to the default and update the plot
    span = 4*std_avg;
    UpdatePlot();
end

%-------------------------------------------------------------------------%
%                              NAVIGATION                                 %
%-------------------------------------------------------------------------%

% Magnify the vertical axis
function MagV(~,~)
    limits = ylim(hAx);
    ylim(hAx,limits+diff(limits)*[.1,-.1]-mean(limits));
    
    % Update the plot but maintain the spacing of the series in the window
    span = span*0.8;
    atmp = axis(hAx);
    UpdatePlot();
    axis(hAx,atmp);
end

% Minify the vertical axis
function MinV(~,~)
    limits = ylim(hAx);
    ylim(hAx,limits+diff(limits)*[-.1,.1]-mean(limits));
    
    % Update the plot but maintain the spacing of the series in the window
    span = span*1.2;
    atmp = axis(hAx);
    UpdatePlot();
    axis(hAx,atmp);
end

% Magnify the time axis
function MagH(~,~)
    limits = xlim(hAx);
    xlim(hAx,limits+diff(limits)*[.1,-.1]);
end

% Minify the time axis
function MinH(~,~)
    limits = xlim(hAx);
    xlim(hAx,limits+diff(limits)*[-.1,.1]);
end

% Scroll backward along the time axis
function Backward(~,~)
    limits = xlim(hAx);
    xlim(hAx,limits-diff(limits)*.1);
end

% Scroll forward along the time axis
function Forward(~,~)
    limits = xlim(hAx);
    xlim(hAx,limits+diff(limits)*.1);
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
end

