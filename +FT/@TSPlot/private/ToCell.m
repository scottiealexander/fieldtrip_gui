function x = ToCell(x)

% ToCell
%
% Description: 
%
% Syntax: ToCell
%
% In: 
%
% Out: 
%
% Updated: 2013-10-15
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

if ~iscell(x)
	x = {x};
end
