function hFIG = PlotCtrl(hFIG,cList,fUpdate,varargin)

% FT.PlotCtrl
%
% Description: update / control a plot based on user selection from a list
%
% Syntax: hFIG = FT.PlotCtrl(hFIG,cList,fUpdate,<options>)
%
% In:
%       hFIG    - the handel to the plot to control
%       cList   - a cell of possible choices for the user to select from
%       fUpdate - the handel to a function that takes one input: the item from
%                 cList that the subject selected
%   options:
%       close - (true) true to allow the plot_ctrl figure to close the figure
%               that it is controlling
%
% Out:
%       hFIG - the handle to the figure being controlled
%
% Updated: 2013-12-13
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt = FT.ParseOpts(varargin,...
    'close' , true ...
    );

if (isempty(hFIG) || ~ishandle(hFIG))
    pFig  = GetFigPosition(800,600);
    hFIG  = figure('Name','Power wave','Units','pixels','Position',pFig,...
               'NumberTitle','off','MenuBar','none','Color',[1 1 1]);    
    bShow = false;
else
    orig_units = get(hFIG,'Units');
    set(hFIG,'Units','pixels');
    pFig = get(hFIG,'Position');
    set(hFIG,'Units',orig_units);
    bShow = true;
end

%get the size and position for the figure
pCtrl = GetFigPosition(200,600,'xoffset',pFig(1)-250,'yoffset',pFig(2),'reference','absolute');

%main figure
h = figure('Units','pixels','OuterPosition',pCtrl,...
           'Name','Plot Control','NumberTitle','off','MenuBar','none',...
           'KeyPressFcn',@KeyPress);
       
hPanel = uipanel('Units','normalized','Position',[.05 .18 .9 .8],'HighlightColor',[0 0 0],...
    'Title','Selection Items','FontSize',12,'FontWeight','bold',...
    'BackgroundColor',[.8 .8 .8],'Parent',h);

hList = uicontrol('Style','listbox','Units','normalized','Position',[0 0 1 1],...
    'String',cList,'BackgroundColor',[1 1 1],'Parent',hPanel);

uicontrol('Style','pushbutton','Units','normalized','Position',[.05 .1 .4 .05],...
    'String','Plot','Parent',h,'Callback',@PlotBtn);

uicontrol('Style','pushbutton','Units','normalized','Position',[.55 .1 .4 .05],...
    'String','Close','Parent',h,'Callback',@CloseBtn);

uicontrol('Style','pushbutton','Units','normalized','Position',[.05 .02 .4 .05],...
    'String','Previous','Parent',h,'Callback',@StepBtn);

uicontrol('Style','pushbutton','Units','normalized','Position',[.55 .02 .4 .05],...
    'String','Next','Parent',h,'Callback',@StepBtn);

%show the first item if the user gave us a valid figure
if bShow
    PlotBtn([],[]);
end

%------------------------------------------------------------------------------%
function RmAxes
    hChild = get(hFIG,'Children');
    if ~isempty(hChild)
       bAx = strcmpi(get(hChild,'Type'),'axes');
       delete(hChild(bAx));
    end
end
%------------------------------------------------------------------------------%
function StepBtn(obj,evt)
    kItem = get(hList,'Value');
    switch lower(get(obj,'String'))
        case 'next'
            if kItem < numel(cList)
                kItem = kItem+1;
            end
        case 'previous'
            if kItem > 1
                kItem = kItem-1;
            end
        otherwise
            %this should never happen...
    end
    set(hList,'value',kItem)
    PlotBtn(obj,evt);
end
%------------------------------------------------------------------------------%
function PlotBtn(obj,evt)
    kItem = get(hList,'Value');
    RmAxes;
    fUpdate(cList{kItem});
end
%------------------------------------------------------------------------------%
function CloseBtn(obj,Evt)
    if ishandle(hFIG) && opt.close
        close(hFIG);
    end
    if ishandle(h)
        close(h);
    end
    hFIG = [];
end
%------------------------------------------------------------------------------%
end