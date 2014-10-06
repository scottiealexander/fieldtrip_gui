function b = IsEmptyField(field)

% FT.tools.IsEmptyField
%
% Description: returns true if the FT_DATA struct has a given field and that
%              field is not empty
%
% Syntax: b = FT.tools.IsEmptyField(field)
%
% In:
%       field - a fieldname as a string or cell of such
%
% Out:
%       b - a logical (or vector of such if 'field' is a cell) indicating
%           whether the given field exists and is empty
%
% Updated: 2014-10-03
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

if ~iscell(field)
    field = {field};
end
b = false(numel(field),1);
for k = 1:numel(field)
    b(k) = ~isfield(FT_DATA,field{k}) || isempty(FT_DATA.(field{k}));
end