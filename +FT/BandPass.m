function BandPass()

% FT.BandPass
%
% Description: 
%
% Syntax: FT.BandPass
%
% In: 
%
% Out: 
%
% Updated: 2013-12-12
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

%make sure we are ready to run
if ~FT.CheckStage('filter')
    return;
end

bRun    = false;
bSelect = false;

cfg = CFGDefault;
cfg.continuous = 'yes';
cfg.channel    = 'all';

%open the figure for the GUI
pFig = GetFigPosition(360,200);
h = figure('Units','pixels','OuterPosition',pFig,...
        'Name','Filter Builder','NumberTitle','off','MenuBar','none','KeyPressFcn',@KeyPress);

bgColor = get(h,'Color');

hEdt = .15;

%select channels
    uicontrol('Style','text','String','Select Channels to filter: (default: all)',...
            'Units','normalized','FontSize',12,'FontWeight','bold',...
            'Position',[.08 .7 .55 .2],'BackgroundColor',bgColor,...
            'Parent',h);
    
    uicontrol('Style','pushbutton','Units','normalized','String','Select',...
            'Position',[.65 .78 .25 hEdt],'Callback',@SelectChannels,'Parent',h);
        
%bandpass low
    uicontrol('Style','text','String','Bandpass Low Frequency [Hz]:',...
            'Units','normalized','FontSize',12,'FontWeight','bold',...
            'Position',[0 .55 .7 .1],'BackgroundColor',bgColor,...
            'Parent',h);

    hLo = uicontrol('Style','edit','Units','normalized',...
            'Position',[.71 .55 .15 hEdt],'BackgroundColor',[1 1 1],...
            'KeyPressFcn',@KeyPress,'Parent',h);
        
%bandpass high
    uicontrol('Style','text','String','Bandpass High Frequency [Hz]:',...
            'Units','normalized','FontSize',12,'FontWeight','bold',...
            'Position',[0 .3 .7 .1],'BackgroundColor',bgColor,...
            'Parent',h);

    hHi = uicontrol('Style','edit','Units','normalized',...
            'Position',[.71 .3 .15 hEdt],'BackgroundColor',[1 1 1],...
            'KeyPressFcn',@KeyPress,'Parent',h);

%run filtering button
    lBtn = .5 - (.2*2 + .05)/2;
    uicontrol('Style','pushbutton','String','Run','Units','normalized',...
            'Position',[lBtn .05 .2 .15],'Parent',h,'Callback',@BuildFilter);

%cancel button
    uicontrol('Style','pushbutton','String','Cancel','Units','normalized',...
        'Position',[lBtn+.25 .05 .2 .15],'Parent',h,'Callback',@CloseFig);

%give control to the bandpass low entry and wait until the figure is
%closed
uicontrol(hLo);
uiwait(h);

%perform the filtering
if bRun
    hMsg = FT.UserInput('Filtering data...',1);
    bErr = false;
    try
        if bSelect
            %only filter specified channels            
            datTmp = ft_preprocessing(cfg,FT_DATA.data);                        
            
            %temporal zscore
            datTmp.trial{1} = zscore(datTmp.trial{1},[],2);
            
            cfg = CFGDefault;
            cfg.hilbert = 'abs';
            
            datTmp = ft_preprocessing(cfg,datTmp);                        
            
            %replace orig channels with result of filtering
            bNew = strcmpi(datTmp.label,FT_DATA.data.label);
            
            %power = abs(H(t)).^2 where H(t) is the Hilbert xfm
            FT_DATA.data.trial{1}(bNew,:) = datTmp.trial{1}.^2;
        else
            %filter everything
            FT_DATA.data = ft_preprocessing(cfg,FT_DATA.data);
            
            %temporal zscore
            FT_DATA.data.trial{1} = zscore(FT_DATA.data.trial{1},[],2);
            
            cfg = CFGDefault;
            cfg.hilbert = 'abs';
            
            %power = abs(H(t)).^2 where H(t) is the Hilbert xfm
            FT_DATA.data = ft_preprocessing(cfg,FT_DATA.data);
            FT_DATA.data.trial{1} = FT_DATA.data.trial{1}.^2;
        end
    catch me
        bErr = true;
        FT.ProcessError(me);
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
function BuildFilter(obj,evt)
%build the filter configuration struct based on users selections
    %high and low pass filters
    lo = str2double(regexprep(get(hLo,'String'),'[^\d\.]*',''));
    hi = str2double(regexprep(get(hHi,'String'),'[^\d\.]*',''));
    if isempty(lo) || isnan(lo)
        bRun  = false;
        uicontrol(hLo);
        strMsg = ['\bf[\color{red}ERROR\color{black}]: invalid ',...
                  'low frequency: ''\color[rgb]{1 .08 .6}' get(hLo,'String') '\color{black}''.'];
        FT.UserInput(strMsg,0,'button','OK','title','Invalid Value','wrap',false);
    elseif isempty(hi) || isnan(hi)
        bRun = false;
        uicontrol(hHi);
        strMsg = ['\bf[\color{red}ERROR\color{black}]: invalid ',...
                  'high frequency : ''\color[rgb]{1 .08 .6}' get(hHi,'String') '\color{black}''.'];
        FT.UserInput(strMsg,0,'button','OK','title','Invalid Value','wrap',false);
    else
        cfg.bpfilter 	= 'yes';
        cfg.bpfreq      = [lo hi];    
        cfg.bpfilttype  = 'but';         %butterworth type filter
        cfg.bpfiltdir   = 'twopass';     %forward+reverse filtering
        cfg.bpinstabilityfix = 'reduce'; %deal with filter instability        

        bRun = true;
        CloseFig(obj,evt);
    end    
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
function CloseFig(obj,evt)
%close the figure if it's still open
    if ishandle(h)
        uiresume(h);
        close(h);
    end
end
%------------------------------------------------------------------------------%
end