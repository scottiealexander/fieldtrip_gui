function CheckEvents(varargin)

% CheckEvents
%
% Description: check events against stimulus channel data
%
% Syntax: CheckEvents
%
% In:
%
% Out:
%
% Updated: 2013-08-20
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

if ~FT_DATA.done.read_events
    FT.UserInput(['\color{red}Events have not been processed for this dataset!\n\color{black}'...
        'Please use:\n      \bfSegmentation->Process Events\rm\nbefore checking.'],...
        0,'title','No Events Found','button','OK');
    return;
end

kFinal = [];
kData = 1;
kStim = strcmpi(FT_DATA.stim_chan,FT_DATA.data.label);

kInt = round(FT_DATA.data.fsample*(1/4)); % # samples in 250ms

% --- FIGURE --- %;
pFig = GetFigPosition(720,720);

h = figure('Units','pixels','OuterPosition',pFig,...
           'Name','Event Check','NumberTitle','off','MenuBar','none');

% --- AXES --- %
hA = axes('Units','normalized','OuterPosition',[0,.05,1,.95]);

% --- LINE AND TITLE HANDLES --- %
[hP,hTitle,hLine,hInit] = deal([]);

% --- EDIT --- %
uicontrol('Style','text','Units','normalized','Position',[.22 .06 .2 .05],...
    'String','New Event Type:','BackgroundColor',get(h,'Color'),...
    'FontSize',14,'Parent',h);

hEdit = uicontrol('Style','edit','Units','normalized','Position',[.425 .07 .15 .05],...
    'String','','BackgroundColor',[1 1 1],'FontSize',12,'Parent',h);

% --- PLOT --- %
NewPlot;

%allow markers to be clicked
set(hP,'hittest','off');
hold on;

%fnct to deal with keypresses
set(h,'KeyPressFcn',@KeyCtrl);

%fnct to deal with clicks
set(hA,'ButtonDownFcn',@MouseCtrl);

% --- BUTTONS --- %
wBtn = .15;
lInit = .5-((wBtn*4 + .05*3)/2);
uicontrol('Style','pushbutton','Units','normalized','Position',[lInit .01 .15 .05],...
    'String','Remove','Callback',@(x,y) PlotCtrl(x,y,'remove'),...
    'FontSize',12,'Parent',h);

uicontrol('Style','pushbutton','Units','normalized','Position',[lInit+.2 .01 .15 .05],...
    'String','Previous','Callback',@(x,y) PlotCtrl(x,y,'previous'),...
    'FontSize',12,'Parent',h);

uicontrol('Style','pushbutton','Units','normalized','Position',[lInit+.4 .01 .15 .05],...
    'String','Accept / Next','Callback',@(x,y) PlotCtrl(x,y,'accept'),...
    'FontSize',12,'Parent',h);

uicontrol('Style','pushbutton','Units','normalized','Position',[lInit+.6 .01 .15 .05],...
    'String','Done','Callback',@(x,y) PlotCtrl(x,y,'done'),...
    'FontSize',12,'Parent',h);

%give focus to the figure
set(hEdit,'Enable','off');
drawnow;
set(hEdit,'Enable','on');

%wait till user is done
uiwait(h)

%make the changes effective
FT_DATA.data.cfg.event = FT_DATA.event;

if ishandle(h)
    close(h);
end

%------------------------------------------------------------------------------%
function NewPlot
%refresh the stim channel plot and related text to reflect the event that is
%currently being reviewed / edited
    %get current event
    evt = FT_DATA.event(kData);
    kFinal = evt.sample;

    %get and plot stim channel surrounding current event
    kStart = kInt*evt.value;
    kEnd = kInt;
    dX = evt.sample-kStart:evt.sample+kEnd;
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
    strTitle = ['Event #' num2str(kData) '  -  Code ' num2str(evt.value) ': ''' strType ''''];
    if isempty(hTitle) || ~ishandle(hTitle)
        hTitle = text(xText,yText,strTitle,'FontSize',20,'FontWeight','bold','Units','data');
    else
        set(hTitle,'String',strTitle,'Position',[xText yText 0],'Units','data');
    end
    
    %make sure that the title is actually centered
    tExt = get(hTitle,'Extent');
    xLim = get(hA,'XLim');
    xText = mean(xLim) - tExt(3)/2;
    set(hTitle,'Position',[xText yText ]);
    
    %remove old legend
    hL = legend;
    if ishandle(hL)
        delete(hL);
    end
        
    %update edit box with default event type
    set(hEdit,'String',evt.type);
    
    %add new legend
    set(hLine,'DisplayName',['Code ' num2str(evt.value) ': ' strType]);    
    legend('show');
    set(legend,'Location','NorthWest');
    
    %fix x-axis tick labels
    xT = reshape(get(hA,'XTick'),[],1);
    xTL = arrayfun(@(x) num2str(x),xT,'uni',false);
    set(hA,'XTickLabel',xTL);
    
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
        case 'accept'
            kData = kData+1;
        case 'previous'
            kData = kData-1;
        case 'remove'
            kData = kData+1;            
        case 'done'
            uiresume(h);
            return;
        otherwise
            %this should never happen
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
    switch act
        case {'accept','previous'}
            strType = get(hEdit,'String');
            FT_DATA.event(kData).type = strType;
            FT_DATA.event(kData).sample = kFinal;
        case 'remove'
            FT_DATA.event(kData) = [];
        otherwise
            %this should never happend
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
                PlotCtrl([],[],'accept');
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
        [~,idx] = min( ((pt(1,1)-xp).*dx(2)).^2 + ((pt(1,2)-yp).*dx(1)).^2 );

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
    hL = line(x,y,'Color',col,'LineWidth',2);
    setappdata(hA,'CurrentPoint',hL);
end
%------------------------------------------------------------------------------%
end

