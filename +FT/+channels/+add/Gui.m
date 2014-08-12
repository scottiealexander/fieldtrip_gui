function Gui(varargin)

% FT.channels.add.Gui
%
% Description: provide expressions for creating new channels
%
% Syntax: FT.channels.add.Gui
%
% In: 
%
% Out: 
%
% Updated: 2014-08-12
% Peter Horak
%
% See also: FT.channels.add.Run

global FT_DATA;

%make sure we are ready to run
if ~FT.tools.Validate('add_channel','todo',{'segment_trials'})
    return;
end

%max number of characters (digits) in a label index 
nMax = floor(log10(numel(FT_DATA.data.label)))+1;

%map each channel lable to it's index to help the user make their equations
cLabels = cellfun(@(x,y) [ 'ch' sprintf(['%' num2str(nMax) '.0f'],x) ' -  ' strrep(y,'-REF','')],num2cell(reshape(1:numel(FT_DATA.data.label),[],1)),FT_DATA.data.label,'uni',false);
strLabel = FT.Join(cLabels,10);

%get the size and position for the figure
pFig = FT.tools.FT.tools.GetFigPosition(300,600,'xoffset',450);

%channel label guide figure
h = figure('Units','pixels','OuterPosition',pFig,...
           'Name','Channel Labels','NumberTitle','off','MenuBar','none',...
           'KeyPressFcn',@KeyPress);

%pretty frame
hPanel = uipanel('Units','normalized','Position',[.1 0 .8 1],'HighlightColor',[0 0 0],'Parent',h);

%labels box, this has to be an edit box to get the scroll bar so we just
% turn the enable property to inactive to prevent the user from editing it
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
[params.cExp,btn] = FT.UserInput(strInst,1,'title','New Channel','input',true,'button',{'OK','Cancel'},'nline',3);

%close the label figure
if ishandle(h)
    close(h);
end

%make sure the user entered something usable
if isempty(params.cExp) || strcmpi(btn,'cancel')
    return;
end

hMsg = FT.UserInput('Adding channels...',1);

me = FT.channels.add.Run(params);

if ishandle(hMsg)
    close(hMsg);
end

% So the user doesn't get confused and think there's a bug when they enter
% an invalid expression. Eventually FT.channels.add.Gui should be made to
% check that the input expressions are valid before calling run.
if isa(me,'MException')
    FT.UserInput('\bf[\color{red}ERROR\color{black}]: Could not parse the given expressions.',0,'title','Error','button',{'OK'});
end
% FT.ProcessError(me);

FT.UpdateGUI;

end
