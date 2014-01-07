function KeyPress(obj,evt)

% KeyPress
%
% Description: 
%
% Syntax: KeyPress
%
% In: 
%
% Out: 
%
% Updated: 2013-10-15
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

switch lower(evt.Key)
   case 'w'
       if ismember(evt.Modifier,'control')
           close(obj);
       end
   otherwise
end