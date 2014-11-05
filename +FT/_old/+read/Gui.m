function Gui(varargin)

% FT.events.read.Gui
%
% Description: get parameters if necessary for translating pulses to
%              events
%
% Syntax: FT.events.read.Gui
%
% In: 
%
% Out: 
%
% Updated: 2014-10-09
% Scottie Alexander
%
% See also: FT.events.read.Run
%
% Please report bugs to: scottiealexander11@gmail.com


global FT_DATA;

if ~FT.tools.Validate('read_events','todo',{'define_trials'})
    return;
end

params = struct;

%get file format
[~,~,ext] = fileparts(FT_DATA.path.raw_file);
ext = regexprep(ext,'^\.','');
params.type = ext;

%convert code pulses to events if need be
if strcmpi(ext,'edf')
    params.type = 'edf';

    %set default channel
    stimChan = FT_DATA.data.label(strncmpi('stim',FT_DATA.data.label,4));
    if isempty(stimChan)
        if isempty(FT_DATA.data.label)
            FT.UserInput('No stim channels available.',0);
            return;
        else
            params.channel = FT_DATA.data.label{1};
        end
    else
        params.channel = stimChan{1};
    end
    
    evtLocation = {'start','end'};

    %get necessary information from user to auto convert pulses to events
    c = {...
        {'text','String','Select Stimulus Channel:'},...
        {'pushbutton','String',params.channel,'Callback',@SelectChannel};...
        {'text','String','Pulse Width [ms]:'},...
        {'edit','String','50','tag','width','valfun',{'inrange',1,inf,true}};...
        {'text','String','Pulse Interval [ms]:'},...
        {'edit','String','100','tag','interval','valfun',{'inrange',1,inf,true}};...
        {'text','String','Max Pulses per Event:'},...
        {'edit','String','8','tag','max_pulse','valfun',{'inrange',1,inf,true}};...
        {'text','string','Events occur at pulse train:'},...
        {'listbox','String',evtLocation,'value',2,'tag','loc','Callback'};...
        {'pushbutton','String','Run'},...
        {'pushbutton','String','Cancel','validate',false};...
        };

    win = FT.tools.Win(c,'title','Event-Processing Parameters');
    win.Wait;
    
    if strcmpi(win.res.btn,'cancel')
        return;
    end
    
    params.width = win.res.width;
    params.interval = win.res.interval;
    params.max_pulse = win.res.max_pulse;
    params.evt_at_start = strcmpi(evtLocation{win.res.loc},'start');
    
elseif strcmpi(ext,'')
    params.type = 'ncs';
    resp = FT.UserInput('Collapse Neuralynx Events?',1,'button',{'Yes','No'},'title','MESSAGE');
    params.collapse_nlx = strcmpi(resp,'yes');
end

hMsg = FT.UserInput('Reading events...',1);

me = FT.events.read.Run(params);

if ishandle(hMsg)
    close(hMsg);
end

FT.ProcessError(me);

FT.UpdateGUI;

%------------------------------------------------------------------------------%
function SelectChannel(obj,~)
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
        params.channel = FT_DATA.data.label{kChan};
        set(obj,'String',params.channel);        
    end
end
%------------------------------------------------------------------------------%
end
