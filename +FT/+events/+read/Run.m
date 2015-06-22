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
        % save information about pulse-decoding parameters
        FT_DATA.pulse_evts = rmfield(params,'type');
        
        % the stimulus channel
        bStimChan = strcmpi(params.channel,FT_DATA.data.label);
        
        if params.fromfile
            % align events from a file with the stimulus channel
            FT_DATA.event = File2Event(FT_DATA.data.trial{1}(bStimChan,:),...
                FT_DATA.data.fsample,FT_DATA.pulse_evts);
        else
            % detect and translate events from the stimulus channel
            FT_DATA.event = Pulse2Event(FT_DATA.data.trial{1}(bStimChan,:),...
                FT_DATA.data.fsample,FT_DATA.pulse_evts);
        end
        if isempty(FT_DATA.event)
            return;
        end
    elseif strcmpi(params.type,'penn')
        % load events formatted for eeg_toolbox_v1.3.2
%         strDirEvt = fileparts(FT_DATA.path.base_directory);
%         % find and check the filepath
%         strPathEvt = fullfile(strDirEvt,'events.mat');
        strPathEvt = params.evtsfile;
        if ~exist(strPathEvt,'file')
            error('[Error]: no events.mat file found.')
        end
        % load the events struct
        f = load(strPathEvt,'events');
        if ~isfield(f,'events') || ~isa(f.events,'struct')
            error('[Error]: invalid events.mat file.')
        end
        events = f.events;
        % make events struct have the required fields for later operations
        evt = FT.ReStruct(events);
%         evt.type = cellfun(@(x,y) [x '_' y],evt.period,evt.type,'uni',false);
        evt.value = evt.type;
        evt.sample = evt.eegoffset;
        evt.duration = ones(size(evt.sample));
        evt.offset = cell(size(evt.sample));
        
        % Remove any array fields that resulted in an inconsistent number
        % of values when concatenated into an array
        nEvt = numel(evt.type);
        fields = fieldnames(evt);
        for i = 1:numel(fields)
           if numel(evt.(fields{i})) ~= nEvt
               evt = rmfield(evt,fields{i});
           end
        end
        FT_DATA.event = FT.ReStruct(evt);
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
                error('[Error]: Poorly formated event code values. Please contact the developer with the circumstances of this error'); 
            end
        end
        FT_DATA.event = FT.ReStruct(evt);

        %neuralynx events
        if strcmpi(params.type,'ncs') && params.collapse_nlx
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
    
    % If there are no events
    if (numel(FT_DATA.event) == 1) && isempty(FT_DATA.event.sample)
        FT_DATA.event = struct('type','Dummy Event','value',0,'sample',1,'duration',0,'offset',[]);
    end

catch me
end

%mark data as not saved
FT_DATA.saved = false;

%update the history
FT.tools.AddHistory('read_events',params);
FT_DATA.done.read_events = isempty(me);

end
