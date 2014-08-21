function rhs = Parse(str)

% FT.events.relabel.Parse
%
% Description: parse a new event label definition into a matlab usable right-hand-side
%
% Syntax: rhs = FT.events.relabel.Parse(str)
%
% In: 
%       str - the right-hand-side of a new event label definition
%
% Out: 
%
% SEE ALSO: FT.events.relabel.Gui, FT.events.relabel.Run
%
% Updated: 2014-07-15
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

sep = ' \t,;:';
c = regexp(regexprep(str,['[^\w' sep ']*|["'']*'],''),['[' sep ']*'],'split');
n = str2double(c);
if ~any(isnan(n))
    rhs = n;
else
    rhs = c;
end