function x = randomize(x)

% randomize
%
% Description: randomize the elements of input
%
% Syntax: x = randomize(x)
%
% In: 
%		x - any container that can be indexed into

% Out: 
%		x - the input container in a random order
%
% Updated: 2014-06-20
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com
persistent SHUFFLE

if isempty(SHUFFLE)
    rng('shuffle');
    SHUFFLE = true;
end
siz = size(x);
x = reshape(randperm(numel(x)),siz);