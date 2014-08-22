function Gui(varargin)

% FT.events.check.Gui
%
% Description: check events against stimulus channel data
%
% Syntax: FT.events.check.Gui
%
% In:
%
% Out:
%
% Updated: 2014-03-13
% Scottie Alexander
%
% See also: FT.events.check.Run

global FT_DATA;

if ~FT.tools.Validate('check_events','done',{'read_events'},'todo',{'remove_channels','segment_trials'})
    return;
end

if ~isfield(FT_DATA,'pulse_evts')
    FT.UserInput(['\color{red}Events did not have to be translated from pulses for this dataset!\n\color{black}'...
        'No manual event checking is needed.'],0,'title','No Event Translation','button','OK');
    return;
end

EVENT   = FT.ReStruct(FT_DATA.event);
bRM     = false;
kRemove = [];
kFinal  = [];
kData   = 1;
kStim   = strcmpi(FT_DATA.pulse_evts.channel,FT_DATA.data.label);

pulse_width = (FT_DATA.pulse_evts.width/1000)*FT_DATA.data.fsample;
pulse_int   = (FT_DATA.pulse_evts.interval/1000)*FT_DATA.data.fsample;

siz_win = round(FT_DATA.pulse_evts.fs*.3); % ~# samples in 250ms

% --- FIGURE --- %;
pFig = FT.tools.GetFigPosition(800,720);

h = figure('Units','pixels','OuterPosition',pFig,...
           'Name','Event Check','NumberTitle','off','MenuBar','none');

pFigCtrl = FT.tools.GetFigPosition(250,250);
pFigCtrl(1) = pFig(1) - 250;
hCtrl = figure('Units','pixels','OuterPosition',pFigCtrl,...
           'Name','Plot Control','NumberTitle','off','MenuBar','none');

% --- AXES --- %
hA = axes('Units','normalized','OuterPosition',[0,.05,1,.95],'Parent',h);

% --- LINE AND TITLE HANDLES --- %
[hP,hTitle,hLine,hInit] = deal([]);

height = .12;

% --- EDIT --- %
uicontrol('Style','text','Units','normalized','Position',[.05 .85 .4 height],...
    'String','New type:','BackgroundColor',get(hCtrl,'Color'),...
    'FontSize',14,'HorizontalAlignment','right','Parent',hCtrl);

hEdit = uicontrol('Style','edit','Units','normalized','Position',[.55 .87 .4 height],...
    'String','','BackgroundColor',[1 1 1],'FontSize',12,'Parent',hCtrl);

% --- ZOOM --- %
uicontrol('Style','pushbutton','Units','normalized','Position',[.05 .7 .4 height],...
    'String','Zoom In','FontSize',11,'Callback',@ZoomCtrl,'Parent',hCtrl);

uicontrol('Style','pushbutton','Units','normalized','Position',[.55 .7 .4 height],...
    'String','Zoom Out','FontSize',11,'Callback',@ZoomCtrl,'Parent',hCtrl);

% --- BUTTONS --- %
wBtn  = .4;
pad   = .05;
lInit = .5-((wBtn*5 + pad*4)/2);
lInit = lInit:wBtn+pad:lInit+(wBtn+pad)*5;

uicontrol('Style','pushbutton','Units','normalized','Position',[.05 .55 .4 height],...
    'String','Previous','Callback',@(x,y) PlotCtrl(x,y,'previous'),...
    'FontSize',12,'Parent',hCtrl);

uicontrol('Style','pushbutton','Units','normalized','Position',[.55 .55 .4 height],...
    'String','Next','Callback',@(x,y) PlotCtrl(x,y,'next'),...
    'FontSize',12,'Parent',hCtrl);

uicontrol('Style','text','Units','normalized','Position',[.05 .38 .4 height],...
    'String','Display:','BackgroundColor',get(hCtrl,'Color'),...
    'FontSize',14,'HorizontalAlignment','right','Parent',hCtrl);

hFilt = uicontrol('Style','edit','Units','normalized','Position',[.55 .4 .4 height],...
    'String','','BackgroundColor',[1 1 1],'FontSize',12,'Parent',hCtrl);

uicontrol('Style','text','Units','normalized','Position',[.05 .25 .4 height],...
    'String','Remove:','BackgroundColor',get(hCtrl,'Color'),...
    'FontSize',14,'HorizontalAlignment','right','Parent',hCtrl);

hRM = uicontrol('Style','checkbox','Units','normalized','Position',[.55 .29 .08 .08],...
    'BackgroundColor',[1 1 1],'Min',0,'Max',1,'Value',0,'Parent',hCtrl);

uicontrol('Style','pushbutton','Units','normalized','Position',[.05 .1 .4 height],...
    'String','Done','Callback',@(x,y) PlotCtrl(x,y,'done'),...
    'FontSize',12,'Parent',hCtrl);

uicontrol('Style','pushbutton','Units','normalized','Position',[.55 .1 .4 height],...
    'String','Cancel','Callback',@(x,y) PlotCtrl(x,y,'cancel'),...
    'FontSize',12,'Parent',hCtrl);

% --- PLOT --- %
NewPlot;

%allow markers to be clicked
set(hP,'hittest','off');
hold(hA,'on');

%fnct to deal with keypresses
set(h,'KeyPressFcn',@KeyCtrl);

%fnct to deal with clicks
set(hA,'ButtonDownFcn',@MouseCtrl);

%give focus to the figure
set(hEdit,'Enable','off');
drawnow;
set(hEdit,'Enable','on');

% wait till user is done
uiwait(h)

%only actually remove events if the user clicks done
if bRM && ~isempty(kRemove)
    params.remove = kRemove;
    me = FT.events.check.Run(params);
    FT.ProcessError(me);
end

if ishandle(h)
    close(h);
end

if ishandle(hCtrl)
    close(hCtrl);
end

%------------------------------------------------------------------------------%
function NewPlot
%refresh the stim channel plot and related text to reflect the event that is
%currently being reviewed / edited
    %get current event
    evt    = FT_DATA.event(kData);
    kFinal = evt.sample;

    %get and plot stim channel surrounding current event
    nPnts  = (evt.value * pulse_width) + ((evt.value-1) * pulse_int);
    kStart = nPnts+round(siz_win*1.25);

    if kStart > evt.sample
        kStart = 1;
    end
    
    dX = evt.sample-kStart:evt.sample+round(siz_win*.75);
    dY = FT_DATA.data.trial{1}(kStim,dX);
    if isempty(hP) || ~ishandle(hP)
        hP = plot(dX,dY,'Color',[1 0 0],'LineWidth',2,'Parent',hA);
        set(get(get(hP,'Annotation'),'LegendInformation'),'IconDisplayStyle','Off');
    else
        set(hP,'XData',dX,'YData',dY); 
    end
    
    %reset axes limits to reflect new data
    set(hA,'XLim',[min(dX) max(dX)],'YLim',[min(dY)-20 max(dY)+20]);
    
    %remove old event lines
    if ishandle(hInit)
        delete(hInit);
    end
    if ishandle(hLine)
        delete(hLine);
    end
    
    %add starting (green) and movable (blue) event lines
    hInit = AddLine([evt.sample evt.sample],[min(dY) max(dY)],[0 1 0]);
    hLine = AddLine([evt.sample evt.sample],[min(dY) max(dY)],[0 0 1]);
    set(get(get(hLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','Children');
    set(get(get(hInit,'Annotation'),'LegendInformation'),'IconDisplayStyle','Off');
    
    %axes title location
    xText = dX(1); %initial x location for title, this is finialized below
    yLim = get(hA,'YLim');
    yText = yLim(2) + (yLim(2)/20);
    
    %set axes title to inform user of event number, event code/value, and event
    %type
    strType = strrep(evt.type,'_','\_'); %escape underscores for tex interpretation
    strTitle = ['Event #' num2str(kData) '  -  Value ' num2str(evt.value) ': ''' strType ''''];
    if isempty(hTitle) || ~ishandle(hTitle)
        hTitle = text(xText,yText,strTitle,'FontSize',20,'FontWeight','bold','Units','data','Parent',hA);
    else
        set(hTitle,'String',strTitle,'Position',[xText yText 0],'Units','data');
    end
    
    %make sure that the title is actually centered
    tExt = get(hTitle,'Extent');
    xLim = get(hA,'XLim');
    xText = mean(xLim) - tExt(3)/2;
    set(hTitle,'Position',[xText yText]);
    
    %remove old legend
    hL = findobj(h,'Tag','legend');
    if ishandle(hL)        
        delete(hL);
    end
        
    %update edit box with default event type
    set(hEdit,'String',evt.type);
    
    %add new legend
    set(hLine,'DisplayName',['Value ' num2str(evt.value) ': ' strType]);    
    hL = legend(hA,'show');
    set(hL,'Location','NorthWest');
    
    %fix x-axis tick labels
    xT = reshape(get(hA,'XTick'),[],1);
    xTL = arrayfun(@(x) num2str(x),xT,'uni',false);
    set(hA,'XTickLabel',xTL);
    
    %has this event already been removed?
    if ~isempty(kRemove) && ismember(kData,kRemove)
        set(hRM,'Value',1);
    else
        set(hRM,'Value',0);
    end

    %force figure update
    drawnow;
end
%------------------------------------------------------------------------------%
function PlotCtrl(obj,evt,strAct)
%simple function to handle button clicks    
    %update event struct
    EvtCtrl(strAct);

    %increment/decrement current event index
    switch strAct
        case {'next','previous'}
            GetNextEvent(strAct)
        case 'done'
            bRM = true;
            uiresume(h);            
            return;
        case 'cancel'
            bRM = false;
            uiresume(h);
            return;
        otherwise
            %this should never happen
            error('invalid action %s',strAct);
    end        
    
    %make sure we stay within limites of the event struct
    if kData > numel(FT_DATA.event)
        kData = numel(FT_DATA.event);
    elseif kData < 1
        kData = 1;
    else
        NewPlot;
    end
    
    %give focus back to the figure so keypresses work immediatly
    set(obj,'Enable','off');
    drawnow;
    set(obj,'Enable','on');
end
%------------------------------------------------------------------------------%
function EvtCtrl(act)
    if get(hRM,'Value')
        kRemove(end+1,1) = kData;
    elseif ~isempty(kRemove)        
        kRemove(kRemove == kData) = [];        
    end
    if any(strcmpi(act,{'next','previous'}))
        if isempty(kRemove) || ~ismember(kData,kRemove)
            strType = get(hEdit,'String');
            params2.adjust.type = strType;
            params2.adjust.sample = kFinal;
            params2.adjust.kData = kData;
            me2 = FT.events.check.Run(params2);
            FT.ProcessError(me2);
        end
    end
        
end
%------------------------------------------------------------------------------%
function KeyCtrl(obj,evt)
    if ishandle(hLine)
        drawnow;
        xD = get(hLine,'XData');
        yD = get(hLine,'YData');
        bNew = false; 

        switch lower(evt.Key)        
            case 'space'
                kFinal = xD(1);
                PlotCtrl([],[],'next');
            case 'backspace'
                kFinal = xD(1);
                PlotCtrl([],[],'previous');
            case 'escape'
                kFinal = [];
                PlotCtrl([],[],'done');
            case 'leftarrow'
                xD = xD-1;
                bNew = true;
            case 'rightarrow'
                xD = xD+1;
                bNew = true;
            otherwise
                %some other key...
        end

        if bNew
            delete(hLine);
            hLine = AddLine(xD,yD,[0 0 1]);
            kFinal = xD(1);
        end
    elseif strcmpi(evt.Key,'escape')
        uiresume(h);
    end
end
%------------------------------------------------------------------------------%
function MouseCtrl(obj,evt)
    drawnow;
    click_type = get(h,'SelectionType');    
    if strcmp(click_type,'normal')        
        %Finding the closest point and draw a vertical line through it
        pt = get(hA,'CurrentPoint');

        %Getting coordinates of line object
        xp = get(hP,'Xdata'); 
        yp = get(hP,'Ydata');

        %Aspect ratio is needed to compensate for uneven axis when calculating the distance
        dx = daspect(hA);
        
        %find closest point on line
        [~,idx] = min(((pt(1,1)-xp).*dx(2)).^2 + ((pt(1,2)-yp).*dx(1)).^2);

        %draw a line at the chosen point
        if ishandle(hLine)
            delete(hLine);
        end
        hLine = AddLine([xp(idx),xp(idx)],[min(yp) max(yp)],[0 0 1]);
        
        %keep track of the location
        kFinal = get(hLine,'XData');
        kFinal = kFinal(1);
    end
end
%------------------------------------------------------------------------------%
function hL = AddLine(x,y,col)
    hL = line(x,y,'Color',col,'LineWidth',2.5,'Parent',hA);
    setappdata(hA,'CurrentPoint',hL);
end
%------------------------------------------------------------------------------%
function ZoomCtrl(obj,evt)
    action = regexprep(get(obj,'String'),'Zoom ','');
    switch lower(action)
        case 'in'
            siz_win = floor(siz_win*.6);
        case 'out'
            siz_win = ceil(siz_win*1.4);
        otherwise
            error('Invalid zoom action %s',action);
    end
    NewPlot;
end
%------------------------------------------------------------------------------%
function GetNextEvent(btn)
    
    str = strtrim(get(hFilt,'String'));
    if isempty(str)
        DefaultIncrement(btn);
        return;
    end

    re = regexp(str,'(?<key>\w+)\s*(?<op>[=\<\>]+)\s*(?<val>[^=\<\>]*)','names');

    if isempty(re) || ~any(strcmpi(re.key,fieldnames(EVENT)))
        BadFilterExpr(btn);
        return;
    end
    
    re.op = regexprep(re.op,'\s+','');
    re.val = strtrim(re.val);

    if ~all(ismember(re.op,'=><'))
        BadFilterExpr(btn);
        return;
    end
    val = str2double(re.val);
    if ~isnan(val)
        if re.op == '='
            re.op = '==';
        end
        cmd = ['EVENT.' re.key ' ' re.op ' ' re.val];        
    elseif any(strcmp(re.op,{'=','=='}))
        if ~any(ismember(re.val,EVENT.(re.key)))
            BadFilterExpr(btn);
            return;
        else
            if re.val(1) ~= char(39)
                re.val = [char(39) re.val];
            end
            if re.val(end) ~= char(39)
                re.val = [re.val char(39)];
            end

            cmd = ['strcmpi(' re.val ',EVENT.' re.key ')'];
        end

    else
        BadFilterExpr(btn);
        return;
    end
    try
        b = eval(cmd);
    catch me
        BadFilterExpr(btn);
        return;
    end    
    if any(b)
        kGood = find(b);        
        if strcmpi(btn,'next')
            kNext = find(kGood > kData,1,'first');            
        elseif strcmpi(btn,'previous')
            kNext = find(kGood < kData,1,'last');
        end
        if ~isempty(kNext)
            kData = kGood(kNext);
        end
    end
end
%------------------------------------------------------------------------------%
function BadFilterExpr(btn)
    FT.UserInput('\bf[WARNING]: you entered an invalid filter expression',0,'button','OK');
    DefaultIncrement(btn);
    set(hFilt,'String','');
end
%------------------------------------------------------------------------------%
function DefaultIncrement(btn)    
    switch lower(btn)
    case 'next'
        kData = kData+1;
    case 'previous'
        kData = kData-1;
    end
end
%------------------------------------------------------------------------------%
end