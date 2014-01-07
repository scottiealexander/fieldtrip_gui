function Resample(varargin)

% FT.Resample
%
% Description: run resampling GUI 
%
% Syntax: FT.Resample()
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
if ~FT.CheckStage('resample')
    return;
end

cfg 			= CFGDefault;
cfg.detrend 	= 'no'; %we'll have to check on these
cfg.demean 		= 'no';

bRun = false;

pFig = GetFigPosition(500,120);

%main sampling rate specification window
h = figure('Units','pixels','OuterPosition',pFig,...
        'Name','Resample Data','NumberTitle','off','MenuBar','none',...
        'KeyPressFcn',@KeyPress);

%text instructions
pLabel = [.2 .6 .42 .2];
uicontrol('Style','text','String','New Sampling Rate [Hz]:',...
        'Units','normalized','Position',pLabel,'FontSize',12,...
        'FontWeight','bold','BackgroundColor',get(h,'Color'),...
        'HorizontalAlignment','left','Parent',h);

hEdit = uicontrol('Style','edit','String','','Units','normalized',...
        'Position',[pLabel(3)+pLabel(1)+.01 pLabel(2)-.05 .1 .3],...
        'BackgroundColor',[1 1 1],'Parent',h);
    
tWidth = .45;
pBtn = [(1-tWidth)/2 .05 .2 .35];
uicontrol('Style','pushbutton','String','Run','Units','normalized',...
        'Position',pBtn,'Parent',h,'Callback',@BtnPress);
    
uicontrol('Style','pushbutton','String','Cancel','Units','normalized',...
        'Position',[pBtn(1)+(.2+.05) pBtn(2:4)],'Parent',h,'Callback',@BtnPress);
    
uicontrol(hEdit);
uiwait(h);


if ~FT_DATA.debug && bRun
    if isfield(FT_DATA,'event') && ~isempty(FT_DATA.event) && numel(FT_DATA.data.trial)==1
        resp = FT.UserInput(['Do you want to resample event indicies as well?\n\n'...
           'This is \color{red}required\color{black} if you want to segment the data \bfAFTER\rm resampling.'],1,...
           'title','Reasmple Events?','button',{'Yes','No'});
        bResampleEvt = strcmpi(resp,'yes');
    else
        bResampleEvt = false;
    end
    
    %resample the data
    hMsg = FT.UserInput('Resampling data...',1,'button',false);    
    FT_DATA.data = ft_resampledata(cfg,FT_DATA.data);
    
    %resample events
    if bResampleEvt
        ResampleEvents;
    end
    
    %fix trialdef
    FT_DATA.data.sampleinfo = [1 size(FT_DATA.data.trial{1},2)];
    [~,FT_DATA.data.cfg] = FT.EditCfg(FT_DATA.data.cfg,'set','trl',[FT_DATA.data.sampleinfo 0]);
    
    if ishandle(hMsg)
        close(hMsg);
    end

    %mark data as not saved
    FT_DATA.saved = false;
else
   %nothing to do 
end

if bRun
    %update the history
    FT_DATA.history.resample = cfg;
    FT_DATA.done.resample = true;

    FT.UpdateGUI;
end

%------------------------------------------------------------------------------%
function BtnPress(obj,evt)
    switch lower(get(obj,'String'))
        case 'run'
            fps = str2double(get(hEdit,'String'));
            if fps < FT_DATA.data.fsample && fps > 0
                cfg.resamplefs = fps;
                bRun = true;
                if ishandle(h)
                    close(h);
                end
            else
               FT.UserInput(['\bf\color{red}Invalid sampling rate given: \color{black}'...
                   'New rate should be between 0 and ' num2str(FT_DATA.data.fsample-1)],0,'button','OK');
               set(hEdit,'String','');
            end
        case 'cancel'
            bRun = false;
            if ishandle(h)
                close(h);
            end
        otherwise
            %will never happen
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
function ResampleEvents
%resample event indicies according to new sampling rate
    if isfield(FT_DATA,'event') && ~isempty(FT_DATA.event)
        fs_ratio = FT_DATA.data.fsample/FT_DATA.data.hdr.Fs;
        evt = FT.ReStruct(FT_DATA.event);
        evt.sample = ceil(evt.sample*fs_ratio);
        FT_DATA.event = FT.ReStruct(evt);
        FT_DATA.data.cfg.event = FT_DATA.event;
    else
        %events have not been read, nothing to do
    end
end
%------------------------------------------------------------------------------%
end