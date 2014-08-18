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

FT_DATA.epoch = params.epoch;

try
    %segment into trials
    nCondition = numel(FT_DATA.epoch);
    EPOCH = cell(nCondition,1);
    for k = 1:nCondition

        %segment
        cfg = FT.tools.CFGDefault;
        cfg.trl = FT_DATA.epoch{k}.trl;
        EPOCH{k,1} = ft_redefinetrial(cfg,FT_DATA.data);
    end

    FT_DATA.data = EPOCH;
catch me
end

%update history
FT_DATA.gui.display_mode = 'segment';
FT.tools.AddHistory('segment_trials',params);

FT_DATA.saved = false;
FT_DATA.done.segment_trials = isempty(me);