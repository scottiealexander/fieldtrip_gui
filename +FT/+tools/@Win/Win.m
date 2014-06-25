classdef Win < handle

% Win
%
% Description:
%
% Syntax:
%
% In:
%
% Out:
%
% Updated: 2014-06-25
% Scottie Alexander
%
% Please send bug reports to: scottiealexander11@gmail.com

% TODO:
%   1) implement 'row-wise' construction so that rows can have a different number of columns
%      BUT, what should we do with the axes...? Only acutally make axes for text objects?
%      *OR* if we use only fixed width fonts maybe we can revert to uicontrol text objects...?
%   2) column resizing (increase only of course)
%   3) button resizing based on string (USE FIXED WIDTH FONT)


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
    res = struct('btn',[]);
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
            'position' ,  [0,0]  ...
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

        %uiwait(self.h);
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
                        uiwait(errordlg(val,'Invalid Input'));
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
       
        self.AddElements;
        
    end
    %-------------------------------------------------------------------------%
    function AddElements(self)
        left  = Inf;
        right = -Inf;
        height = 0;
        [width,height] = deal(zeros(self.nrow,max(self.ncol)));
        for kR = 1:self.nrow            
            for kC = 1:max(self.ncol)                
                align = self.GetHAlignment(kC,self.ncol(kR));
                if ~isempty(self.content{kR,kC})                    
                    pos = self.GetElementPosition(kR,kC);                    
                    self.el{kR,kC} = FT.tools.Element(self,pos,self.content{kR,kC},'halign',align);
                    [width(kR,kC),height(kR,kC)] = size(self.el{kR,kC});                    
                else
                    self.el{kR,kC} = {};
                end
            end            
        end

        mx_width  = max(width,[],1);
        mx_height = max(height,[],2);
        fig_width = sum(mx_width) + (self.pad * (max(self.ncol)+1));
        fig_height = sum(mx_height) + (self.pad * (self.nrow+1));
        pFig = self.GetFigPosition(fig_width,fig_height,...
              'xoffset',self.opt.position(1),'yoffset',self.opt.position(2));
        
        set(self.h,'Position',pFig);

        %width for each column and height for each row
        btm_cur = pFig(4);
        for kR = 1:self.nrow
            btm_cur = btm_cur - (mx_height(kR) + self.pad);            
            if ~self.opt.grid
                row_width = sum(width(kR,:)) + (self.pad * (self.ncol(kR)-1));
                left_cur = (pFig(3)/2) - (row_width/2);
            else                
                left_cur = self.pad;
            end
            for kC = 1:max(self.ncol)                
                if ~isempty(self.el{kR,kC})
                    if ~self.opt.grid
                        halign = self.GetHAlignment(kC,self.ncol(kR));
                        width_use = width(kR,kC);
                    else
                        halign = self.el{kR,kC}.opt.halign;
                        width_use = mx_width(kC);
                    end                    
                    rect = [left_cur, btm_cur, width_use, mx_height(kR)];
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