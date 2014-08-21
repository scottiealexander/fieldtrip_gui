function me = Run(params)

% FT.events.relabel.Run
%
% Description: relabel events according to the given parameters
%
% Syntax: FT.events.relabel.Run
%
% In:   params - a struct holding parameters from the user
%
% Out:  me - an empty matrix if processing finished with out error,
%            otherwise a MException object caught from the error
%
% See also: FT.events.relabel.Gui
%
% Updated: 2014-08-21
% Peter Horak

global FT_DATA;
me = [];

try
    events = FT.ReStruct(FT_DATA.event); % events
    events.value = cellfun(@(x) num2str(x),events.value,'uni',false); % make sure values are strings
    values = unique(events.value); % event values
    
    for i = 1:numel(values)
        if isfield(params,values{i})
            bSet = strcmpi(events.value,values{i});
            events.type(bSet) = params.(values{i})(:);
        end
    end

    FT_DATA.event = FT.ReStruct(events);
    [~,FT_DATA.data.cfg] = FT.EditCfg(FT_DATA.data.cfg,'set','event',FT_DATA.event);
catch me
end

FT_DATA.saved = false;
FT.tools.AddHistory('relabel_events',params);
FT_DATA.done.relabel_events = isempty(me);

end