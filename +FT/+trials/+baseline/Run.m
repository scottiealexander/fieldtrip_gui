function me = Run(cfg)

% FT.trials.baseline.Run
%
% Description: perform baseline correctionon on segmented data
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
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA
me = [];

% time = FT_DATA.data{1}.time{1};
% BASELINE = cfg.baselinewindow;
% BASELINE = [find(time>=BASELINE(1),1,'first') find(time>=BASELINE(2),1,'first')];

try
	for k = 1:numel(FT_DATA.data)
		FT_DATA.data{k} = ft_preprocessing(cfg,FT_DATA.data{k});
%         if FT_DATA.done.tfd
%             FT_DATA.power.data{k} = BaselineCorr(FT_DATA.power.data{k});
%         end
	end
catch me
end

FT.tools.AddHistory('baseline_trials',cfg);

FT_DATA.saved = false;
FT_DATA.done.baseline_trials = isempty(me);

%-------------------------------------------------------------------------%
% function d = BaselineCorr(d)
% 	m = mean(mean(d(:,BASELINE(1):BASELINE(2),:,:),4),2);
% 
% 	%avoid dividing by 0
% 	m(m==0) = 1;
%     m = repmat(m,1,1,1,size(d,4));
% 	m = repmat(m,1,size(d,2));
% 	
% 	d = (d - m) ./ abs(m);
% end
%-------------------------------------------------------------------------%
end