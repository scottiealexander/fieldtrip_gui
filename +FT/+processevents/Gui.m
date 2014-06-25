function Gui(varargin)

% FT.processevents.Gui
%
% Description: get parameters if necessary for translating pulses to
% events
%
% Syntax: FT.processevents.Gui
%
% In: 
%
% Out: 
%
% Updated: 2014-06-23
% Peter Horak
%
% See also: FT.processevents.Run
%
% Please report bugs to: scottiealexander11@gmail.com


global FT_DATA;

if ~FT.CheckStage('read_events')
    return;
end

cfg = FT.tools.CFGDefault;
cfg.channel = [];

%get file format
[~,~,ext] = fileparts(FT_DATA.path.raw_file);
ext = strrep(ext,'.','');

%convert code pulses to events if need be
if strcmpi(ext,'edf')
    cfg.type = 'edf';

    %set default channel
    stimChan = FT_DATA.data.label(strncmpi('stim',FT_DATA.data.label,4));
    if isempty(stimChan)
        if isempty(FT_DATA.data.label)
            FT.UserInput('No stim channels available.',0);
            return;
        else
            cfg.channel = FT_DATA.data.label{1};
        end
    else
        cfg.channel = stimChan{1};
    end

    %get necessary information from user to auto convert pulses to events
    c = {...
        {'text','String','Select Stimulus Channel:'},...
        {'pushbutton','String',cfg.channel,'Callback',@SelectChannel};...
        {'text','String','Pulse Width [ms]:'},...
        {'edit','size',5,'String','50','tag','width','valfun',{'inrange',1,inf,true}};...
        {'text','String','Pulse Interval [ms]:'},...
        {'edit','size',5,'String','50','tag','interval','valfun',{'inrange',1,inf,true}};...
        {'text','String','Max Mulses per Event:'},...
        {'edit','size',5,'String','8','tag','max_pulse','valfun',{'inrange',1,inf,true}};...
        {'pushbutton','String','Run'},...
        {'pushbutton','String','Cancel','validate',false};...
        };

    win = FT.tools.Win(c,'title','Event-Processing Parameters');
    uiwait(win.h);
    
    if strcmpi(win.res.btn,'cancel')
        return;
    end
    
    cfg.width = win.res.width;
    cfg.interval = win.res.interval;
    cfg.max_pulse = win.res.max_pulse;
    
elseif ~isfield(FT_DATA,'event') || isempty(FT_DATA.event)  
    cfg.type = '';
    cfg.trialdef.triallength = Inf;
    cfg.dataset = FT_DATA.path.raw_file;
else
    %nothing to do
    return;
end

hMsg = FT.UserInput('Reading events...',1);

me = FT.processevents.Run(cfg);

if ishandle(hMsg)
    close(hMsg);
end

FT.ProcessError(me);

FT.UpdateGUI;

%------------------------------------------------------------------------------%
function SelectChannel(obj,evt)
%allow user to select the stim channel    
    %set the height of the figure
    nChan = numel(FT_DATA.data.label);
    if nChan < 40
        hFig = FT.tools.Inch2Px(0.171)*nChan;
    else
        hFig = FT.tools.Inch2Px(5);
    end
    wFig = FT.tools.Inch2Px(2.5);
    
    %get the users selection
    [kChan,b] = listdlg('Name','Select Stim Channel',...
       'ListString',FT_DATA.data.label,'ListSize',[wFig,hFig],...
       'SelectionMode','single');
    if b && ~isempty(kChan)
        cfg.channel = FT_DATA.data.label{kChan};
        set(obj,'String',cfg.channel);        
    end
end
%------------------------------------------------------------------------------%
end
