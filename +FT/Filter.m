function Filter(varargin)

% FT.Filter
%
% Description: run filtering GUI
%
% Syntax: FT.Filter
%
% In: 
%
% Out: 
%
% Updated: 2014-03-31
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

%make sure we are ready to run
if ~FT.CheckStage('filter')
    return;
end

[bLP,bHP,bNF] = deal(false);
bSelect = false;

cfg = CFGDefault;
cfg.continuous = 'yes';
cfg.channel    = 'all';

%open the figure for the GUI
pFig = GetFigPosition(360,280);
h = figure('Units','pixels','OuterPosition',pFig,...
        'Name','Filter Builder','NumberTitle','off','MenuBar','none','KeyPressFcn',@KeyPress);

bgColor = get(h,'Color');

hEdt = .12;

%select channels
    uicontrol('Style','text','String','Select Channels to filter: (default: all)',...
            'Units','normalized','FontSize',12,'FontWeight','bold',...
            'Position',[.08 .75 .55 .2],'BackgroundColor',bgColor,...
            'Parent',h);
    
    uicontrol('Style','pushbutton','Units','normalized','String','Select',...
            'Position',[.65 .83 .25 hEdt],'Callback',@SelectChannels,'Parent',h);
        
%highpass filter
    uicontrol('Style','text','String','Highpass Filter Frequency [Hz]:',...
            'Units','normalized','FontSize',12,'FontWeight','bold',...
            'Position',[0 .65 .7 .1],'BackgroundColor',bgColor,...
            'Parent',h);

    hHP = uicontrol('Style','edit','Units','normalized',...
            'Position',[.71 .65 .15 hEdt],'BackgroundColor',[1 1 1],...
            'KeyPressFcn',@KeyPress,'Parent',h);
        
%lowpass filter
    uicontrol('Style','text','String','Lowpass Filter Frequency [Hz]:',...
            'Units','normalized','FontSize',12,'FontWeight','bold',...
            'Position',[0 .45 .7 .1],'BackgroundColor',bgColor,...
            'Parent',h);

    hLP = uicontrol('Style','edit','Units','normalized',...
            'Position',[.71 .45 .15 hEdt],'BackgroundColor',[1 1 1],...
            'KeyPressFcn',@KeyPress,'Parent',h);

%remove line noise
    uicontrol('Style','text','String','Notch Filter [60,120,180 Hz]:',...
            'Units','normalized','FontSize',12,'FontWeight','bold',...
            'Position',[0 .25 .7 .1],'BackgroundColor',bgColor,...
            'Parent',h);
    hNotchP = uipanel(h,'Units','normalized','Position',[.71 .25 .1 hEdt],...
            'BackgroundColor',[1 1 1],'HighlightColor',bgColor);

    hNotch = uicontrol('Style','checkbox','Units','normalized',...
            'Position',[.2 .15 .55 .65],'BackgroundColor',[1 1 1],...
            'KeyPressFcn',@KeyPress,'Parent',hNotchP);

%run filtering button
    lBtn = .5 - (.2*2 + .05)/2;
    uicontrol('Style','pushbutton','String','Run','Units','normalized',...
            'Position',[lBtn .05 .2 .15],'Parent',h,'Callback',@BuildFilter);

%cancel button
    uicontrol('Style','pushbutton','String','Cancel','Units','normalized',...
        'Position',[lBtn+.25 .05 .2 .15],'Parent',h,'Callback',@CloseFig);

%give control to the highpass filter entry and wait until the figure is
%closed
uicontrol(hHP);
uiwait(h);

%perform the filtering 
%NOTE we are doing this in series to avoid errors thrown by ft_preprocessing
%when both hpfilter and lpfilter are specified and hpfreq < ~1Hz
nFilt = bHP + bLP + bNF;
if nFilt > 0
    cFilt = {'hpfilter','lpfilter','dftfilter'};
    hMsg = FT.UserInput('Filtering data...',1);
    bErr = false;
    for kA = 1:nFilt
        if nFilt > 1            
            cfg.(cFilt{kA}) = 'yes';
            kRM = setdiff(1:nFilt,kA);
            for kB = 1:numel(kRM)
                cfg.(cFilt{kRM(kB)}) = 'no';
            end
        end        
        try
            if bSelect            
                %only filter specified channels
                datTmp = ft_preprocessing(cfg,FT_DATA.data);
                
                %replace orig channels with result of filtering
                bNew = strcmpi(datTmp.label,FT_DATA.data.label);
                FT_DATA.data.trial{1}(bNew,:) = datTmp.trial{1};
            else
                %filter everything
                FT_DATA.data = ft_preprocessing(cfg,FT_DATA.data);
            end
        catch me
            bErr = true;
            FT.ProcessError(me);
            break;
        end
    end
    if ishandle(hMsg)
        close(hMsg);
    end
    
    if ~bErr
        %mark data as not saved
        FT_DATA.saved = false;
        
        %update the history
        FT_DATA.history.filter = cfg;
        FT_DATA.done.filter = true;

        FT.UpdateGUI;
    end
else
    %nothing to do
end

%------------------------------------------------------------------------------%
function KeyPress(obj,evt)
%allow the figure to be closed via Crtl+W shortcut
   switch lower(evt.Key)
       case 'w'
           if ismember(evt.Modifier,'control')
               CloseFig(obj,evt);
           end
       otherwise
   end
end
%------------------------------------------------------------------------------%
function CloseFig(obj,evt)
%close the figure if it's still open
    if ishandle(h)
        uiresume(h);
        close(h);
    end
end
%------------------------------------------------------------------------------%
function BuildFilter(obj,evt)
%build the filter configuration struct based on users selections
    %high and low pass filters
    hp = str2double(regexprep(get(hHP,'String'),'[^\d\.]*',''));
    lp = str2double(regexprep(get(hLP,'String'),'[^\d\.]*',''));
    cfg.hpfilter 	= Ternary(isempty(hp) || isnan(hp),'no','yes');
    cfg.lpfilter    = Ternary(isempty(lp) || isnan(lp),'no','yes');
    cfg.hpfreq      = hp;
    cfg.lpfreq      = lp;
    cfg.lpfilttype  = 'but'; %butterworth type filter
    cfg.hpfilttype  = 'but';
    cfg.hpfiltdir   = 'twopass'; %forward+reverse filtering
    cfg.lpfiltdir   = 'twopass';
    cfg.hpfiltord   = 6;
    cfg.hpinstabilityfix = 'reduce'; %deal with filter instability
    cfg.lpinstabilityfix = 'reduce';
    
    %line noise removal
    cfg.dftfilter = Ternary(get(hNotch,'Value'),'yes','no');
    cfg.dftfreq   = [60,120,180];
    
    bLP = strcmpi(cfg.lpfilter,'yes');
    bHP = strcmpi(cfg.hpfilter,'yes');
    bNF = strcmpi(cfg.dftfilter,'yes');
    CloseFig(obj,evt);
end
%------------------------------------------------------------------------------%
function SelectChannels(obj,evt)
%allow user to select specific channels for filtering    
    %set the height of the figure
    nChan = numel(FT_DATA.data.label);
    if nChan < 40
        hFig = 15.4*nChan;
    else
        hFig = 400;
    end
    
    %get the users selection
    [kChan,b] = listdlg('Name','Select Channels',...
       'ListString',FT_DATA.data.label,'ListSize',[210,hFig]);
    
   if b && ~isempty(kChan)
        cfg.channel = FT_DATA.data.label(kChan);            
        set(obj,'String','Done');
        bSelect = true;
   end
end
%------------------------------------------------------------------------------%
end