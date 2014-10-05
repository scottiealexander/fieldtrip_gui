function val = GetParameter(field,varargin)

% FT.tools.GetParameter
%
% Description: search the FT_DATA struct for a parameter
%
% Syntax: val = FT.tools.GetParameter(field,<options>)
%
% In: 
%       field - the field of interest
%   options:
%       sub   - a sub-field of FT_DATA to search within
%
% Out:
%       val - the value of field if found, otherwise an empty matrix
%
% Updated: 2014-06-26
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

opt = FT.ParseOpts(varargin,...
    'sub', '' ...
    );

% val = [];
% if ~isempty(opt.sub)
%     if ischar(opt.sub) && isfield(FT_DATA,opt.sub)
%         domain = FT_DATA.(opt.sub);        
%     else
            
%     end
% else
% end

% if iscell(FT_DATA.(opt.sub))
%         val = SearchCell(FT_DATA.(opt.sub));
%     elseif isstruct(FT_DATA.(opt.sub))
%         val = SearchStruct(FT_DATA.(opt.sub));   
%     end
% end

val = risky_isfield(field);

%-----------------------------------------------------------------------------%
function b = risky_isfield(c)    
    if ischar(c)
        b = isfield(FT_DATA,c);
    elseif iscellstr(c)
        b = true;
        field_path =  '';
        for k = 1:numel(c)
            cmd = ['isfield(FT_DATA' field_path ',''' c{k} ''')'];
            if ~eval(cmd)
                b = false;
                break;
            else
                field_path = [field_path '.(''' c{k} ''')'];
            end
        end        
    else
        b = false;
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
    function x = FindField(x,f)
        if isfield(x,f)
            x = x.(f);
        end
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