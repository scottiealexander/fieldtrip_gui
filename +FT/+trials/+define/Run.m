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
    j = 0;
    for i = 1:numel(params)
        % Make trial definitions for the ith condition
        [trl,evtifo] = FT.trials.define.MakeTRL(params(i));
        
        % If there are any valid trials
        if ~isempty(trl)
            j = j + 1;
            % Add the trials to the epoch cell array
            epoch{j}.name = params(i).name;
            epoch{j}.trl = trl;
            epoch{j}.ifo = params(i);
            epoch{j}.evtifo = evtifo;
        end
    end

    if (j == 0)
        error('No valid trials defined');
    end
    
    FT_DATA.epoch = epoch(1:j);
catch me
end

% update display fields
FT_DATA.gui.display_mode = 'analysis';
%mark data as not saved
FT_DATA.saved = false;

%update the history
FT.tools.AddHistory('define_trials',params);
FT_DATA.done.define_trials = isempty(me);

end
