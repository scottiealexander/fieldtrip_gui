function [bRun,cfg] = GetHilbertParameters()

% GetHilbertParameters
%
% Description: 
%
% Syntax: GetHilbertParameters
%
% In: 
%
% Out: 
%
% Updated: 2014-03-31
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;
FS = FT_DATA.data.fsample;
bRun = false;
cfg = struct('lo',10,'hi',floor(FS/2),'n',42,'w',10,'log',true,'surrogate',true);

%open the figure for the GUI
pFig = GetFigPosition(320,280);
h = figure('Units','pixels','OuterPosition',pFig,...
        'Name','Hilbert Decomposition','NumberTitle','off','MenuBar','none','KeyPressFcn',@KeyPress);

bgColor = get(h,'Color');

hEdt = .1;
        
%min frequency
    uicontrol('Style','text','String','Starting Frequency [Hz]:',...
            'Units','normalized','FontSize',12,'FontWeight','bold',...
            'Position',[0 .85 .61 .1],'BackgroundColor',bgColor,...
            'Parent',h,'HorizontalAlignment','right');

    hLo = uicontrol('Style','edit','Units','normalized','String',num2str(cfg.lo),...
            'Position',[.65 .87 .15 hEdt],'BackgroundColor',[1 1 1],...
            'KeyPressFcn',@KeyPress,'Parent',h);
        
%max frequency
    uicontrol('Style','text','String','Ending Frequency [Hz]:',...
            'Units','normalized','FontSize',12,'FontWeight','bold',...
            'Position',[0 .7 .6 .1],'BackgroundColor',bgColor,...
            'Parent',h,'HorizontalAlignment','right');

    hHi = uicontrol('Style','edit','Units','normalized','String',num2str(cfg.hi),...
            'Position',[.65 .72 .15 hEdt],'BackgroundColor',[1 1 1],...
            'KeyPressFcn',@KeyPress,'Parent',h);

%number of bins
    uicontrol('Style','text','String','Number of bins:',...
            'Units','normalized','FontSize',12,'FontWeight','bold',...
            'Position',[.12 .55 .48 .1],'BackgroundColor',bgColor,...
            'Parent',h,'HorizontalAlignment','right');

    hN = uicontrol('Style','edit','Units','normalized','String',num2str(cfg.n),...
            'Position',[.65 .57 .15 hEdt],'BackgroundColor',[1 1 1],...
            'KeyPressFcn',@KeyPress,'Parent',h);

%bin width
    uicontrol('Style','text','String','Bin width [%]:',...
            'Units','normalized','FontSize',12,'FontWeight','bold',...
            'Position',[.12 .4 .48 .1],'BackgroundColor',bgColor,...
            'Parent',h,'HorizontalAlignment','right');

    hW = uicontrol('Style','edit','Units','normalized','String',num2str(cfg.w),...
            'Position',[.65 .42 .15 hEdt],'BackgroundColor',[1 1 1],...
            'KeyPressFcn',@KeyPress,'Parent',h);

%linear or log spacing
    uicontrol('Style','text','String','Use logarithmic spacing?:',...
            'Units','normalized','FontSize',12,'FontWeight','bold',...
            'Position',[0 .26 .65 .1],'BackgroundColor',bgColor,...
            'Parent',h,'HorizontalAlignment','right');

	hLog = uicontrol('Style','checkbox','Units','normalized','Position',[.7 .29 .07 .08],...
			'BackgroundColor',[1 1 1],'Min',0,'Max',1,'Value',cfg.log,'Parent',h);

%compute surrogate dataset
    uicontrol('Style','text','String','Generate surrogate data?:',...
            'Units','normalized','FontSize',12,'FontWeight','bold',...
            'Position',[0 .14 .65 .1],'BackgroundColor',bgColor,...
            'Parent',h,'HorizontalAlignment','right');
            
	hSur = uicontrol('Style','checkbox','Units','normalized','Position',[.7 .17 .07 .08],...
			'BackgroundColor',[1 1 1],'Min',0,'Max',1,'Value',cfg.surrogate,'Parent',h);

%run filtering button
    lBtn = .5 - (.2*2 + .05)/2;
    uicontrol('Style','pushbutton','String','Run','Units','normalized',...
            'Position',[lBtn .02 .2 hEdt],'Parent',h,'Callback',@BtnCtrl);

%cancel button
    uicontrol('Style','pushbutton','String','Cancel','Units','normalized',...
        'Position',[lBtn+.25 .02 .2 hEdt],'Parent',h,'Callback',@BtnCtrl);

uicontrol(hLo);

uiwait(h);

if ishandle(h)
	close(h);
end

%-------------------------------------------------------------------------%
function BtnCtrl(obj,varargin)
	action = get(obj,'String');
	switch lower(action)
	case 'run'
		[cfg.lo,b] = CheckEntry(hLo,0,round(FS/2));
		if ~b, return; end
		[cfg.hi,b] = CheckEntry(hHi,cfg.lo,round(FS/2));
		if ~b, return; end
		[cfg.n,b] = CheckEntry(hN,1,round(FS/2));
		if ~b, return; end
		[cfg.w,b] = CheckEntry(hW,.001,100);
		if ~b, return; end
		cfg.log = logical(get(hLog,'Value'));
		cfg.surrogate = logical(get(hSur,'Value'));
		bRun = true;
		if ishandle(h)
			close(h);
		end
	case 'cancel'
		if ishandle(h)
			close(h);
		end
	otherwise
		%this should never happen...
	end
end
%-------------------------------------------------------------------------%
function [x,b] = CheckEntry(h,lb,hb)
	b = false;
	str = get(h,'String');
	x = str2double(str);
	if isnan(x)
		uicontrol(h);
		FT.UserInput('\bf[\color{red}ERROR\color{black}]: Invalid entry - please enter a number',1,'button','OK');		
	elseif x < lb  || x > hb
		uicontrol(h);
		FT.UserInput('\bf[\color{red}ERROR\color{black}]: The number you have entered is outside the allowable range!',1,'button','OK');
	else
		b = true;
	end
end
%-------------------------------------------------------------------------%
end
