classdef Element < handle

% FT.tools.Element
%
% Description: a wrapper class for uicontrol objects
%              ***[NOTE]***: a user should never interact directly with this
%              class, only with the containing FT.tools.Win instance
%
% Syntax: el = FT.tools.Element(win,pos,ifo,<options>)
%
% In:
%       win - the parent FT.tools.Win instance
%       pos - the approx. position for this element in pixels relative to the
%             containing figure
%       ifo - the element info struct (see FT.tools.Win)
%   options:
%       haligh - ('center') the horizontal alignment for this element relative
%                to it's containing rect
%       valigh - ('center') the vertical alignment for this element relative
%                to it's containing rect
%
% Out:
%       el - an instance of the Element class
%
% See also:
%       FT.tools.Win, FT.tools.Win.Test
%
% Updated: 2014-10-10
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
    dpi;
    pos = zeros(1,4);
    len = 0;
    opt;
    tag = '';
    valfun;
    listboxmax = 8;
    fontsize = .2;
    def_len = 5;
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
        self.dpi = get(0,'ScreenPixelsPerInch');
        self.fig = win.h;
        self.pos = p ./ self.dpi;
        self.type = lower(s.type);
        
        if isfield(s,'len')
            self.len = s.len(1);
            s = rmfield(s,'len');
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
        rect = rect./self.dpi;
        p = self.pos;
        p(1) = self.GetLeft(rect(1),rect(3));
        p(2) = self.GetBottom(rect(2),rect(4));
        self.SetPosition(p);
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
        w = self.pos(3)*self.dpi;
        h = self.pos(4)*self.dpi;
    end
    %-------------------------------------------------------------------------%
    function [w,h] = ReSize(self)
        if strcmpi(self.type,'text')
            self.InitTextPosition;
        else
            self.InitUIPosition;
        end
        [w,h] = self.GetSize;
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
        p = get(self.h,'Position');
        [p(3), p(4)] = self.Extent;
        self.SetPosition(p);
    end
    %-------------------------------------------------------------------------%
    function InitUIPosition(self)        
        p = get(self.h,'Position');        
        [p(3), p(4)] = self.Extent;
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
    function [wd,ht] = Extent(self)
        if isprop(self.h,'Extent')
            ext = get(self.h,'Extent');
        else
            ext = [0 0];    
        end
        switch lower(self.type)
        case 'listbox'
            if isempty(self.string)
                if self.len
                    emptylen = self.len;
                else
                    emptylen = self.def_len;
                end
                wd = emptylen*self.fontsize;
                ht = self.fontsize*1.75;
            else
                [wd,ht] = self.GetListExtent;
                wd = wd+self.fontsize; %add a char in width for the scroll bar
            end
        case 'checkbox'
            wd = .22;
            ht = .22;
        case {'edit','pushbutton'}
            if isempty(self.string)
                if self.len
                    nchar = self.len;
                else
                    nchar = self.def_len;    
                end
                wd = nchar*self.fontsize;
                ht = self.fontsize*1.75;
            else
                if self.len > 0
                    wd = self.len*self.fontsize;
                else
                    if numel(self.string) < 4
                        scale = 1.75;
                    else
                        scale = 1.1;
                    end
                    wd = ext(3)*scale;                    
                end
                ht = ext(4)*1.2;
            end
        otherwise            
            wd = ext(3);
            ht = ext(4);            
        end
    end
    %-------------------------------------------------------------------------%
    function [wd,ht] = GetListExtent(self)
        c = get(self.h,'String');
        if ~iscell(c)
            c = {c};
        end
        nc = numel(c);
        ht = nan(nc,1);
        wd = -inf;
        for k = 1:nc
            tmp = uicontrol(...
                'Style'     , 'text'        ,...
                'Units'     , 'inches'      ,...
                'FontName'  , 'Monospaced'  ,...
                'FontUnits' , 'inches'      ,...
                'FontSize'  , self.fontsize ,...
                'String'    , c{k}          ,...
                'Visible'   , 'off'         ,...
                'Parent'    , self.fig       ...
                );
            ext = get(tmp,'Extent');
            wd = max([ext(3) wd]);
            ht(k) = ext(4);
            if k > 1
                ht(k) = ht(k)*.8;
            end
            delete(tmp);
        end
        if nc > self.listboxmax
            ht = ht(1:self.listboxmax);
        end
        ht = nansum(ht);
    end
    %-------------------------------------------------------------------------%
    function def = AddDefaultValues(self,s)
        def = { 'Units'     , 'inches'      ,...
                'FontUnits' , 'inches'      ,...
                'FontName'  , 'Monospaced'  ,...
                'FontSize'  , self.fontsize ,...                
                'Position'  , self.pos      ,...
                'Parent'    , self.fig       ...
              };

        switch self.type
            case {'edit','checkbox','listbox'}
                def = [def {'BackgroundColor',[1 1 1]}];
                if iscell(self.string)
                    def = [def {'Min',0,'Max',1}];
                end
            case 'text'
                def = [def {'BackgroundColor',get(self.fig,'Color')}];
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

% function pos = Axes2Fig(self,pos)
% %function to convert data units (i.e extent) within an axes to figure units
%     pAx  = self.GetPosition(self.ax,'pixels');
%     yLim = get(self.ax,'YLim');
%     yExt = yLim(2)-yLim(1);
%     xLim = get(self.ax,'XLim');
%     xExt = xLim(2)-xLim(1);
        
%     pos(1) = pAx(1)+((pos(1)-xLim(1))/xExt)*pAx(3);
%     pos(2) = pAx(2)+((pos(2)-yLim(1))/yExt)*pAx(4);
%     pos(3) = (pos(3)/yExt) * pAx(3);
%     pos(4) = (pos(4)/yExt) * pAx(4);
% end
% %-------------------------------------------------------------------------%
% function out = Fig2Axes(self,pos)
% %functon to convert figure units to axes data units
%     pAx = self.GetPosition(self.ax,'pixels');
%     out(1) = (pos(1) - pAx(1)) / pAx(3);
%     out(2) = (pos(2) - pAx(2)) / pAx(4);
% end
% %-------------------------------------------------------------------------%