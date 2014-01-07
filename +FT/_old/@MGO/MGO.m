classdef MGO < handle

% MGO
%
% Description: 
%
% Syntax: MGO
%
% In: 
%
% Out: 
%
% Updated: 2013-10-15
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

%PRIVATE PROPERTIES------------------------------------------------------------%
properties (SetAccess=private)
    h;
    type;
end
%PRIVATE PROPERTIES------------------------------------------------------------%

%PUBLIC METHODS----------------------------------------------------------------%
methods
    %--------------------------------------------------------------------------%
    function mgo = MGO(h)
    	mgo.h = h;        
        mgo.type = get(h,'Type');
    end
    %--------------------------------------------------------------------------%
    function Set(mgo,varargin)
		if mod(numel(varargin),2)
			error('unballanced parameter value pairs');
		end
		for k = 1:2:numel(varargin)
			try
%                 if iscell(varargin{k})
%                     ts.SetNested(varargin{k});
%                 else
                    set(mgo.h,varargin{k},varargin{k+1});
%                 end
			catch me
				fprintf('[WARNING]: %s\n',me.message);
			end
		end
    end
    %--------------------------------------------------------------------------%
    function val = Get(mgo,varargin)
        try
            if isempty(varargin)
               val = get(mgo.h); 
            else
                val = get(mgo.h,varargin{1});
            end
        catch me
            val = [];
            fprintf('[WARNING]: %s\n',me.message);
        end		
    end
    %--------------------------------------------------------------------------%
    function Close(mgo)
        if ishandle(mgo.h)
            close(mgo.h);
        end
    end
    %--------------------------------------------------------------------------%    
    function display(mgo)
        fprintf('<MGO> object\n');
    end
    %--------------------------------------------------------------------------%
end
%PUBLIC METHODS----------------------------------------------------------------%

%PRIVATE METHODS---------------------------------------------------------------%
% methods (Access=private)
%     function SetNested(mgo,c)
%         hTmp = mgo.h;
%         for k = 1:numel(c)
%            tmp = get(hTmp,c{k});
%            if ishandel(tmp)
%                hTmp = tmp;
%            else
%                set(hTmp,c{k+1}); 
%            end
%         end
%     end
% end
%PRIVATE METHODS---------------------------------------------------------------%

end
