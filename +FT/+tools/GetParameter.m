function val = GetParameter(domain,field)

% FT.tools.GetParameter
%
% Description: get parameters for baseline correcting segmented data
%
% Syntax: val = FT.tools.GetParameter(domain,field)
%
% In: 
%       domain - the domain to search (i.e. sub-field of FT_DATA)
%       field  - the field of interest
%
% Out:
%       val - the value of field if found, otherwise an empty matrix
%
% Updated: 2014-06-26
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

val = [];
if isfield(FT_DATA,domain)
	if iscell(FT_DATA.(domain))
		val = SearchCell(FT_DATA.(domain));
	elseif isstruct(FT_DATA.(domain))
		val = SearchStruct(FT_DATA.(domain));	
	end
end

%-----------------------------------------------------------------------------%
function val = SearchCell(c)
	val = [];
	k = 1;
	while isempty(val) && k <= numel(c)
		if iscell(c{k})
			val = SearchCell(c{k});
		elseif isstruct(c{k})
			val = SearchStruct(c{k});
		end
		k = k+1;
	end
end
%-----------------------------------------------------------------------------%
function val = SearchStruct(s)
    if isfield(s,field)
        val = s.(field);
    elseif numel(s) > 1
        val = SearchArray;
    else
        val = SearchScalar;
    end
    %-------------------------------------------------------------------------%
    function val = SearchScalar
        fields = fieldnames(s);
        val = [];
        k = 1;
        while isempty(val) && k <= numel(fields)
            if iscell(s.(fields{k}))
                val = SearchCell(s.(fields{k}));
            elseif isstruct(s.(fields{k}))
                val = SearchStruct(s.(fields{k}));
            end
            k = k+1;
        end
    end
    %-------------------------------------------------------------------------%
    function val = SearchArray
        k = 1;
        val = [];
        while isempty(val) && k <= numel(s)
            if iscell(s(k))
                val = SearchCell(s(k));
            elseif isstruct(s(k))
                val = SearchStruct(s(k));
            end
            k = k+1;
        end
    end
    %-------------------------------------------------------------------------%
end
%-----------------------------------------------------------------------------%
end