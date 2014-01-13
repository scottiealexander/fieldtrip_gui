function [kL,cL] = GetAxLabels(v,n,varargin)

% GetvLabels
%
% Description: construct a cell of tick labels from a vector representing the
%              axes bin centers
%
% Syntax: cL = GetAxLabels(v,n)
%
% In:
%       v - a vector representing axes bin centers
%       n - the number of bins in 'v' to label (i.e the number of tick labels)
% Out:
%       kL - the tick locations
%       cL - a cell of strings representing the tick labels
%
% Updated: 2013-12-17
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt = FT.ParseOpts(varargin,...
	'space' , 'linear' ,...
	'round' , []        ...
	);

% step = RoundN((abs(v(1))+abs(v(end)))/n,-1);

switch lower(opt.space)
	case 'linear'
		% kL = v(1):step:v(end);
		kL = linspace(v(1),v(end),n);
	case 'log'
		kL = logspace(log10(v(1)),log10(v(end)),n);
	otherwise
		error('invalid spacing: %s',opt.space);
end

if ~isempty(opt.round) && isnumeric(opt.round)
	f = @(x) num2str(RoundN(x,opt.round));
else
	f = @num2str;
end
cL = arrayfun(f,kL,'uni',false);

%------------------------------------------------------------------------------%
function x = RoundN(x,n)
    n = 10^(-n);
    x = round(x*n)/n;
end
%------------------------------------------------------------------------------%
end