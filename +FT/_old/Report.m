function h = Report(strMsg,vType,varargin)

% FT.Report
%
% Description: report a message (error or instructional) in a dialog box
%
% Syntax: h = FT.Report(strMsg,vType,bShowBtn)
%
% In: 
%       strMsg - the message as a string, tex markup is allowed
%                including:
%                     '\bf'           — bold font
%                     '\it'           — italic font
%                     '\rm'           — normal font
%                     '\fontname{fn}' — font family to use
%                     '\fontsize{fs}' — font size in FontUnits
%                     '\color{cs}'    — color for following chars *OR*
%                     '\color[rgd]{cs}— rgb color spec
%       vType - one of:
%                     0 - error message
%                     1 - information message
%   Options:
%       button - (true) true to show an 'OK' button, false to omit
%
% Out:
%       h - a handle to the report figure
%
% Updated: 2013-08-05
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt = FT.ParseOpts(varargin,...
    'button' , true ...
    );

%approx. number of charachers per line for word wrapping
nCharPerLine = 80;

%make sure no reports are currently open
hMsg = findobj('Tag','ft_report');
for kM = 1:numel(hMsg)
    if ishandle(hMsg(kM))
        delete(hMsg(kM));
    end
end

%which icon to display
strDirIcon = fullfile(fileparts(mfilename('fullpath')),'icon');
switch vType
    case 0
        strPathIcon = fullfile(strDirIcon,'error.png');
        strTitle = 'ERROR';
    case 1
        strPathIcon = fullfile(strDirIcon,'logo1.png');
        strTitle = 'Status';
    otherwise
        strPathIcon = fullfile(strDirIcon,'logo2.png');
        strTitle = 'Message';
end

%read and resize the icon
im = imread(strPathIcon);
im = imresize(im,[NaN 100]);

%get the size and position for the figure
rootUnits = get(0,'Units');
set(0,'Units','pixels');
sizScreen = get(0,'ScreenSize');
set(0,'Units',rootUnits);

wFig = 440;
hFig = 160;
lFig = (sizScreen(3)/2)-(wFig/2);
bFig = (sizScreen(4)/2)-(hFig/2);

%main figure
h = figure('Units','pixels','OuterPosition',[lFig bFig wFig hFig],...
           'Name',strTitle,'NumberTitle','off','MenuBar','none',...
           'KeyPressFcn',@KeyPress,'Tag','ft_report');

%axes for the icon
pAxIm = [10 (hFig/2)-30 round(wFig/6) (hFig/2)-10];
ax = axes('Color',[1 1 1],'Units','pixels','Position',pAxIm,'Parent',h);

%add icon
image(im,'Parent',ax);
set(ax,'Visible','off');

%axes for the text
lTxt = pAxIm(1)+pAxIm(3)+10;
pAxTxt = [lTxt 10 wFig-(lTxt+10) hFig-50];
ax2 = axes('Visible','off','Units','pixels','Position',pAxTxt,'Parent',h);

%allow newline escapes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: we may want to change this as it will screw up our word wrapping...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
strMsg = strrep(strMsg,'\n',char(10));

%add text
hT = text(0,.9,WrapMsg(strMsg),'FontSize',14,'Interpreter','tex');

% add the 'OK' button
if opt.button
    pBtn = [(wFig/2)-40 10 80 30];
    hOk = uicontrol('Style','pushbutton','String','OK','Position',pBtn,...
                'Parent',h,'Callback',@OkBtn);
else
    %this effectivly sets the bottom of the text box when no button is asked for
    pBtn = [0 0 0 10];
end

%get the extent of the text in figure units so that we can resize the figure to
%fit the text
pAxes = get(ax2,'Position');
nExt = Axes2Fig(ax2,get(hT,'Extent'));

%increase the width of the figure to fit the text
right = nExt(1)+nExt(3);
if right > wFig
    wFig = wFig + (right-wFig) + 10;
    set(h,'OuterPosition',[lFig,bFig,wFig,hFig]);
end

%center the text within the axes
top = nExt(2)+nExt(4);
if  top > hFig-30
    sep = (top/(hFig-30))-1;
    if sep > .4
        sep = .4;
    end
    set(hT,'Position',[0 .9-sep 0])    
    
    %recalcuate the text extent
    nExt = Axes2Fig(ax2,get(hT,'Extent'));
    
    %set the text axes position to encompass the text and sit above the button
    nExt(2) = pBtn(2)+pBtn(4);
    set(ax2,'Position',nExt);
end

%increase figure height
top = nExt(2)+nExt(4);
if  top > hFig - 30
    hFig = hFig + (top-(hFig-35));
    set(h,'OuterPosition',[lFig,bFig,wFig,hFig]);
    
    %move the image axes up to account for our new height
    pAxIm = get(ax,'Position');
    pAxIm(2) = (hFig-30)-pAxIm(4)-10;
    set(ax,'Position',pAxIm);
end

%recenter the figure
pFig = get(h,'Position');
set(h,'Position',[(sizScreen(3)/2)-(pFig(3)/2) (sizScreen(4)/2)-(pFig(4)/2) pFig(3:4)]);

%re-center the button and give it focus
if opt.button
    pBtn(1) = (wFig/2)-40;
    set(hOk,'Position',pBtn);
    uicontrol(hOk);
end

%force drawing of figure
drawnow;

%-------------------------------------------------------------------------%
function strLine = WrapMsg(strLine)
%word wrap the message to nCharPerLine
    if length(strLine) > nCharPerLine         
        kSpace = find(double(strLine)==32);            
        kInc = 0;           
        while kInc + nCharPerLine < length(strLine)
            kAdd = find(kSpace<=(kInc+nCharPerLine),1,'last'); 
            if ~isempty(kAdd)
                strLine(kSpace(kAdd)) = char(10);
                kInc = kSpace(kAdd)+1;
            else
                break
            end
        end
    end
end
%-------------------------------------------------------------------------%
function pos = Axes2Fig(hAx,pos)
%function to convert data units within an axes to normalized figure units
    pAxes = get(hAx,'Position');
    yLim = get(hAx,'YLim');
    yExt = yLim(2)-yLim(1);
    xLim = get(hAx,'XLim');
    xExt = xLim(2) - xLim(1);
        
    pos(1) = pAxes(1)+((pos(1)-xLim(1))/xExt)*pAxes(3);
    pos(2) = pAxes(2)+((pos(2)-yLim(1))/yExt)*pAxes(4);
    pos(3) = pos(3)*pAxes(3);%+pAxes(3);
    pos(4) = pos(4)*pAxes(4);%+pAxes(4);
end
%-------------------------------------------------------------------------%
function KeyPress(obj,evt)
%allow the figure to be closed via Crtl+W shortcut
   switch lower(evt.Key)
       case 'w'
           if ismember(evt.Modifier,'control')
               if ishandle(h)
                   close(h);
               end
           end
       otherwise
   end
end
%-------------------------------------------------------------------------%
function OkBtn(obj,evt)
    if ishandle(h)
        close(h);
    end
end
%-------------------------------------------------------------------------%
end