function s = structfieldfun(f,s)

% structfieldfun
%
% Description: apply a function (f) to each field of structure s
%
% Syntax: s = structfieldfun(f,s)
%
% In:
%       f - the handle to a function that will take each field of s as and input
%       s - a struct
%
% Out:
%       s - the new struct after f has been applied to each field
%
% Updated: 2013-12-12
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

bRefmt = false;

if numel(s) > 1
    bRefmt = true;
    s = FT.ReStruct(s);
end

cF = fieldnames(s);
for k = 1:numel(cF)
    s.(cF{k}) = f(s.(cF{k}));
end

if bRefmt
    s = FT.ReStruct(s);
end