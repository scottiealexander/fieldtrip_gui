function me = Run(params)

% FT.events.read.Run
%
% Description: read events or translate them from pulses
%
% Syntax: me = FT.events.read.Run(params)
%
% In: 
%       params - a struct holding parameters from the user for processing events
%             see 'FT.events.Gui'
%
% Out:
%       me - an empty matrix if processing finished with out error, otherwise a
%            MException object caught from the error
%
% Updated: 2014-07-08
% Scottie Alexander
%
% See also: FT.events.read.Gui
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;
me = [];

cfg = FT.tools.CFGDefault;

try
    if strcmpi(params.type,'edf')
        %auto convert pulses to events
        %the stim channel needs to be filtered to detect events
        cfg.channel     = params.channel;
        cfg.hpfilter 	= 'yes';
        cfg.lpfilter    = 'yes';
        cfg.hpfreq      = 2;
        cfg.lpfreq      = 15;
        cfg.lpfilttype  = 'but'; %butterworth type filter
        cfg.hpfilttype  = 'but';
        cfg.hpfiltdir   = 'twopass'; %forward+reverse filtering
        cfg.lpfiltdir   = 'twopass';

        %perform the filtering
        datChan = ft_preprocessing(cfg,FT_DATA.data); % why not FT.filter.Run(cfg)?

        %overwirte the old stim channel with the filtered one
        FT_DATA.data.trial{1}(strcmpi(params.channel,FT_DATA.data.label),:) = datChan.trial{1}(1,:);
        FT_DATA.pulse_evts.channel = params.channel;
        FT_DATA.pulse_evts.width = params.width;
        FT_DATA.pulse_evts.interval = params.interval;
        FT_DATA.pulse_evts.max_pulse = params.max_pulse;
        FT_DATA.pulse_evts.fs = FT_DATA.data.fsample;                
        %detect and translate events
        FT_DATA.event = Pulse2Event(datChan.trial{1}(1,:),FT_DATA.data.fsample,...
                        'width'       , params.width       ,...
                        'interval'    , params.interval    ,...
                        'max_pulse'   , params.max_pulse   ,...
                        'evt_at_start', params.evt_at_start ...
                        );
    else
        %just let fieldtrip read the events...
        cfg.continuous = 'yes';
        cfg.trialdef.triallength = Inf;
        cfg.dataset = FT_DATA.path.raw_file;
        cfg = ft_definetrial(cfg);

        %format the event values to be as user friendly as possible
        evt = FT.ReStruct(cfg.event);
        if iscell(evt.value)
            bEmpty = cellfun(@isempty,evt.value);
            evt    = structfun(@(x) x(~bEmpty),evt,'uni',false);
            bNum   = cellfun(@isnumeric,evt.value);
            if ~any(bNum)
                evt.value(cellfun(@isempty,evt.value)) = {''};
                evt.value = cellfun(@(x) regexprep(x,'\s+',''),evt.value,'uni',false);
            elseif all(bNum)
                evt.value(cellfun(@isempty,evt.value)) = {NaN};
                evt.value = cat(1,evt.value{:});
            else
                error('Poorly formated event code values. Please contact the developer with the circumstances of this error'); 
            end
        end
        FT_DATA.event = FT.ReStruct(evt);

        %neuralynx events
        if strcmpi(params.type,'ncs')
            ParseNLXEvents;
        end
    end
    
    %make sure struct is Nx1 array of structs to be consistent with ft_definetrial (above)
    if numel(FT_DATA.event) == 1
        FT_DATA.event = FT.ReStruct(FT_DATA.event);
    end
    FT_DATA.data.cfg.event = FT_DATA.event;
    
    % Make the event types match the event values (but always be strings)
    events = FT.ReStruct(FT_DATA.event);
    if ~iscell(events.value)
        events.type = arrayfun(@(x) num2str(x),events.value,'uni',false);
    else
        events.type = cellfun(@(x) num2str(x),events.value,'uni',false);
    end
    FT_DATA.event = FT.ReStruct(events);

catch me
end

%mark data as not saved
FT_DATA.saved = false;

%update the history
FT.tools.AddHistory('read_events',params);
FT_DATA.done.read_events = isempty(me);

end
