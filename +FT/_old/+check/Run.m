function me = Run(params)

% FT.events.check.Run
%
% Description: remove or adjust the start index of events
%
% Syntax: me = FT.events.check.Run(params)
%
% In:   params - a struct holding parameters from the user
%
% Out:  me - an empty matrix if processing finished with out error,
%            otherwise a MException object caught from the error
%
% Updated: 2014-08-12
% Peter Horak
%
% See also: FT.events.check.Gui

global FT_DATA;
me = [];

try
    if isfield(params,'remove')
        FT_DATA.event(params.remove) = [];
        FT_DATA.data.cfg.event = FT_DATA.event;
    end
    if isfield(params,'adjust')
        FT_DATA.event(params.adjust.kData).type = params.adjust.type;
        FT_DATA.event(params.adjust.kData).sample = params.adjust.sample;
    end
catch me
end

%mark data as not saved
FT_DATA.saved = false;

%update the history
FT.tools.AddHistory('check_events',params);
FT_DATA.done.check_events = isempty(me);

end
