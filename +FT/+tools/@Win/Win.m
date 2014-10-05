classdef Win < handle

% FT.tools.Win
%
% Description: a class that wraps basic GUI building
%
% Syntax: win = FT.tools.Win(c,<options>)
%
% Methods:
%       Wait, SetFocus, GetElementProp, SetElementProp
%
% In:
%       c - a Win layout specification made up of a cell of cells
%           ***see example below***
%   options:
%       title    - ('Win') a title for the figure window
%       grid     - (false) use strict grid spacing for elements
%       focus    - ('') the 'tag' of the element to give focus to
%       position - ([0,0]) the position of the figure window (in PIXELS)
%                   relative to the center of the screen (center=[0,0])
%
% Out:
%       win - an instance of the FT.tools.Win class
%
% Example:
%       %this is a very simple example
%       %see FT.tools.Win.Test for a more complete one
%
%       c = {{'text','string','A "row" with text & edit elements:'},...
%            {'edit','string','','tag','input'};... % <= see below for how a 'tag' is used to extract content
%            {'text','string','A "row" with text & checkbox elements:'},...
%            {'checkbox','tag','chkbox'};,...
%            {'text','string','This row only has text...'},...
%            {};... % <= this empty cell is needed so the outer cell 'c' conforms to matlab spec
%            {'text','string','A listbox:'},...
%            {'listbox','string',{'item 1','item 2'},'tag','lstbox'};...
%            {'pushbutton','string','Button 1'},...
%            {'pushbutton','string','Button 2'}...
%           };
%       win = FT.tools.Win(c,'title','Title','focus','input','grid',false);
%       win.Wait;              %wait for the user to finish interacting
%       btn = win.res.btn;     %the string of the button the user selected
%       chk = win.res.chkbox;  %the state of the checkbox
%       item = win.res.lstbox; %the index of the item the user selected
%
% See also:
%       FT.tools.Win.Test
%
% Updated: 2014-10-03
% Scottie Alexander
%
% Please send bug reports to: scottiealexander11@gmail.com


%PROPERTIES-------------------------------------------------------------------%
properties
    h;
    nrow;
    ncol;
    pad = .1;
    id;
    opt;
    content;
    el = {};
    ui;
    tx = [];
    res = struct('btn','');
    validate = false;
end
%PROPERTIES-------------------------------------------------------------------%

%METHODS----------------------------------------------------------------------%
methods
    %-------------------------------------------------------------------------%
    function self = Win(c,varargin)
        self.opt = self.ParseOptions(varargin,...
            'title'    , 'Win'  ,...
            'grid'     , false  ,...
            'focus'    , ''     ,...
            'position' , [0,0]   ...
            );

        if ~iscell(c) || ~all(reshape(cellfun(@iscell,c),[],1))
            error('Input should be a cell of cells!');
        end
        self.nrow = size(c,1);
        self.ncol = zeros(self.nrow,1);
        for k = 1:self.nrow
            self.ncol(k,1) = sum(~cellfun(@isempty,c(k,:)));
        end

        self.content = cell(self.nrow,max(self.ncol));
        for k = 1:numel(c)
            if numel(c{k}) < 1
                self.content{k} = {};
            else
                tmp = [{'type'},c{k}];
                if mod(numel(tmp),2)
                    tmp{end} = [];
                end
                self.content{k} = self.pvpair2struct(tmp);                
            end        
        end
        
        self.id = [datestr(now,'yyyymmddHHMMSSFFF') '_win'];

        %convert padding to pixels
        self.pad = self.inch2px(self.pad);

        self.InitFigure;

        self.SetFocus(self.opt.focus);

        pause(.1);

        drawnow;
    end
    %-------------------------------------------------------------------------%
    function Wait(self)
        uiwait(self.h);
    end
    %-------------------------------------------------------------------------%
    function SetFocus(self,tag)
        k = self.Tag2Index(tag);
        if ~isempty(k)
            uicontrol(self.el{k}.GetProp('h'));
        end
    end
    %-------------------------------------------------------------------------%
    function FetchResult(self,varargin)
        b = true;
        for k = 1:numel(self.el)
            if ~isempty(self.el{k}) && ~isempty(self.el{k}.tag)
                if self.validate
                    [b,val] = self.el{k}.Validate;
                    if ~b
                        self.validate = false;  
                        hErr = warndlg(val,'Invalid Input');
                        hMsg = findobj(hErr,'Type','text');
                        set(hMsg,'FontSize',12,'Interpreter','tex');
                        uiwait(hErr);
                        uicontrol(self.el{k}.h);
                        break;
                    else
                        self.res.(self.el{k}.tag) = val;    
                    end
                else
                    self.res.(self.el{k}.tag) = self.el{k}.Response;
                end
            end
        end
        if b
            delete(self.h);
        end
    end
    %-------------------------------------------------------------------------%
    function BtnPush(self,obj,validate)
        self.res.btn = get(obj,'String');
        self.validate = validate;
        self.FetchResult;
    end
    %-------------------------------------------------------------------------%
    function SetElementProp(self,tag,field,val)        
        k = self.Tag2Index(tag);
        if ~isempty(k)
            self.el{k}.SetProp(field,val);
        end
    end
    %-------------------------------------------------------------------------%
    function val = GetElementProp(self,tag,field)
        val = [];
        k = self.Tag2Index(tag);
        if ~isempty(k)
            val = self.el{k}.GetProp(field);
        end
    end
    %-------------------------------------------------------------------------%
    function ReSize(self)
        self.AddElements(false);
    end
    %-------------------------------------------------------------------------%
    function delete(self)
        if isvalid(self) && ishandle(self.h)
            close(self.h);
        end
    end
    %-------------------------------------------------------------------------%
end
%METHODS----------------------------------------------------------------------%

%PRIVATE METHODS--------------------------------------------------------------%
methods (Access=private)
    %-------------------------------------------------------------------------%
    pos = GetFigPosition(w,h,varargin);
    %-------------------------------------------------------------------------%
    function k = Tag2Index(self,tag)
        for k = 1:numel(self.el)
            if ~isempty(self.el{k})
                if strcmpi(tag,self.el{k}.tag)                    
                    return;
                end
            end
        end
        k = [];
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
    function InitFigure(self)
        %get the size and position for the figure
        w = self.inch2px(2.5) * max(self.ncol);
        h = self.inch2px(.5) * self.nrow;       
        pos = self.GetFigPosition(w,h,...
              'xoffset',self.opt.position(1),'yoffset',self.opt.position(2));

        %main figure
        self.h = figure('Units','pixels','OuterPosition',pos,...
                    'Name',self.opt.title,'NumberTitle','off','MenuBar','none',...
                    'Tag',self.id,'Resize','off','CloseRequestFcn',@self.FetchResult,...
                    'KeyPressFcn',@self.KeyPress);
       
        self.AddElements(true);
    end
    %-------------------------------------------------------------------------%
    function AddElements(self,varargin)
        if ~isempty(varargin) && islogical(varargin{1})
            el_init = varargin{1};            
        else
            el_init = true;
        end
        left  = Inf;
        right = -Inf;
        height = 0;
        [width,height] = deal(zeros(self.nrow,max(self.ncol)));
        for kR = 1:self.nrow            
            for kC = 1:max(self.ncol)                
                halign = self.GetHAlignment(kC,self.ncol(kR));
                if ~isempty(self.content{kR,kC})
                    if el_init
                        pos = self.GetElementPosition(kR,kC);                    
                        self.el{kR,kC} = FT.tools.Element(self,pos,self.content{kR,kC},'halign',halign);
                        [width(kR,kC),height(kR,kC)] = self.el{kR,kC}.GetSize;
                    else                        
                        [width(kR,kC),height(kR,kC)] = self.el{kR,kC}.ReSize;
                    end
                else
                    self.el{kR,kC} = {};
                end
            end            
        end

        if ~self.opt.grid
            fig_width = max(sum(width,2)) + (self.pad * (max(self.ncol)+1));;            
        else            
            mx_width  = max(width,[],1);            
            fig_width = sum(mx_width) + (self.pad * (max(self.ncol)+1));            
        end
        mx_height = max(height,[],2);
        fig_height = sum(mx_height) + (self.pad * (self.nrow+1));        
        pFig = self.GetFigPosition(fig_width,fig_height,...
              'xoffset',self.opt.position(1),'yoffset',self.opt.position(2));
        
        set(self.h,'Position',pFig);

        %width for each column and height for each row
        btm_cur = pFig(4);
        for kR = 1:self.nrow
                        
            if ~self.opt.grid
                btm_cur = btm_cur - (max(height(kR,:)) + self.pad);                
                row_width = sum(width(kR,:)) + (self.pad * (self.ncol(kR)-1));
                left_cur = (pFig(3)/2) - (row_width/2);
            else
                btm_cur = btm_cur - (mx_height(kR) + self.pad);
                left_cur = self.pad;
            end
            for kC = 1:max(self.ncol)                
                if ~isempty(self.el{kR,kC})
                    if ~self.opt.grid
                        halign = self.GetHAlignment(kC,self.ncol(kR));
                        width_use = width(kR,kC);

                        %always use the max height of a row to get a centered vertical alignment                    
                        height_use = mx_height(kR);
                        % height_use = height(kR,kC);
                    else
                        halign = self.el{kR,kC}.opt.halign;
                        width_use = mx_width(kC);
                        height_use = mx_height(kR);
                    end                    
                    rect = [left_cur, btm_cur, width_use, height_use];
                    self.el{kR,kC}.SetOuterRect(rect,'halign',halign);
                    left_cur = left_cur + width_use + self.pad;
                end
            end
        end
    end
    %-------------------------------------------------------------------------%
    function ep = GetElementPosition(self,kR,kC)
        fp = get(self.h,'OuterPosition');
        nC = self.ncol(kR);
        sum_pad = self.pad/self.nrow;
        height = (fp(4)/self.nrow) - (self.pad + sum_pad);
        ep = zeros(1,4);        
        ep(1) = ((fp(3)/nC) * (kC-1)) + self.pad;
        ep(2) = fp(4) - (kR * (height + self.pad));
        ep(3) = (fp(3)/nC) - (self.pad);
        ep(4) = height;
    end
    %-------------------------------------------------------------------------%
    function algn = GetHAlignment(self,kC,nC)
        if kC == 1
            algn = 'right';
        elseif kC == nC
            algn = 'left';
        else
            algn = 'center';
        end
    end
    %-------------------------------------------------------------------------%
    function KeyPress(self,obj,evt)
        switch lower(evt.Key)
           case 'w'
               if ismember('control',evt.Modifier)
                   self.FetchResult;
               end
           otherwise
        end
    end
    %-------------------------------------------------------------------------%
end
%PRIVATE METHODS--------------------------------------------------------------%

%PRIVATE STATIC METHODS-------------------------------------------------------%
methods (Static=true,Access=private)
    %-------------------------------------------------------------------------%
    function s = pvpair2struct(c)
    %convert a 1xN or Nx1 cell of parameter value pairs to a struct
        fields = cellfun(@lower,c(1:2:end-1),'uni',false);
        s = cell2struct(c(2:2:end),fields,2);
    end
    %-------------------------------------------------------------------------%    
    function px = inch2px(in)
        px = get(0,'ScreenPixelsPerInch')*in;
    end
    %-------------------------------------------------------------------------%
end
%PRIVATE STATIC METHODS-------------------------------------------------------%

%STATIC METHODS---------------------------------------------------------------%
methods (Static=true)
    w = Test(varargin);
end
%STATIC METHODS---------------------------------------------------------------%

end