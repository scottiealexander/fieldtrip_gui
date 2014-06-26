function me = Run(cfg)

% FT.baseline.Run
%
% Description: perform baseline correctionon on segmented data
%
% Syntax: me = FT.baseline.Run(cfg)
%
% In: 
%		cfg - a struct of baseline correction parameters
%
% Out:
%		me - an mexception if one was thrown, otherwise an empty matrix
%
% Updated: 2014-06-26
% Scottie Alexander
%
% See also: FT.baseline.Gui
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA
fprintf('Running!\n');
me = [];
try
	for k = 1:numel(FT_DATA.data)
		FT_DATA.data{k} = ft_preprocessing(cfg,FT_DATA.data);
	end
catch me
end

FT.tools.AddHistory('baseline_correction',cfg);

FT_DATA.saved = false;
FT_DATA.done.filter = FT.tools.Ternary(isempty(me),true,false);