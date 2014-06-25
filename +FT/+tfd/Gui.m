function Gui(varargin)

% FT.tfd.Gui
%
% Description: get parameters for Hilbert decomposition from user via a GUI
%
% Syntax: FT.tfd.Gui
%
% In: 
%
% Out: 
%
% Updated: 2014-06-23
% Peter Horak
%
% See also: FT.tfd.Run
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;
if ~FT.CheckStage('tfd')
    return;
end
%make sure there is trial info
if ~isfield(FT_DATA,'epoch') || isempty(FT_DATA.epoch)
    if ~FT.DefineTrial
        return;
    end
end

availableMethods = {'Hilbert'};

fnyq = floor(FT_DATA.data.fsample/2);
cfg = struct('lo',10,'hi',fnyq,'n',42,'w',10,'log',true,'surrogate',true,'nsurrogate',10);
cfg.method = availableMethods{1};
loShared = cfg.lo;

c = {...
    {'text','String','Select Method:'},...
    {'pushbutton','String',cfg.method,'Callback',@SelectMethod};...
    {'text','String','Starting Frequency [Hz]:'},...
    {'edit','size',5,'String',num2str(cfg.lo),'tag','lo','valfun',@CheckLo};...
    {'text','String','Ending Frequency [Hz]:'},...
    {'edit','size',5,'String',num2str(cfg.hi),'tag','hi','valfun',@CheckHi};...
    {'text','String','Number of bins:'},...
    {'edit','size',5,'String',num2str(cfg.n),'tag','n','valfun',{'inrange',1,fnyq,true}};...
    {'text','String','Bin width [%]:'},...
    {'edit','size',5,'String',num2str(cfg.w),'tag','w','valfun',{'inrange',0.001,100,true}};...
    ...
    {'text','string','Use logarithmmic spacing?:'},...
	{'checkbox','value',cfg.log,'tag','log'};...
    {'text','string','Generate surrogate data?:'},...
	{'checkbox','value',cfg.surrogate,'tag','surrogate'};...
    ...
    {'text','String','# Surrogate Datasets:'},...
    {'edit','size',5,'String',num2str(cfg.nsurrogate),'tag','nsurrogate','valfun',{'inrange',0,1e4,true}};...
    ...
    {'pushbutton','String','Run'},...
    {'pushbutton','String','Cancel','validate',false};...
    };

win = FT.tools.Win(c,'title','Time-Frequency Decomposition');
uiwait(win.h);

if strcmpi(win.res.btn,'cancel')
    return;
else
    cfg.lo = win.res.lo;
    cfg.hi = win.res.hi;
    cfg.n = win.res.n;
    cfg.w = win.res.w;
    cfg.log = win.res.log;
    cfg.surrogate = win.res.surrogate;
    cfg.nsurrogate = win.res.nsurrogate;
end

me = FT.tfd.Run(cfg);

if isa(me,'MException')
    FT.ProcessError(me);
elseif cfg.surrogate && cfg.nsurrogate > 0
	FT.tfd.Surrogate(cfg.nsurrogate);
end

FT.UpdateGUI;

%-------------------------------------------------------------------------%
function [b,val] = CheckLo(str)
    loShared = str2double(str);
    [b,val] = FT.tools.Element.inrange(str,0,fnyq,true);
end
%-------------------------------------------------------------------------%
function [b,val] = CheckHi(str)
    [b,val] = FT.tools.Element.inrange(str,loShared,fnyq,true);
end
%-------------------------------------------------------------------------%
function SelectMethod(obj,evt)
%allow user to select the frequency decomposition method   
    %set the size of the figure
    hFig = FT.tools.Inch2Px(0.171)*numel(availableMethods);
    wFig = FT.tools.Inch2Px(2.5);
    
    %get the users selection
    [kMeth,b] = listdlg('Name','Select Method',...
       'ListString',availableMethods,'ListSize',[wFig,hFig],...
       'SelectionMode','single');
    if b && ~isempty(kMeth)
        cfg.method = availableMethods{kMeth};
        set(obj,'String',cfg.method);        
    end
end
%-------------------------------------------------------------------------%
end
