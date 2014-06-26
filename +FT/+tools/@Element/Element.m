classdef Element < handle

% Element
%
% Description:
%
% Syntax:
%
% In:
%
% Out:
%
% Updated: 2014-06-23
% Scottie Alexander
%
% Please send bug reports to: scottiealexander11@gmail.com

%PROPERTIES-------------------------------------------------------------------%
properties
    type;
    h;
    fig;
    ax; 
    string = '';
    len = [1 5];
    pos = zeros(1,4);   
    opt;
    tag = '';
    valfun;
end
%PROPERTIES-------------------------------------------------------------------%

%METHODS----------------------------------------------------------------------%
methods
    %-------------------------------------------------------------------------%
    function self = Element(win,p,s,varargin)
    % win - the parent GUI object
    % p   - the position of this element's rect in pixels (relative to the figure)
    % s   - the element info struct
        self.opt = self.ParseOptions(varargin,...
            'halign', 'center' ,...
            'valign', 'center'  ...
            );

        self.fig = win.h;
        self.pos = p;
        self.type = lower(s.type);
        
        if isfield(s,'size')
            if numel(s.size) == 1
                s.size = [1 s.size];
            end
            self.len = s.size;
            s = rmfield(s,'size');
        end

        if isfield(s,'string')
            if ischar(s.string) && strcmpi(s.string,'default')                
                s.string = ['\' s.string];
            end
            self.string = s.string;
        end     

        if isfield(s,'tag')
            self.tag = s.tag;
        end

        if isfield(s,'valfun')
            self.valfun = s.valfun;
            s = rmfield(s,'valfun');
        else
            self.valfun = @self.DefaultValFun;
        end

        if isfield(s,'validate') && (islogical(s.validate) || isnumeric(s.validate))
            validate = s.validate;
            s = rmfield(s,'validate');
        else
            validate = true;
        end
        c = self.AddDefaultValues(rmfield(s,'type'));

        self.h = uicontrol('Style',self.type,c{:});

        switch self.type
        case 'text'
            self.InitTextPosition;
        case {'pushbutton','edit','checkbox','listbox'}            
            self.InitUIPosition;
            if strcmpi(self.type,'pushbutton') && isempty(get(self.h,'Callback'))
                set(self.h,'Callback',@(x,varargin) win.BtnPush(x,validate));
            end
        otherwise
            error('not yet supported');
        end
    end
    %-------------------------------------------------------------------------%
    function SetOuterRect(self,rect,varargin)
        self.opt = self.ParseOptions(varargin,...
            'halign' , self.opt.halign,...
            'valign' , self.opt.valign ...
            );
        pos = self.pos;
        pos(1) = self.GetLeft(rect(1),rect(3));
        pos(2) = self.GetBottom(rect(2),rect(4));
        self.SetPosition(pos);
    end
    %-------------------------------------------------------------------------%
    function SetProp(self,field,val)
        if isprop(self.h,field)
            set(self.h,field,val);
        elseif isprop(self,field)
            self.(field) = val;
        end
    end
    %-------------------------------------------------------------------------%
    function val = GetProp(self,field)
        if isprop(self.h,field)
            val = get(self.h,field);
        elseif isprop(self,field)
            val = self.(field);
        else
            val = [];
        end
    end
    %-------------------------------------------------------------------------%
    function [w,h] = GetSize(self,varargin)
        w = self.pos(3);
        h = self.pos(4);
    end
    %-------------------------------------------------------------------------%
    function out = Response(self)
        switch self.type
        case 'edit'
            out = get(self.h,'String');
        case {'checkbox','listbox'}
            out = get(self.h,'Value');        
        otherwise
            out = [];
        end
    end
    %-------------------------------------------------------------------------%
    function [b,msg] = Validate(self)
        err = false;
        switch class(self.valfun)
        case 'function_handle'
            [b,msg] = self.valfun(self.Response);
        case 'cell'         
            if ischar(self.valfun{1}) && ismethod(self,self.valfun{1})
                %this calls the method contained in the string self.valfun{1},
                %passing it the users response followed by all other elements
                %of self.valfun (i.e. self.valfun{2:end})
                [b,msg] = self.(self.valfun{1})(self.Response,self.valfun{2:end});
            else
                err = true;
            end
        otherwise
            err = true;         
        end
        if err
            error('valfun must be a function handle or cell of strings');       
        end
    end
    %-------------------------------------------------------------------------% 
end
%METHODS----------------------------------------------------------------------%

%PRIVATE METHODS--------------------------------------------------------------%
methods (Access=private)
    %-------------------------------------------------------------------------%
    function [b,msg] = DefaultValFun(self,msg)
        b = true;       
    end
    %-------------------------------------------------------------------------%
    function SetPosition(self,pos)
        set(self.h,'Position',pos);
        self.pos = pos;
    end
    %-------------------------------------------------------------------------%
    function InitTextPosition(self)
        ext = get(self.h,'Extent');
        p = get(self.h,'Position');
        p(3:4) = ext(3:4);
        self.SetPosition(p);
    end
    %-------------------------------------------------------------------------%
    function InitUIPosition(self)
        set(self.h,'Units','characters');
        p = get(self.h,'Position');
        p(3) = self.GetWidth;
        p(4) = self.GetHeight;
        set(self.h,'Position',p);
        set(self.h,'Units','pixels');
        p = get(self.h,'Position');
        p(1) = self.GetLeft(p(1),p(3));
        p(2) = self.GetBottom(p(2),p(4));
        self.SetPosition(p);
    end
    %-------------------------------------------------------------------------%
    function l = GetLeft(self,l,w)
        r = l+w;        
        switch lower(self.opt.halign)
        case 'left'
            % do nothing
        case 'center'
            l = (l + w/2) - (self.pos(3)/2);
        case 'right'
            l = r - self.pos(3);
        otherwise
            error('Invalid alignment specified');
        end
    end
    %-------------------------------------------------------------------------%
    function b = GetBottom(self,b,h)
        t = b+h;        
        switch lower(self.opt.valign)
        case 'top'
            b = t - self.pos(4);
        case 'center'
            b = (b + h/2) - (self.pos(4)/2);
        case 'bottom'
            %do nothing
        otherwise
            error('Invalid alignment specified');
        end
    end
    %-------------------------------------------------------------------------%
    function w = GetWidth(self)
        switch self.type
        case 'edit'
            fsiz = get(self.h,'FontSize');
            if isempty(self.string)                
                w = (5 * (fsiz/8)) + 2.5;                
            else                
                ext = get(self.h,'Extent');
                w = ext(3) + (fsiz/3);           
            end
        case 'pushbutton'
            w = get(self.h,'Extent');
            w = w(3)+2;
        case 'listbox'
            w = get(self.h,'Extent');
            w = w(3)+3;
        case 'checkbox'
            w = 3.5;
        otherwise
            error('Das ist foul...');
        end
    end
    %-------------------------------------------------------------------------%
    function h = GetHeight(self)
        switch self.type
        case 'checkbox'            
            h = 1.5;
        case 'listbox'
            h = get(self.h,'Extent');
            h = numel(self.string)*h(4);
        case 'edit'
            fsiz = get(self.h,'FontSize');
            h = (self.len(1) * (fsiz/16)) + 2;            
        otherwise
            h = get(self.h,'Position');
            h = h(4);
        end
    end
    %-------------------------------------------------------------------------%
    function pos = Axes2Fig(self,pos)
    %function to convert data units (i.e extent) within an axes to figure units
        pAx  = self.GetPosition(self.ax,'pixels');
        yLim = get(self.ax,'YLim');
        yExt = yLim(2)-yLim(1);
        xLim = get(self.ax,'XLim');
        xExt = xLim(2)-xLim(1);
            
        pos(1) = pAx(1)+((pos(1)-xLim(1))/xExt)*pAx(3);
        pos(2) = pAx(2)+((pos(2)-yLim(1))/yExt)*pAx(4);
        pos(3) = (pos(3)/yExt) * pAx(3);
        pos(4) = (pos(4)/yExt) * pAx(4);
    end
    %-------------------------------------------------------------------------%
    function out = Fig2Axes(self,pos)
    %functon to convert figure units to axes data units
        pAx = self.GetPosition(self.ax,'pixels');
        out(1) = (pos(1) - pAx(1)) / pAx(3);
        out(2) = (pos(2) - pAx(2)) / pAx(4);
    end
    %-------------------------------------------------------------------------%
    function def = AddDefaultValues(self,s)
        def = { 'FontName' , 'Monospaced' ,... %it appears that this needs to be 'Courier'
                'FontSize' , 14           ,... %in order to achieve the desired layout on Linux 
                'Units'    , 'pixels'     ,...
                'Position' , self.pos     ,...
                'Parent'   , self.fig      ...
              };
        switch self.type
            case {'edit','checkbox'}
                def = [def {'BackgroundColor',[1 1 1]}];
                if iscell(self.string)
                    def = [def {'Min',0,'Max',2}];
                    self.len = [numel(self.string) max(cellfun(@numel,self.string))];
                elseif ~isempty(self.string)
                    self.len = [1 numel(self.string)];                
                end
            case 'text'
                def = [def {'BackgroundColor',get(self.fig,'Color')}]; %get(self.fig,'Color')
        end
        def = self.pvpair2struct(def);
        fields = fieldnames(s);
        for k = 1:numel(fields)
            def.(fields{k}) = s.(fields{k});
        end
        def = reshape([fieldnames(def)';struct2cell(def)'],1,[]);
    end
    %-------------------------------------------------------------------------%
    function sDef = ParseOptions(self,cOpt,varargin)
        if mod(numel(cOpt),2) || mod(numel(varargin),2)
            error('Invalid input format!');
        end

        sOpt = self.pvpair2struct(cOpt);
        sDef = self.pvpair2struct(varargin);
        cFields = fieldnames(sDef);
        for k = 1:numel(cFields)
            if isfield(sOpt,cFields{k})
                sDef.(cFields{k}) = sOpt.(cFields{k});
            end
        end
    end
    %-------------------------------------------------------------------------%
end
%PRIVATE METHODS--------------------------------------------------------------%


%PRIVATE STATIC METHODS-------------------------------------------------------%
methods (Static=true,Access=private)
    %-------------------------------------------------------------------------%
    function pos = GetPosition(hl,units)
        orig = get(hl,'Units');
        set(hl,'Units',units);
        pos = get(hl,'Position');
        set(hl,'Units',orig);
    end
    %-------------------------------------------------------------------------%
    function s = pvpair2struct(c)
    %convert a 1xN or Nx1 cell of parameter value pairs to a struct        
        s = cell2struct(c(2:2:end),c(1:2:end-1),2);
    end
    %-------------------------------------------------------------------------% 
end
%PRIVATE STATIC METHODS-------------------------------------------------------%

%STATIC METHODS---------------------------------------------------------------%
methods (Static=true)
    %-------------------------------------------------------------------------%
    function [b,val] = inrange(str,lo,hi,force)
        if ~force && isempty(str)
            b = true;
            val = [];            
        else
            n = str2double(str);
            b = ~isnan(n) && (n >= lo && n <= hi);
            if b
                val = n;
            else
                val = sprintf('Value must be a number in range [%d,%d]!',lo,hi);
            end
        end
    end
    %-------------------------------------------------------------------------%
    function [b,val] = isnumber(str,force)
        if ~force && isempty(str)
            b = true;
            val = [];            
        else
            n = str2double(str);
            if isnan(n)
                val = 'Value must be a number!';
                b = false;
            else
                val = n;
                b = true;
            end
        end
    end
    %-------------------------------------------------------------------------%
    function [b,val] = match(str,ptn,force,varargin)
        if ~force && isempty(str)
            b = true;
            val = '';            
        else
            b = ~isempty(regexp(str,ptn,'match','once'));
            if b
                val = str;
            else
                if ~isempty(varargin) && ischar(varargin{1})
                    val = ['Input must be ' varargin{1} '!'];
                else
                    val = 'Invalid input!';
                end            
            end
        end        
    end
    %-------------------------------------------------------------------------%
end
%STATIC METHODS---------------------------------------------------------------%
end