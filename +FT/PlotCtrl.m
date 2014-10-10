function [hFIG,hCTRL] = PlotCtrl(hFIG,cList,fUpdate,varargin)

% FT.PlotCtrl
%
% Description: update / control / save a plot based on user selection from a list
%
% Syntax: [hFIG,hCTRL] = FT.PlotCtrl(hFIG,cList,fUpdate,<options>)
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
%       hCTRL - the handle to the controlling figure
%
% Updated: 2014-10-10
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

opt = FT.ParseOpts(varargin,...
    'close' , true ...
    );

nItem = numel(cList);
jump_pcent = .1;

if (isempty(hFIG) || ~ishandle(hFIG))
    pFig  = GetFigPosition(800,600);
    hFIG  = figure('Name','Plot','Units','pixels','Position',pFig,...
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
pCtrl = GetFigPosition(200,600,'xoffset',pFig(1)-210,'yoffset',pFig(2),'reference','absolute');

set(hFIG,'KeyPressFcn',@KeyCtrl);

%main figure
hCTRL = figure('Units','pixels','OuterPosition',pCtrl,...
           'Name','Plot Control','NumberTitle','off','MenuBar','none',...
           'KeyPressFcn',@KeyCtrl);
       
hPanel = uipanel('Units','normalized','Position',[.05 .18 .9 .8],'HighlightColor',[0 0 0],...
    'Title','Selection Items','FontSize',12,'FontWeight','bold',...
    'BackgroundColor',[.8 .8 .8],'Parent',hCTRL);

hList = uicontrol('Style','listbox','Units','normalized','Position',[0 0 1 1],...
    'String',cList,'BackgroundColor',[1 1 1],'Parent',hPanel);

uicontrol('Style','pushbutton','Units','normalized','Position',[.05 .12 .4 .05],...
    'String','Plot','Parent',hCTRL,'Callback',@PlotBtn);

uicontrol('Style','pushbutton','Units','normalized','Position',[.55 .12 .4 .05],...
    'String','Close','Parent',hCTRL,'Callback',@CloseBtn);

hPrev = uicontrol('Style','pushbutton','Units','normalized','Position',[.05 .06 .4 .05],...
    'String','Previous','Parent',hCTRL,'Callback',@StepBtn);

hNxt = uicontrol('Style','pushbutton','Units','normalized','Position',[.55 .06 .4 .05],...
    'String','Next','Parent',hCTRL,'Callback',@StepBtn);

hSav = uicontrol('Style','pushbutton','Units','normalized','Position',[.3 0 .4 .05],...
    'String','Save','Parent',hCTRL,'Callback',@SaveBtn);

%show the first item if the user gave us a valid figure
if bShow
    PlotBtn;
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
function SaveBtn(obj,varargin)
    hChild  = get(hFIG,'Children');
    bAx     = strcmpi(get(hChild,'Type'),'axes');
    bAx     = bAx & ~strcmpi(get(hChild,'Tag'),'legend');
    if sum(bAx) > 1
        strName = 'figure';
    elseif sum(bAx) == 1
        strName = regexprep(get(get(hChild(bAx),'Title'),'String'),'\W+','_');
    else
        error('Das ist foul...');
    end
    strDir  = fileparts(FT_DATA.path.dataset);
    if isempty(strDir)
        strDir = pwd;
    end
    x       = pwd;
    try
        cd(strDir)
        [strName,strDir] = uiputfile('*.svg','Save Figure As',[strName '.svg']);
        cd(x);
    catch me
        cd(x);
        FT.ProcessError(me);
        return;
    end
    if isequal(strName,0)
        return;
    end
    plot2svg(fullfile(strDir,strName),hFIG);    
end
%------------------------------------------------------------------------------%
function StepBtn(obj,varargin)
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
    PlotBtn;
end
%------------------------------------------------------------------------------%
function PlotBtn(varargin)
    kItem = get(hList,'Value');
    RmAxes;
    fUpdate(cList{kItem});    
end
%------------------------------------------------------------------------------%
function CloseBtn(varargin)
    if ishandle(hFIG) && opt.close
        close(hFIG);
    end
    if ishandle(hCTRL)
        close(hCTRL);
    end
    hFIG = [];
end
%------------------------------------------------------------------------------%
function KeyCtrl(obj,evt)
    switch lower(evt.Key)
        case {'return','space'}
            PlotBtn;
        case 'leftarrow'
            StepBtn(hPrev);
        case 'rightarrow'
            StepBtn(hNxt);
        case 'downarrow'
            kItem = get(hList,'Value');
            if kItem < numel(cList)
                set(hList,'Value',kItem+1);
            end
        case 'uparrow'
            kItem = get(hList,'Value');
            if kItem > 1
                set(hList,'Value',kItem-1);
            end
        case 'pageup'
            kItem = get(hList,'Value');
            kItem = floor(kItem-(nItem*jump_pcent));
            if kItem < 1
                kItem = 1;
            end
            set(hList,'Value',kItem);            
        case 'pagedown'
            kItem = get(hList,'Value');
            kItem = floor(kItem+(nItem*jump_pcent));
            if kItem > nItem
                kItem = nItem;
            end
            set(hList,'Value',kItem);            
        case 'home'
            set(hList,'Value',1);            
        case 'end'
            set(hList,'Value',nItem);            
        case 'escape'
            CloseBtn;
        case 'w'
           if ismember(evt.Modifier,'control')
               CloseBtn;
           end
        otherwise
            %some other key...
    end
end
%------------------------------------------------------------------------------%
end