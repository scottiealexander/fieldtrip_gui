function me = Run(params)

% FT.trials.define.Run
%
% Description: define trials
%
% Syntax: me = FT.trials.define.Run(params)
%
% In:   params - struct array with fields:
%           type (event type to which it applies)
%           pre  (trial start relative to event)
%           post (trial end relative to event)
%           name (tag for resulting segments)
%
% Out:  me - an mexception if one was thrown, an empty matrix if successful
%
% Updated: 2014-08-19
% Peter Horak
%
% See also: FT.trials.define.Gui

global FT_DATA;
me = [];

try
    epoch = cell(size(params));
    for i = 1:numel(params)
        % Make trial definitions for the ith condition
        trl = FT.trials.define.MakeTRL(params(i));
        
%         % Put params in a struct to be compatible with current epoch.ifo format
%         sOpt.event = params(i).type;
%         sOpt.pre   = params(i).pre;
%         sOpt.post  = params(i).post;
%         sOpt.field = 'type';
%         sOpt.format = 'timelock';

        % Add the trials to the epoch cell array
        epoch{i}.name = params(i).name;
        epoch{i}.trl = trl;
        epoch{i}.ifo = params(i);
    end

    FT_DATA.epoch = epoch;
catch me
end

%mark data as not saved
FT_DATA.saved = false;

%update the history
FT.tools.AddHistory('define_trials',params);
FT_DATA.done.define_trials = isempty(me);

end
