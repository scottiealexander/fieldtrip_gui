function me = Run(cfg)

% FT.processevents.Run
%
% Description: read events or translate them from pulses
%
% Syntax: me = FT.processevents.Run(cfg)
%
% In: 
%       cfg - a fieldtrip configuration struct holding parameters or processing events
%             see 'FT.processevents.Gui'
%
% Out:
%       me - an empty matrix if processing finished with out error, otherwise a
%            MException object caught from the error
%
% Updated: 2014-06-23
% Peter Horak
%
% See also: FT.processevents.Gui
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;
me = [];

if ~cfg.edf
    %use fieldtrip's ft_definetrial
    try
        cfg = ft_definetrial(cfg);
        FT_DATA.event = cfg.event;
    catch me
    end
else
    %auto convert pulses to events
    try
        %perform the filtering
        datChan = ft_preprocessing(cfg,FT_DATA.data); % why not FT.filter.Run(cfg)?

        %overwirte the old stim channel with the filtered one
        FT_DATA.data.trial{1}(strcmpi(cfg.channel,FT_DATA.data.label),:) = datChan.trial{1}(1,:);
        FT_DATA.pulse_evts.channel = cfg.channel;
        FT_DATA.pulse_evts.width = cfg.width;
        FT_DATA.pulse_evts.interval = cfg.interval;
        FT_DATA.pulse_evts.max_pulse = cfg.max_pulse;
        FT_DATA.pulse_evts.fs = FT_DATA.data.fsample;
    catch me
    end
    if isempty(me)
        %detect and translate events
        FT_DATA.event = FT.processevents.Pulse2Event(datChan.trial{1}(1,:),FT_DATA.data.fsample,...
                        'width'     , cfg.width     ,...
                        'interval'  , cfg.interval  ,...
                        'max_pulse' , cfg.max_pulse  ...
                        );

        %make sure struct is Nx1 array of structs to be consistent with ft_definetrial (above)
        if numel(FT_DATA.event) == 1
            FT_DATA.event = FT.ReStruct(FT_DATA.event);
        end
        FT_DATA.data.cfg.event = FT_DATA.event;
    end
end

%mark data as not saved
FT_DATA.saved = false;

%update the history
FT.tools.AddHistory('detect_events',cfg);
FT_DATA.done.read_events = FT.tools.Ternary(isempty(me),true,false);

end