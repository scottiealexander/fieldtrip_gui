function me = Run(params)

% FT.events.Run
%
% Description: read events or translate them from pulses
%
% Syntax: me = FT.events.Run(params)
%
% In: 
%       params - a struct holding parameters from the user for processing events
%             see 'FT.events.Gui'
%
% Out:
%       me - an empty matrix if processing finished with out error, otherwise a
%            MException object caught from the error
%
% Updated: 2014-06-23
% Peter Horak
%
% See also: FT.events.Gui
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;
me = [];

cfg = FT.tools.CFGDefault(params);

try
    switch lower(cfg.type)
        case 'edf'
            %auto convert pulses to events
            %the stim channel needs to be filtered to detect events
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
            FT_DATA.data.trial{1}(strcmpi(cfg.channel,FT_DATA.data.label),:) = datChan.trial{1}(1,:);
            FT_DATA.pulse_evts.channel = cfg.channel;
            FT_DATA.pulse_evts.width = cfg.width;
            FT_DATA.pulse_evts.interval = cfg.interval;
            FT_DATA.pulse_evts.max_pulse = cfg.max_pulse;
            FT_DATA.pulse_evts.fs = FT_DATA.data.fsample;                
            %detect and translate events
            FT_DATA.event = Pulse2Event(datChan.trial{1}(1,:),FT_DATA.data.fsample,...
                            'width'     , cfg.width     ,...
                            'interval'  , cfg.interval  ,...
                            'max_pulse' , cfg.max_pulse  ...
                            );

            %make sure struct is Nx1 array of structs to be consistent with ft_definetrial (above)
            if numel(FT_DATA.event) == 1
                FT_DATA.event = FT.ReStruct(FT_DATA.event);
            end
            FT_DATA.data.cfg.event = FT_DATA.event;

        case 'nlx'
            ReadNLXEvents;

        otherwise
            %just let fieldtrip handle the events...
            cfg.trialdef.triallength = Inf;
            cfg.dataset = FT_DATA.path.raw_file;
            cfg = ft_definetrial(cfg);
            
            %format the event values to be a user friendly as possible
            evt = FT.ReStruct(cfg.event);
            if iscell(evt.value)
                bEmpty = cellfun(@isempty,evt.value);
                evt    = structfieldfun(@(x) x(~bEmpty),evt);
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
                FT_DATA.event = FT.ReStruct(evt);
            end            
    end
catch me
end

%mark data as not saved
FT_DATA.saved = false;

%update the history
FT.tools.AddHistory('detect_events',params);
FT_DATA.done.read_events = FT.tools.Ternary(isempty(me),true,false);

end
