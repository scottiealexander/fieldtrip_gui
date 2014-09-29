function me = Run(params)

% FT.trials.segment.Run
%
% Description: segment trials
%
% Syntax: me = FT.trials.segment.Run(params)
%
% In:   params - a struct holding parameters from the user
%
% Out:  me - an empty matrix if processing finished with out error,
%            otherwise a MException object caught from the error
%
% Updated: 2014-07-22
% Peter Horak
%
% See also: FT.trials.segment.Gui

global FT_DATA
me = [];

try
    %segment into trials
    nCondition = numel(FT_DATA.epoch);
    EPOCH = cell(nCondition,1);
    for k = 1:nCondition

        %segment
        cfg = FT.tools.CFGDefault;
        cfg.trl = FT_DATA.epoch{k}.trl;
        % *** TODO: errors if cfg.trl is empty (happens if all trials lie
        % outside the length of the data)
        if isempty(cfg.trl)
            error('Empty trial definition for conditoin %d',k);
        end
        EPOCH{k,1} = ft_redefinetrial(cfg,FT_DATA.data);
    end

    FT_DATA.data = EPOCH;
catch me
end

%mark data as not saved
FT_DATA.saved = false;

%update history
FT.tools.AddHistory('segment_trials',params);

FT_DATA.done.segment_trials = isempty(me);