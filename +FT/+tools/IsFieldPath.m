function b = IsFieldPath(field)

% FT.tools.IsFieldPath
%
% Description: check if a fieldpath is valid.
%              ***NOTE***: in order to save memory, this function uses eval
%              to avoid performing ANY copying operations on the FT_DATA
%              struct or substructs
%
% Syntax: val = FT.tools.IsFieldPath(field)
%
% In: 
%       field - the fieldpath to check as a cell of strings
%
% Out:
%       b - true if the field path is valid
%
% Updated: 2014-10-05
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

if ischar(field)
    b = isfield(FT_DATA,field);
elseif iscellstr(field)
    b = true;
    field_path =  '';
    for k = 1:numel(field)        
        cmd = ['isfield(FT_DATA' field_path ',''' field{k} ''')'];
        if ~eval(cmd)
            b = false;
            break;
        else
            field_path = [field_path '.(''' field{k} ''')'];
        end
    end        
else
    b = false;
end