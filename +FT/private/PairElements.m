function y = PairElements(x)

% PairElements
%
% Description: pair the elements of an input array such that each element is
%              paired with every other element once
%
% Syntax: y = PairElements(x)
%
% In:
%       x - a Nx1 or 1xN array
%
% Out: 
%       y - a Nx2 array of pairs
%
% Updated: 2013-10-25
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

n = numel(x);
y = cell(n-1,2);
for k = 1:n-1
    y{k,1} = repmat(x(k),n-k,1);
    y{k,2} = reshape(x(k+1:end),[],1);
end

y = [cat(1,y{:,1}) cat(1,y{:,2})];