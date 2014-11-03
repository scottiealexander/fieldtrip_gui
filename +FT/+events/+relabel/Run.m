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
    % Restructure the events struct
    events = FT.ReStruct(FT_DATA.event);
    evtVals = events.value;
    
    % Make sure the evtVals is a cell of strings that can be field names
    if ~iscell(evtVals)
        evtVals = arrayfun(@(x) num2str(x),evtVals,'uni',false);
    elseif ~iscellstr(evtVals)
        evtVals = cellfun(@(x) num2str(x),evtVals,'uni',false);
    end
    ver = version('-release');
    if str2double(ver(1:4)) >= 2014
        evtVals = matlab.lang.makeValidName(evtVals);
    else
        evtVals = cellfun(@(x) genvarname(x),evtVals,'uni',false);
    end
    
    % One of each value that appears
    values = unique(evtVals);
    
    % Initialize all the event to a type of none
    events.type(:) = {'none'};

    % For eachevent value
    for i = 1:numel(values)
        % If params contains a field for events with this value
        if isfield(params,values{i})
            % Apply the label (or code file) from params to these events
            bSet = strcmpi(evtVals,values{i});
            labels = FT.events.relabel.ProcLabel(params.(values{i}),values{i},evtVals);
            events.type(bSet) = labels(:);
            
            % Add fields to the structure with .evta labels
            field = params.(values{i});
            % Make sure the field doesn't share the name of a critical one
            if ~ismember(field,{'type','value','sample'}) && (numel(labels) > 1)
                % Initialize the field if it doesn't yet exist
                if ~isfield(events,field)
                    events.(field) = cell(size(events.type));
                end
                events.(field)(bSet) = labels(:);
            end
        end
    end

    % Copy the changes into FT_DATA
    FT_DATA.event = FT.ReStruct(events);
    [~,FT_DATA.data.cfg] = FT.EditCfg(FT_DATA.data.cfg,'set','event',FT_DATA.event);
catch me
end

FT_DATA.saved = false;
FT.tools.AddHistory('relabel_events',params);
FT_DATA.done.relabel_events = isempty(me);

end