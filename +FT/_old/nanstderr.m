function x = nanstderr(x,dim)

% nanstderr
%
% Description: 
%
% Syntax: err = nanstderr(x,dim)
%
% In: 
%       x   - an matrix of data
%       dim - the dimention along which to calculate stderr
%
% Out: 
%       err - the standard error
%
% Updated: 2013-12-11
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

n = sum(~isnan(x),dim);
x = nanstd(x,[],dim)./sqrt(n);