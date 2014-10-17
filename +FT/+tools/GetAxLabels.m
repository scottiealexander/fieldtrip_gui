function [tick,tick_label] = GetAxLabels(v,n,varargin)

% GetvLabels
%
% Description: construct a cell of tick labels from a vector representing the
% axes bin centers
%
% Syntax: cL = GetAxLabels(v,n,<options>)
%
% In:
% 		v - a vector representing axes bin centers
% 		n - the number of bins in 'v' to label (i.e the number of tick labels)
%	options:
%		round - ([]) the power of 10 to round to
% Out:
% 		tick       - the tick locations (indicies)
% 		tick_label - a cell of strings representing the tick labels
%
% Updated: 2014-06-26
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt = FT.ParseOpts(varargin,...
	'round' , [] ...
	);

if n > numel(v)
	n = numel(v);
end

if ~isempty(opt.round) && isnumeric(opt.round)
	f = @(x) num2str(RoundN(x,opt.round));
else
	f = @num2str;
end

tick = linspace(1,numel(v),n);
tick(tick > numel(v)) = [];
tick_label = arrayfun(f,v(ceil(tick)),'uni',false);

%------------------------------------------------------------------------------%
function x = RoundN(x,n)
	n = 10^(-n);
    x = round(x*n)/n;
end
%------------------------------------------------------------------------------%
end