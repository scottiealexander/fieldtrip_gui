function s = ParseEquation(str)

% FT.ParseEquation
%
% Description: parse a new channel equation submited from the user
%
% Syntax: s = FT.ParseEquation(str)
%
% In: 
%       str - the equation as the user entered it
%
% Out: 
%       s - a struct with fields:
%               'label' - the label that the user specified for the new channel
%               'expr'  - the expression that will generate the channel
%               'raw'   - the expression that the user entered (un-altered)
%
% Updated: 2013-08-09
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

re = regexp(str,'(?<label>[^\s\=]*)\s?\=\s?(?<expr>[^\=]*)\s*$','names');

%capture label and raw expression for output
s.label = re.label;
s.raw   = re.expr;

%check for special operations (just mean for now)
str = strrep(re.expr,'avg','mean');
if ~isempty(strfind(str,'mean'))

    %fix parenthese issues to the Matlab syntax compatible
    str = FixParentheses(str);

    %make sure concatenation within mean() calls is vertical
    [kStart,kEnd,c] = regexp(str,'\[[^\]]*\]','start','end','match');
    c = cellfun(@(x) strrep(x,',',';'),c,'uni',false);

    %put the string back together with the new formatting
    s.expr = '';
    kLast = 1;
    for k = 1:numel(c)
        s.expr = [s.expr str(kLast:kStart(k)-1) c{k} str(kEnd(k)+1:end)];
        kLast = kEnd(k)+1;
    end
else
    s.expr = str;
end

%------------------------------------------------------------------------------%
function tmp = FixParentheses(str)
%fix parentheses problem within mean() calls
    %insert opening bracket for concatenation
    tmp = strrep(str,'mean(','mean([');
    
    %find the indicies of the beging of a call to mean()
    kB = regexp(tmp,'\(\[','start');
    
    %loop over calls to mean()
    for kI = 1:numel(kB)
        %keep track of the number of 'currently open parentheses' that we come 
        %across as we step through the string
        nOP = 0;
        
        %starting at the begining of the call to mean, step through each char
        %and find the parenthesis that closes the call to mean()
        for kK = kB(kI)+1:numel(tmp) 
           %check for opening or closing parentheses
           if tmp(kK) == ')' && nOP == 0
               %found parenthesis that closes the call to mean(), so instert the
               %closing bracket to close the concatenation, and add dim argument
               %to min (1 = vertical concatenation)
               tmp = [tmp(1:kK-1) '],1' tmp(kK:end)];
               break;
           elseif tmp(kK) == ')' && nOP > 0
               %found closing parenthesis, decrement counter
               nOP = nOP-1;
           elseif tmp(kK) == '('
               %found open parenthesis, increment counter
               nOP = nOP+1;
           end
        end
        
        %recalculate starting indicies of mean() calls as we have added some
        %chars in the loop above
        kB = regexp(tmp,'\(\[','start');
    end
end
%------------------------------------------------------------------------------%
end