classdef TSPlot < handle

% TSPlot
%
% Description: a class for plotting time series data
%
% Syntax: ts = TSPlot(x,y,<options>)
%
% In:
%       x - a array or cell of arrays of x-data
%       y - a array or cell of arrays of y-data
%   options:
%       title  - ('') 
%       error  - ([])
%       xlabel - ('')
%       ylabel - ('')
%       zeros  - true
%       legend - {}
%       w      - 800
%       h      - 600
%       parent - []
%       axes   - []
%
% Out: 
%       ts - a TSPlot object
%
% Methods: 
%
% Updated: 2013-12-11
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

%PRIVATE PROPERTIES------------------------------------------------------------%
properties (SetAccess=private)
    opt;
    label = struct('title',[],'xlabel',[],'ylabel',[]);    
    data = struct('x',[],'y',[],'err',[]);
    color;
    hF;
    hA;
    hL = [];
    hP = [];
    hBox;
    hZero;
end
%PRIVATE PROPERTIES------------------------------------------------------------%

%PUBLIC METHODS----------------------------------------------------------------%
methods
    %--------------------------------------------------------------------------%
    function ts = TSPlot(x,y,varargin)
    %ts = TSPlot
    %   constructor for TSPlot class
        ts.opt = FT.ParseOpts(varargin,...
            'title'  , 'TITLE'  ,...
            'xlabel' , 'x-axis' ,...
            'ylabel' , 'y-axis' ,...
            'zeros'  , true     ,...
            'error'  , []       ,...
            'legend' , {}       ,...
            'w'      , 800      ,...
            'h'      , 600      ,...
            'parent' , []       ,...
            'axes'   , []        ...
            );        

        ts.data.x = ToCell(x);
        ts.data.y = ToCell(y);
        
        %fill x arrays to match number of y arrays
        if numel(ts.data.x) == 1 && numel(ts.data.y) > 1
            ts.data.x = repmat(ts.data.x,size(ts.data.y));
        end
        
        %allow row-wise matrix plotting: so y can be a NxM matrix where N is the
        %number of variable and M is the number of observation (so x MUST be a
        %1xM or Mx1 array / cell of arrays)
        if numel(ts.data.x) == 1 && numel(ts.data.y) == 1 && ~any(size(ts.data.y{1})==1)
            d = ts.data.y{1};
            ts.data.y = mat2cell(d,ones(size(d,1),1),size(d,2));
            ts.data.x = repmat(ts.data.x,size(ts.data.y));
        end
        
        if ~isempty(ts.opt.error)
            ts.data.err = ToCell(ts.opt.error);
        end
        
        pFig = GetFigPosition(ts.opt.w,ts.opt.h);
        
        if isempty(ts.opt.parent)
            ts.hF = figure('Units','pixels','OuterPosition',pFig,...
               'Name','TS-Plot','NumberTitle','off','MenuBar','none',...
               'Color',[1 1 1],'KeyPressFcn',@KeyPress);        
        elseif ishandle(ts.opt.parent) && strcmpi(get(ts.opt.parent,'type'),'figure')
            ts.hF = ts.opt.parent;
        else
            error('parent options MUST be a figure handle');
        end
        
        if isempty(ts.opt.axes)
            ts.hA = axes('Parent',ts.hF,'Units','normalized','OuterPosition',[0 0 1 1],...
                'Box','off','LineWidth',2);
        elseif ishandle(ts.opt.axes) && strcmpi(get(ts.opt.axes,'type'),'axes')
            ts.hA = ts.opt.axes;
            set(ts.hA,'Parent',ts.hF,'Units','normalized','Box','off','LineWidth',2);
        else
            error('axes options MUST be a figure handle');
        end

        ts.AddLines; 
        ts.SetLimits;       
        ts.AddLabels;
        drawnow;
    end
    %--------------------------------------------------------------------------%
    function display(varargin)
       fprintf('<TSPlot object>\n');
    end    
    %--------------------------------------------------------------------------%
    function Close(ts)
       close(ts.hF);
    end
    %--------------------------------------------------------------------------%
    function AddLines(ts)
        
        col = GetColor(numel(ts.data.x));
        for k = 1:numel(ts.data.x)
            ts.hL(end+1,1) = line(ts.data.x{k},ts.data.y{k},'Color',col(k,:),...
                                  'LineWidth',2,'Parent',ts.hA);
        end
        legend(ts.hA,ts.opt.legend{:});
        ts.color = col;        
        ts.AddError;                
        
        if ts.opt.zeros
            ts.hZero(1,1) = line([0 0],get(ts.hA,'YLim'),'Color',[.5 .5 .5],...
                'LineWidth',2,'LineStyle','--','Parent',ts.hA);
            ts.hZero(2,1) = line(get(ts.hA,'XLim'),[0 0],'Color',[.5 .5 .5],...
                'LineWidth',2,'LineStyle','--','Parent',ts.hA);
            ts.SendToBack(ts.hZero);
        end
    end
    %--------------------------------------------------------------------------%
    function AddError(ts)
        if ~isempty(ts.data.err)
            if numel(ts.data.err) ~= numel(ts.data.y)
                error('error is missing for one or more input datasets');
            end
            for k = 1:numel(ts.data.x)
                xD = reshape(ts.data.x{k},[],1);
                xD = [xD;xD(end:-1:1)];
                yD = reshape(ts.data.y{k},[],1);
                eD = reshape(ts.data.err{k},[],1);
                err = [yD + eD; yD(end:-1:1) - eD(end:-1:1)];
                [colErr,colEdge] = ts.GetErrCol(ts.color(k,:));                
                ts.hP(end+1,1) = patch(xD,err,colErr,'EdgeAlpha',1,'EdgeColor',colEdge,'Parent',ts.hA);
            end
            ts.SendToBack(ts.hP);
        end
    end
    %--------------------------------------------------------------------------%
    function AddLabels(ts)
        c = {'title','xlabel','ylabel'};
        for k = 1:numel(c)            
            set(get(ts.hA,c{k}),'String',ts.opt.(c{k}),'FontSize',14);
        end
    end
    %--------------------------------------------------------------------------%
    function SetLimits(ts)
        xMin = min(cellfun(@min,ts.data.x));
        xMax = max(cellfun(@max,ts.data.x));

        if ~isempty(ts.data.err)
            yMin = nanmin(cellfun(@(a,b) nanmin(a-b),ts.data.y,ts.data.err));       
            yMax = nanmax(cellfun(@(a,b) nanmax(a+b),ts.data.y,ts.data.err));
        else
            yMin = nanmin(cellfun(@nanmin,ts.data.y));       
            yMax = nanmax(cellfun(@nanmax,ts.data.y));
        end

        set(ts.hA,'XLim',[xMin,xMax],'YLim',[yMin,yMax]);
        
        xLine = [xMin xMin; xMin xMax];
        yLine = [yMin yMin; yMax yMin];
        ts.hBox = line(xLine,yLine,'Color',[0 0 0],'LineWidth',2,'Clipping','off','Parent',ts.hA);
       
    end    
    %--------------------------------------------------------------------------%
    function [colErr,colEdge] = GetErrCol(ts,col)
        fErr = 8;
        fEdge = .25;
        hsv = rgb2hsv(col);
        hsv(2) = hsv(2)/fErr;
        hsv(3) = 1 - abs(1-hsv(2))^fErr/fErr;        
        colErr = hsv2rgb(min(1,hsv));
        colEdge = (1-fEdge)*colErr + fEdge*col;
    end
    %--------------------------------------------------------------------------%
    function SendToBack(ts,h)
        hChild = reshape(get(ts.hA,'Children'),[],1);
        h = reshape(h,[],1);
        hChild(ismember(hChild,h)) = [];
        hChild = [hChild;h];
        set(ts.hA,'Children',hChild);
    end
    %--------------------------------------------------------------------------%        
end
%PUBLIC METHODS----------------------------------------------------------------%
end