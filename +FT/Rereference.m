function Rereference(varargin)

% FT.ReReference
%
% Description: run rereferenceing GUI
%
% Syntax: FT.ReReference()
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

%make sure we are ready to run
if ~FT.CheckStage('rereference')
    return;
end

cfg = CFGDefault;
cfg.reref       = 'yes'; 		 	%we want to rereference
cfg.channel     = 'all'; 		 	%channels to reref, all of course
cfg.implicitref = [];    		 	%the implicit (non-recorded) reference channel is added to the data representation (we'll have to figure out what this is if any)

bRun = false;

pFig = GetFigPosition(480,120);

%main reference selection figure
h = figure('Units','pixels','OuterPosition',pFig,...
        'Name','Rereference Data','NumberTitle','off','MenuBar','none',...
        'KeyPressFcn',@KeyPress);

%text instructions
uicontrol('Style','text','String','Please specifiy the new reference.',...
        'Units','normalized','Position',[0 .7 1 .2],'FontSize',12,...
        'FontWeight','bold','BackgroundColor',get(h,'Color'),'Parent',h);

%buttons for selecting new reference
tWidth = .65;
pBtn = [(1-tWidth)/2 .2 .3 .35];
uicontrol('Style','pushbutton','String','Avg. of all channels',...
        'Units','normalized','Position',pBtn,'Parent',h,'Callback',@AvgReference);
    
uicontrol('Style','pushbutton','String','Select channels',...
        'Units','normalized','Position',[pBtn(1)+(.3+.05) pBtn(2:4)],'Parent',h,...
        'Callback',@SelectReference);

uiwait(h);

%rereference
if bRun
    hMsg = FT.UserInput('Rereferencing data...',1);
    FT_DATA.data = ft_preprocessing(cfg, FT_DATA.data);
    
    if ishandle(hMsg)
        close(hMsg);
    end
    
    %mark data as not saved
    FT_DATA.saved = false;
    
    %update the history
    FT_DATA.history.rereference = cfg;
    FT_DATA.done.rereference = true;

    FT.UpdateGUI;
else
    %nothing to do
end

%-------------------------------------------------------------------------%
function AvgReference(obj,evt)
%new reference is the average of all channels
    cfg.refchannel = 'all';
    bRun = true;
    if ishandle(h)
        uiresume(h);
        close(h);
    end
end
%-------------------------------------------------------------------------%
function SelectReference(obj,evt)
%allow user to select specific channels for new reference
        
    %set the height of the figure
    nChan = numel(FT_DATA.data.label);
    if nChan < 40
        hFig = 15.4*nChan;
    else
        hFig = 400;
    end
    
    %get the users selection
    [kChanRef,bRun] = listdlg('Name','Select New Reference',...
       'ListString',FT_DATA.data.label,'ListSize',[210,hFig]);
   
    if bRun
        cfg.refchannel = FT_DATA.data.label(kChanRef);
        
        %close the main figure
        if ishandle(h)
            uiresume(h);
            close(h);
        end
    end
    
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
end