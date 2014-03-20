function s2 = ReStruct(s)

% FT.ReStruct
%
% Description: flip between structure formats:
%               - Nx1 array of 1x1 structs
%               - 1x1 struct of Nx1 arrays
%
% Syntax: s2 = FT.ReStruct(s)
%
% In: 
%		s - a struct (see descriptions)
%
% Out: 
%		s2 - the reformatted struct
%
% Updated: 2013-08-14
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

cFields = fieldnames(s);

if numel(s) > 1    

    s2 = cell2struct(repmat({[]},numel(cFields),1),cFields,1);
    for k = 1:numel(cFields)
        s2.(cFields{k}) = {s(:).(cFields{k})};
        s2.(cFields{k}) = UnCell(s2.(cFields{k}))';
    end
else
    bChar = cellfun(@(x) ischar(s.(x)),cFields);
    bEmpty = cellfun(@(x) isempty(s.(x)),cFields);
    if any(bChar | bEmpty)
        cFix = cFields(bChar | bEmpty);
        for k = 1:numel(cFix)
            s.(cFix{k}) = {s.(cFix{k})};
        end
    end
    n = cellfun(@(x) numel(s.(x)),cFields);    
    if ~all(n==n(1))
       error('struct field sizes are not consistent');
    else
        n = n(1);
    end
    
    s2 = repmat(struct,n,1);
    for k = 1:numel(cFields)
        if ~iscell(s.(cFields{k}))
            s.(cFields{k}) = num2cell(s.(cFields{k}));
        end
       [s2(1:n).(cFields{k})] = deal(s.(cFields{k}){:});
    end
end

%------------------------------------------------------------------------------%
function c = UnCell(c)
    if all(cellfun(@(x) ~isempty(x) && isnumeric(x) || islogical(x),c))
        c = [c{:}];        
    end
%------------------------------------------------------------------------------%

