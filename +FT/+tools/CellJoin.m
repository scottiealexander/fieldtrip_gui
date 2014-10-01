function c = CellJoin(c,dim)

% CellJoin
%
% Description: 
%
% Syntax: c = CellJoin(c,dim)
%
% In: 
%       c   - a NxM cell
%       dim - the dimention over which the join the elements
%
% Out: 
%       c - the input c joined over the specified dim
%
% Example:
%   d = repmat({rand(20,300,10)},[3,1,1,5]);
%   CellJoin(d,1) => a 3x1 cell of 20x300x10x5 matricies
%
% Updated: 2014-01-22
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

siz = num2cell(size(c));

siz{dim} = ones(siz{dim},1);

c = mat2cell(c,siz{:});

c = cellfun(@(x) cat(numel(siz),x{:}),c,'uni',false);