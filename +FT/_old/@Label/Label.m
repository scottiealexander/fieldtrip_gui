classdef Label < handle

% Label
%
% Description: 
%
% Syntax: Label
%
% In: 
%
% Out: 
%
% Updated: 2013-10-18
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com
%PRIVATE PROPERTIES------------------------------------------------------------%
properties (SetAccess=private)
    h;
    attr = struct('FontSize',[],'FontWeight',[],'Color',[],'FontName',[],...
            'FontAngle',[],'Position',[],'Interpreter',[],'String',[]);
    attr_names;
end
%PRIVATE PROPERTIES------------------------------------------------------------%

%PUBLIC PROPERTIES-------------------------------------------------------------%
methods
    %--------------------------------------------------------------------------%
    function lb = Label(hObj)
        lb.h = hObj;
        lb.attr_names = fieldnames(lb.attr);
        for k = 1:numel(lb.attr_names)
           lb.attr.(lb.attr_names{k}) = get(hObj,lb.attr_names{k});
        end
    end
    %--------------------------------------------------------------------------%
    function Set(lb,field,val)
        try
            lb.attr.(field) = val;
            lb.Update;
        catch me
           fprintf('[WARNING]: %s\n',me.message);
           lb.attr = rmfield(lb.attr,field);
        end
    end
    %--------------------------------------------------------------------------%
    function Update(lb)
       set(lb.h,lb.attr); 
    end    
    %--------------------------------------------------------------------------%
    function val = Get(lb,field)
        try
            val = get(lb.h,field);
        catch me
            fprintf('[WARNING]: %s\n',me.message);
        end
    end
    %--------------------------------------------------------------------------%
    function Magnify(lb,varargin)
        if isempty(varargin) || isempty(varargin{1}) || ~isnumeric(varargin{1})
            amt = 1;
        else
            amt = varargin{1};
        end
        
        lb.attr.FontSize = lb.attr.FontSize+amt;
        lb.Update;
    end
    %--------------------------------------------------------------------------%
end
%PUBLIC PROPERTIES-------------------------------------------------------------%
end