function [output,strBtn] = UserInput(strMsg,vType,varargin)

% FT.UserInput
%
% Description: get user input via button or input box
%
% Syntax: [output,strBtn] = FT.UserInput(strMsg,vType,<options>)
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
%                     '\color[rgb]{cs}— rgb color spec
%       vType - one of:
%                     0 - error message
%                     1 - status message
%   options:
%       button - (<none>) a cell of buttons to show, set to false or 
%                leave empty to omit
%       input  - (false) true to add a input box above the buttons (buttons are
%                required if this option is set)
%       nline  - (1) the number of lines for the input box (>1 means multiline)
%       inp_str- ('') the default string for the input box
%       title  - (<auto>) the title for the UserInput figure
%       wrap   - (true) false to turn off automatic text wrapping
%
% Out:
%       output - *IF* no buttons or input box are displayed, output is a handle 
%                to the UserInput figure. *IF* an input box is shown, the output
%                is the string that the user entered, *ELSE* if just a 
%                button(s) is/are shown then the output is the string of the 
%                button that the user selected
%       strBtn - *IF* an input box is shown, the string of the button that the
%                user selected, *OTHERWISE* an empty string ''
%
% Updated: 2013-08-20
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt = FT.ParseOpts(varargin,...
    'button' , []     ,...
    'input'  , false  ,...
    'nline'  , 1      ,...
    'inp_str', ''     ,...
    'title'  , ''     ,...
    'wrap'   , true    ...
    );

output = '';
strBtn = '';

%approx. number of charachers per line for word wrapping
nCharPerLine = 80;

top_pad = 45;

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

%override default title with the user specified one
if ~isempty(opt.title) && ischar(opt.title)
    strTitle = opt.title;
end

%read and resize the icon
im = imread(strPathIcon);
im = imresize(im,[NaN 100]);

%get the size and position for the figure
siz = get(0,'ScreenSize');
% wFig = 440;
% hFig = 160;
% lFig = (siz(3)/2)-(wFig/2);
% bFig = (siz(4)/2)-(hFig/2);

pFig = GetFigPosition(440,160);

%main figure
h = figure('Units','pixels','OuterPosition',pFig,... %[lFig bFig wFig hFig],...
           'Name',strTitle,'NumberTitle','off','MenuBar','none',...
           'KeyPressFcn',@KeyPress,'Tag','ft_report');

tmp = get(h,'Position');
lFig = tmp(1);
bFig = tmp(2);
wFig = tmp(3);
hFig = tmp(4);

%axes for the icon
pAxIm = [10 (hFig/2)-top_pad round(wFig/6) (hFig/2)];
ax = axes('Color',[1 1 1],'Units','pixels','Position',pAxIm,'Parent',h);

%add icon
image(im,'Parent',ax);
set(ax,'Visible','off');

%axes for the text
lTxt = pAxIm(1)+pAxIm(3)+10;
pAxTxt = [lTxt 10 wFig-(lTxt+10) hFig-top_pad];
ax2 = axes('Visible','off','Units','pixels','Position',pAxTxt,'Parent',h);

%allow newline escapes
strMsg = strrep(strMsg,'\n',char(10));

%escape '_' chars as we are using tex interpretation
strMsg = strrep(strMsg,'_','\_');
if opt.wrap
    cMsg = regexp(strMsg,'\n','split');
    cMsg = reshape(cellfun(@WrapMsg,cMsg,'uni',false),1,[]);
    strMsg = FT.Join(cMsg,10);
end
%add text
hT = text(0,.9,strMsg,'FontSize',14,'Interpreter','tex');

%allow user to set button to false to omit
if islogical(opt.button) && ~opt.button
    opt.button = [];
end

% add the buttons
if ~isempty(opt.button) || opt.input
    %make sure we have a valid input
    if ischar(opt.button) && ~isempty(opt.button)
        opt.button = {opt.button};
    elseif isempty(opt.button) || ~iscell(opt.button)
        opt.button = {'OK'};
    end
    
    nBtn = numel(opt.button);
    hBtn = zeros(nBtn,1);
    
    %starting left position of button group
    wBtn = 90;
    lInit = (wFig - (wBtn*nBtn+10*(nBtn-1)))/2;
    
    %add the buttons
    for k = 1:nBtn
        pad = 10*(k-1);
        pBtn = [lInit+(k-1)*wBtn+pad 10 wBtn 30];
        hBtn(k) = uicontrol('Style','pushbutton','String',opt.button{k},'Position',pBtn,...
                    'Parent',h,'Callback',@BtnPress);
    end
    
    %keep track for positioning the text
    opt.button = true;
    txtBtm = pBtn(2)+pBtn(4);
    
    %add input box
    if opt.input
        if opt.nline <= 1
            opt.nline = 1;
            hiInp = 30;
        else
            if opt.nline > 5 %5 line max, user can scroll if they need more room
                opt.nline = 2;
            end
            hiInp = 17*opt.nline;
        end
            
        wInp = 260;
        pInp = [(wFig-wInp)/2 pBtn(2)+pBtn(4)+10 wInp hiInp];
        hInp = uicontrol('Style','edit','String',opt.inp_str,'Position',pInp,...
                    'BackgroundColor',[1,1,1],'Min',0,'Max',opt.nline,'Parent',h);
        %keep track for positioning the text
        txtBtm = pInp(2)+pInp(4);
    end
else
    %this effectivly sets the bottom of the text box when no button is asked for
    opt.button = false;
    txtBtm = 10;
end

%get the extent of the text in figure units so that we can resize the figure to
%fit the text
nExt = Axes2Fig(ax2,get(hT,'Extent'));

%increase the width of the figure to fit the text
right = nExt(1)+nExt(3);
if right > wFig
    wFig = wFig + (right-wFig) + top_pad;
    set(h,'OuterPosition',[lFig,bFig,wFig,hFig+10]);
end

%center the text within the axes
top = nExt(2)+nExt(4);
if  top > hFig-(top_pad+5)
    sep = (top/(hFig-(top_pad+5)))-1;
    if sep > .4
        sep = .4;
    end
    set(hT,'Position',[0 .9-sep 0])    
    
    %recalcuate the text extent
    nExt = Axes2Fig(ax2,get(hT,'Extent'));
    
    %set the text axes position to encompass the text and sit above the button
    pAx = get(ax2,'Position');
    pAx(2) = txtBtm;
    pAx(3) = max(nExt(3),pAx(3));
    pAx(4) = max(nExt(4),pAx(4));
    set(ax2,'Position',pAx);
end

%increase figure height
nExt = Axes2Fig(ax2,get(hT,'Extent'));
top = nExt(2)+nExt(4);
if  top > hFig - top_pad
    hFig = hFig + (top-(hFig-(top_pad+5)));
    set(h,'OuterPosition',[lFig,bFig,wFig,hFig]);
    
    %move the image axes up to account for our new height
    pAxIm = get(ax,'Position');
    pAxIm(2) = (hFig-top_pad)-pAxIm(4)-10;
    set(ax,'Position',pAxIm);
end

%recenter the figure
pFig = get(h,'Position');
set(h,'Position',[(siz(3)/2)-(pFig(3)/2) (siz(4)/2)-(pFig(4)/2) pFig(3:4)]);

%re-center the button(s) and input box as needed
if opt.button
    lInit = (pFig(3) - (wBtn*nBtn+10*(nBtn-1)))/2;
    for k = 1:nBtn
        pad = 10*(k-1);
        pBtn = [lInit+(k-1)*wBtn+pad 10 wBtn 30];
        set(hBtn(k),'Position',pBtn);
    end
    if opt.input
        pInp = [(pFig(3)-wInp)/2 pBtn(2)+pBtn(4)+10 wInp hiInp];
        set(hInp,'Position',pInp);
        uicontrol(hInp);
    else
        uicontrol(hBtn(1));
    end    
    
    %wait until the user presses the button
    uiwait(h);
else
    %force drawing of figure before we exit
    drawnow;
    pause(.1);
    
    %output the handle to the UserInput figure
    output = h;
end

%-------------------------------------------------------------------------%
function strLine = WrapMsg(strLine)
%word wrap the message to nCharPerLine
    %remove matlab html display link if any
    strLine = regexprep(strLine,'<[^>]*>','');
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
    pAx  = get(hAx,'Position');
    yLim = get(hAx,'YLim');
    yExt = yLim(2)-yLim(1);
    xLim = get(hAx,'XLim');
    xExt = xLim(2)-xLim(1);
        
    pos(1) = pAx(1)+((pos(1)-xLim(1))/xExt)*pAx(3);
    pos(2) = pAx(2)+((pos(2)-yLim(1))/yExt)*pAx(4);
    pos(3) = (pos(3)/yExt) * pAx(3);
    pos(4) = (pos(4)/yExt) * pAx(4);
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
function BtnPress(obj,evt)
    %get the btn that the pressed
    strBtn = get(obj,'String');
    
    if opt.input
        output = get(hInp,'String');
        if opt.nline > 1
            output = ReformatStr(output,'cell',true);
        end
    else
        output = strBtn;
        strBtn = '';
    end
        
    if ishandle(h)
        close(h);
    end
end
%-------------------------------------------------------------------------%
end