function me = Run(cfg)

% FT.trials.baseline.Run
%
% Description: perform baseline correctionon on segmented time-series data
%
% Syntax: me = FT.trials.baseline.Run(cfg)
%
% In: 
%		cfg - a struct of baseline correction parameters
%
% Out:
%		me - an mexception if one was thrown, an empty matrix if successful
%
% Updated: 2014-06-26
% Scottie Alexander
%
% See also: FT.trials.baseline.Gui

global FT_DATA
me = [];

try
    % baseline correct each condition individually
	for k = 1:numel(FT_DATA.data)
		FT_DATA.data{k} = ft_preprocessing(cfg,FT_DATA.data{k});
	end
catch me
end

% update history
FT.tools.AddHistory('baseline_trials',cfg);
FT_DATA.saved = false;
FT_DATA.done.baseline_trials = isempty(me);

end