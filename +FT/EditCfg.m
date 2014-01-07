function [out,cfg] = EditCfg(cfg,strAct,strField,varargin)

% FT.EditCfg
%
% Description: edit the cfg structs and sub-struct of the fieldtrip data structure(s)
%
% Syntax: [out,cfg] = FT.EditCfg(cfg,strAct,strField,[values]=[])
%
% In: 
%       cfg      - a fieldtrip cfg structure
%       strAct   - the action, either 'set', or 'get'
%       strField - the field/sub-field of the cfg struct to act on
%       [values] - a value or cell of values (one per condition if the data has been segmented)
%
% Out: 
%       out - the contents of the sub-field, if strAct='set' it is the old
%             contents before the setting was executed
%       cfg - the modified fieldtrip cfg struct (only actually modified if
%             strAct='set')
%
% Updated: 2013-09-17
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

switch lower(strAct)    
    case 'get'           
        out = GetFieldVal(cfg,strField);
    case 'set'
        if ~isempty(varargin)                
            [cfg,out] = SetFieldVal(cfg,strField,varargin{1});            
        else
            out = [];
        end
    otherwise
        error(['undefined action ''' strAct ''', use ''set'' or ''get'' only']);
end

%------------------------------------------------------------------------------%
function [s,out] = SetFieldVal(s,field,val)
    if iscell(s)
        [s,out] = cellfun(@(x) SetFieldVal(x,field,val),s);
    elseif isstruct(s)
        if isfield(s,field)
            out = s.(field);
            s.(field) = val;
        elseif isfield(s,'previous')        
            [s.previous,out] = SetFieldVal(s.previous,field,val);
        else
            out = [];
            return;
        end
    else
        InvalidInput;
    end
end
%------------------------------------------------------------------------------%
function out = GetFieldVal(s,field)
   if iscell(s)
       out = cellfun(@(x) GetFieldVal(x,field),s,'uni',false);
   elseif isstruct(s)
       if isfield(s,field)
           out = s.(field);
       elseif isfield(s,'previous')
           if iscell(s.previous)
               out = cellfun(@(x) GetFieldVal(x,field),s.previous,'uni',false);
           elseif isstruct(s.previous) && numel(s.previous) > 1
               out = arrayfun(@(x) GetFieldVal(x,field),s.previous,'uni',false);
           elseif isstruct(s.previous)
               out = GetFieldVal(s.previous,field);
           else
               InvalidInput;
           end
       else
           out = [];
           return;
       end
   else
       InvalidInput;
   end
end
%------------------------------------------------------------------------------%
function InvalidInput
    me = MException('SetFieldVal:InvalidInput','invalid input to SetFieldVal, first input MUST be a struct or cell of structs');
    FT.ProcessError(me);
end
%------------------------------------------------------------------------------%
end