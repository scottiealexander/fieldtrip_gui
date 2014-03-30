function [b,param] = HilbertDecomposition()

% FT.HilbertDecomposition
%
% Description: 
%
% Syntax: FT.HilbertDecomposition
%
% In: 
%
% Out: 
%
% Updated: 2014-03-29
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

%get parameters from user
[b,param] = GetHilbertParameters;

% if ~b
	return;
% end

%run hilbert decomposition
FT.HilbertPSD(param);

%generate surrogate dataset
if cfg.surrogate
	FT.SurrogatePSD;
end