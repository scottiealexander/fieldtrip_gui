function Test

% Test
%
% Description: 
%
% Syntax: Test
%
% In: 
%
% Out: 
%
% Updated: 2014-04-15
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com
global FT_DATA;

siz = getfield(whos('FT_DATA'),'bytes');
s = MemUsage;

fprintf('sizeof(FT_DATA) = %.3f\n',siz/2^20);
fprintf('Using: %.3f MB\n',s.used);