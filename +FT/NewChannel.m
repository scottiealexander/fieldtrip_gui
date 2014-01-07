function str = NewChannel(varargin)

% FT.NewChannel
%
% Description: create a new channel by combining existing channels
%
% Syntax: FT.NewChannel
%
% In: 
%
% Out: 
%
% Updated: 2013-08-09
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA

%make sure we are ready to run
if ~FT.CheckStage('new_channel')
    return;
end

%make sure data is continuous (i.e. only 1 trial)
if numel(FT_DATA.data.trial) > 1
    FT.UserInput('\bf\color{red}ERROR: \color{black}New channels can only be added to continuous data!',0,'button','OK');
end

%max number of characters (digits) in a label index 
nMax = floor(log10(numel(FT_DATA.data.label)))+1;

%map each channel lable to it's index to help the user make their equations
cLabels = cellfun(@(x,y) [ 'ch' Fill(num2str(x),nMax) ' -  ' strrep(y,'-REF','')],num2cell(reshape(1:numel(FT_DATA.data.label),[],1)),FT_DATA.data.label,'uni',false);
strLabel = FT.Join(cLabels,10);

%get the size and position for the figure
pFig = GetFigPosition(300,600,'xoffset',450);

%channel label guide figure
h = figure('Units','pixels','OuterPosition',pFig,...
           'Name','Channel Labels','NumberTitle','off','MenuBar','none',...
           'KeyPressFcn',@KeyPress);

%pretty frame
hPanel = uipanel('Units','normalized','Position',[.1 0 .8 1],'HighlightColor',[0 0 0],'Parent',h);

%labels box, this has to be an edit box to get the scroll bar...
% ([BLEEP]ing matlab...) so we just turn the enable property to inactive to
% prevent the user from editing it
uicontrol('Style','edit','Units','normalized','Position',[0 0 1 1],...
            'String',strLabel,'Parent',hPanel,'BackgroundColor',[1 1 1],...
            'HorizontalAlignment','left','Max',2,'Min',0,'Enable','Inactive');
        
%instructions for the user with examples
strInst = ['\bfPlease enter an equation for a new channel:\rm\n'... 
    'You must refer to channels by their number (ch#) as shown in the \n'...
    '''Channel Labels'' window to the right (see examples below).\n'...
    '\fontsize{10}ex: VEOG = ch56 - ch67\n'...
    '     HEOG = abs(ch58 - ch59)\n'...
    '     Amygd = mean(ch12,ch13,ch14,ch19)\n'...
    '     newChan = (ch15 * 10) + abs(mean(ch13,ch14)) - 15'];

%get the equation
[cExp,btn] = FT.UserInput(strInst,1,'title','New Channel','input',true,'button',{'OK','Cancel'},'nline',3);

%close the label figure
if ishandle(h)
    close(h);
end

%make sure the user entered something usable
if isempty(cExp) || strcmpi(btn,'cancel')
    return;
end

for k = 1:numel(cExp)
    if isempty(cExp{k})
        %skip ahead to next loop iteration
        continue;
    end
    %parse the equation and re-format calls to 'mean' to be compatible with Matlab 
    %syntax
    sChan = FT.ParseEquation(cExp{k});

    %swap ch# convention with eval-able variable and index notation
    strExpr = regexprep(sChan.expr,'ch(\d+)','FT_DATA.data.trial{1}($1,:)');

    %perform the operation and add the new channel to the data
    try
        newChan = eval(strExpr);
        FT_DATA.data.trial{1}(end+1,:) = newChan;
        bErr = false;
    catch me
        %try and point the user towards a solution or allow them to send an error
        %report to the developer
        bErr = true;
        strMsg = ['\bfMATLAB reports the following error when performing\n' ...
                  'the operation that you specified:\n\rm\color{red}'...
                  '             "' me.message '"\n\n'...
                  '\color{black}Please check your equation and try again '...
                  'or press "Send Report"\nto send an error report to the developer.'];

        strResp = FT.UserInput(strMsg,0,'button',{'Continue','Send Report'},'wrap',false);
        if strcmpi(strResp,'send report')
            s = struct('message',me.message,'cause',cExp{k},'stack',me.stack);
            FT.ReportError(s);
        end
    end

    if ~bErr
        %add the label for the new channel
        kChan = numel(FT_DATA.data.label)+1;
        FT_DATA.data.label{kChan} = sChan.label;
        
        %set saved field and update history
        FT_DATA.saved = false;
        FT_DATA.history.add_channel.(sChan.label) = sChan.raw;            
    end
end

FT.UpdateGUI;

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
function str = Fill(str,n)
%this is JUST to fill the channel index - label mapping string for display in a
%uicontrol edit object, i have no idea why we need to add so many spaces...
%matlab???
    len = length(str);
    if len < n
        if len == 1
            len = 0;
        end
        str = [str repmat(' ',1,(n-len)+1)];
    end
end
%-------------------------------------------------------------------------%
end