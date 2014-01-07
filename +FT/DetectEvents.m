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

cfg.channel = [];
bRun = false;

pFig = GetFigPosition(480,160);

%open the figure for the GUI
h = figure('Units','pixels','OuterPosition',pFig,...
        'Name','Automatic Event Detection','NumberTitle','off','MenuBar','none','KeyPressFcn',@KeyPress);

bgColor = get(h,'Color');

%select channel
    defChan = FT_DATA.data.label(strncmpi('stim',FT_DATA.data.label,4));
    if isempty(defChan)
        defChan = '';
    else
        defChan = defChan{1};
    end
    uicontrol('Style','text','String','Select Stimulus Channel:',...
            'Units','normalized','FontSize',12,'FontWeight','bold',...
            'Position',[.01 .54 .42 .25],'BackgroundColor',bgColor,'Parent',h);
    
    eSel = uicontrol('Style','edit','Units','normalized','String',defChan,...
            'BackgroundColor',[1 1 1],'Position',[.43 .6 .19 .25],'Parent',h);
        
    uicontrol('Style','pushbutton','Units','normalized','String','Select Channel From List',...
            'Position',[.64 .6 .35 .25],'Callback',@SelectChannel,'Parent',h);
%buttons
    wBtn = .2;
    uicontrol('Style','pushbutton','Units','normalized','String','Run',...
            'Position',[.5-(wBtn+.05) .2 wBtn .25],'Callback',@BtnPress,'Parent',h);
        
    uicontrol('Style','pushbutton','Units','normalized','String','Cancle',...
            'Position',[.55 .2 wBtn .25],'Callback',@BtnPress,'Parent',h);

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
        FT_DATA.stim_chan = cfg.channel;
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
        FT_DATA.event = Pulse2Event(datChan.trial{1}(1,:),FT_DATA.data.fsample);
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
%------------------------------------------------------------------------------%
end