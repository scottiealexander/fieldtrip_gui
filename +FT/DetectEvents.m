function DetectEvents(varargin)

% FT.DetectEvents
%
% Description: convert stimulus channel pulse sequences to events
%
% Syntax: FT.DetectEvents
%
% In: 
%
% Out: 
%
% Updated: 2013-08-13
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

cfg = CFGDefault;
cfg.channel = [];
bRun = false;
width = 50;
interval = 50;
max_pulse = 8;

pFig = GetFigPosition(480,300);

%open the figure for the GUI
h = figure('Units','pixels','OuterPosition',pFig,...
        'Name','Automatic Event Detection','NumberTitle','off','MenuBar','none','KeyPressFcn',@KeyPress);

bgColor = get(h,'Color');

%function to calculate bottom of each ui element
fB = @(x) 1-(.18*x);
hUI = .12;

%select channel
    defChan = FT_DATA.data.label(strncmpi('stim',FT_DATA.data.label,4));
    if isempty(defChan)
        defChan = '';
    else
        defChan = defChan{1};
    end
    uicontrol('Style','text','String','Select Stimulus Channel:',...
            'Units','normalized','FontSize',12,'FontWeight','bold',...
            'Position',[.01 fB(1)-.03 .42 hUI],'BackgroundColor',bgColor,'Parent',h);
    
    eSel = uicontrol('Style','edit','Units','normalized','String',defChan,...
            'BackgroundColor',[1 1 1],'Position',[.43 fB(1) .19 hUI],'Parent',h);
        
    uicontrol('Style','pushbutton','Units','normalized','String','Select Channel From List',...
            'Position',[.64 fB(1) .35 hUI],'Callback',@SelectChannel,'Parent',h);

%get pulse parameters
    uicontrol('Style','text','String','Pulse Width [ms]:',...
            'Units','normalized','FontSize',12,'FontWeight','bold',...
            'Position',[.07 fB(2)-.03 .42 hUI],'BackgroundColor',bgColor,'Parent',h);
    
    eWidth = uicontrol('Style','edit','Units','normalized','String',num2str(width),...
            'BackgroundColor',[1 1 1],'Position',[.43 fB(2) .12 hUI],'Parent',h);

    uicontrol('Style','text','String','Pulse Interval [ms]:',...
            'Units','normalized','FontSize',12,'FontWeight','bold',...
            'Position',[.055 fB(3)-.03 .42 hUI],'BackgroundColor',bgColor,'Parent',h);
    
    eInt = uicontrol('Style','edit','Units','normalized','String',num2str(interval),...
            'BackgroundColor',[1 1 1],'Position',[.43 fB(3) .12 hUI],'Parent',h);

    uicontrol('Style','text','String','Max Pulses per Event:',...
            'Units','normalized','FontSize',12,'FontWeight','bold',...
            'Position',[.065 fB(4)-.03 .5 hUI],'BackgroundColor',bgColor,...
            'HorizontalAlignment','left','Parent',h);
    
    eMax = uicontrol('Style','edit','Units','normalized','String',num2str(max_pulse),...
            'BackgroundColor',[1 1 1],'Position',[.43 fB(4) .12 hUI],'Parent',h);


%buttons
    wBtn = .2;
    uicontrol('Style','pushbutton','Units','normalized','String','Run',...
            'Position',[.5-(wBtn+.05) fB(5) wBtn hUI],'Callback',@BtnPress,'Parent',h);
        
    uicontrol('Style','pushbutton','Units','normalized','String','Cancle',...
            'Position',[.55 fB(5) wBtn hUI],'Callback',@BtnPress,'Parent',h);

uicontrol(eSel);
uiwait(h);

if bRun
    %filter the stim channel
    cfg.hpfilter 	= 'yes';
    cfg.lpfilter    = 'yes';
    cfg.hpfreq      = 2;%.5;
    cfg.lpfreq      = 15;
    cfg.lpfilttype  = 'but'; %butterworth type filter
    cfg.hpfilttype  = 'but';
    cfg.hpfiltdir   = 'twopass'; %forward+reverse filtering
    cfg.lpfiltdir   = 'twopass';
    
    hMsg = FT.UserInput('Filtering stimulus channel...',1);
    try
        %perform the filtering
        datChan = ft_preprocessing(cfg,FT_DATA.data);
        
        %overwirte the old stim channel with the filtered one
        FT_DATA.data.trial{1}(strcmpi(cfg.channel,FT_DATA.data.label),:) = datChan.trial{1}(1,:);
        FT_DATA.pulse_evts.channel = cfg.channel;
        FT_DATA.pulse_evts.width = width;
        FT_DATA.pulse_evts.interval = interval;
        FT_DATA.pulse_evts.max_pulse = max_pulse;
        FT_DATA.pulse_evts.fs = FT_DATA.data.fsample;
        bErr = false;
    catch me
        bErr = true;
        FT.ProcessError(me);
    end
    if ishandle(hMsg)
        close(hMsg);
    end
        
    if ~bErr
        hMsg = FT.UserInput('Detecting and translating events...',1);
        FT_DATA.event = Pulse2Event(datChan.trial{1}(1,:),FT_DATA.data.fsample,...
                        'width'     , width     ,...
                        'interval'  , interval  ,...
                        'max_pulse' , max_pulse  ...
                        );
        if ishandle(hMsg)
            close(hMsg);
        end
        
        %update done list
        FT_DATA.done.read_events = true;
        FT_DATA.saved = false;
        FT_DATA.history.detect_events = cfg;
        FT.UpdateGUI        
    end
end

%------------------------------------------------------------------------------%
function SelectChannel(obj,evt)
%allow user to select the stim channel    
    %set the height of the figure
    nChan = numel(FT_DATA.data.label);
    if nChan < 40
        hFig = 15.4*nChan;
    else
        hFig = 400;
    end
    
    %get the users selection
    [kChan,bRun] = listdlg('Name','Select Stim Channel',...
       'ListString',FT_DATA.data.label,'ListSize',[210,hFig],...
       'SelectionMode','single');
   if bRun
       cfg.channel = FT_DATA.data.label{kChan};
       set(eSel,'String',cfg.channel);
   end
end
%------------------------------------------------------------------------------%
function BtnPress(obj,evt)
    switch lower(get(obj,'String'))
        case 'run'
            
            %get the channel
            strChan = get(eSel,'String');
            if isempty(cfg.channel) && ~isempty(strChan)
                bMatch = strncmpi(strChan,FT_DATA.data.label,length(strChan));
                if sum(bMatch) ~= 1
                    strMsg = ['\bf\color{red}' strChan ' \color{black}is not a recognized channel label'...
                        ' or matches multiple channels. Check the channel list and try again.'];
                    FT.UserInput(strMsg,0,'button','OK');
                else
                    cfg.channel = FT_DATA.data.label{bMatch};
                    bRun = true;
                end
            elseif isempty(cfg.channel) && isempty(strChan)
                strMsg = '\bfPlease enter or select the stimulus channel to use.';
                FT.UserInput(strMsg,0,'button','OK');
            else
                bRun = true;
            end
            
            %get the pulse width
            w = GetNumericValue(eWidth,width,'width');
            if isnan(w)
                bRun = false;
               return;
            else
               width = w; 
            end
            
            %get the pulse interval
            int = GetNumericValue(eInt,interval,'interval');
            if isnan(int)
                bRun = false;
               return;
            else
               interval = int;
            end
            
            %get the pulse interval
            mx = GetNumericValue(eMax,max_pulse,'#');
            if isnan(mx)
                bRun = false;
               return;
            else
               max_pulse = mx;
            end
            
            if ishandle(h) && bRun
                uiresume(h);
                close(h);
            end
        case 'cancle'
            bRun = false;
            if ishandle(h)
                uiresume(h);
                close(h);
            end
        otherwise
            %this should never happen
    end
end
%------------------------------------------------------------------------------%
function num = GetNumericValue(hE,default,type)
    str = get(hE,'String');
    if ~isempty(str)
       num = str2double(str);
       if isnan(num)
           strMsg = ['\bf[\color{red}ERROR\color{black}]: Invalid pulse ',...
                     type '. Entry must be a number.'];
           FT.UserInput(strMsg,0,'button','OK');
           uicontrol(hE);
       end
    else
        num = default;
    end
end
%------------------------------------------------------------------------------%
end