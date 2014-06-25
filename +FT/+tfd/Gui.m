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

availableMethods = {'Hilbert','Wavelet','STFT'};

fnyq = floor(FT_DATA.data.fsample/2);
params = struct('lo',10,'hi',fnyq,'n',42,'w',10,'log',true,'surrogate',true,'nsurrogate',10);
params.method = availableMethods{1};
loShared = params.lo;

c = {...
    {'text','String','Select Method:'},...    
    {'listbox','String',availableMethods,'tag','method','Callback',@MethodCB};...
    {'text','String','Starting Frequency [Hz]:'},...
    {'edit','size',5,'String',num2str(params.lo),'tag','lo','valfun',@CheckLo};...
    {'text','String','Ending Frequency [Hz]:'},...
    {'edit','size',5,'String',num2str(params.hi),'tag','hi','valfun',@CheckHi};...
    {'text','String','Number of bins:'},...
    {'edit','size',5,'String',num2str(params.n),'tag','n','valfun',{'inrange',1,fnyq,true}};...
    {'text','String','Bin width [%]:'},...
    {'edit','size',5,'String',num2str(params.w),'tag','w','valfun',{'inrange',0.001,100,true}};...
    ...
    {'text','string','Use logarithmmic spacing?:'},...
	{'checkbox','value',params.log,'tag','log'};...
    {'text','string','Generate surrogate data?:'},...
	{'checkbox','value',params.surrogate,'tag','surrogate','Callback',@SurrogateCB};...
    ...
    {'text','String','# Surrogate Datasets:'},...
    {'edit','size',5,'String',num2str(params.nsurrogate),'tag','nsurrogate','valfun',{'inrange',0,1e4,true}};...
    ...
    {'pushbutton','String','Run'},...
    {'pushbutton','String','Cancel','validate',false};...
    };

win = FT.tools.Win(c,'title','Time-Frequency Decomposition','grid',true);
uicontrol(win.GetElementProp('method','h'));
uiwait(win.h);

if strcmpi(win.res.btn,'cancel')
    return;
else
    params = rmfield(win.res,'btn');
    params.method = availableMethods{win.res.method};
end

me = FT.tfd.Run(params);

FT.ProcessError(me);

FT.UpdateGUI;

%-------------------------------------------------------------------------%
function MethodCB(varargin)
    k = win.GetElementProp('method','Value');
    if strcmpi(availableMethods{k},'stft')
        win.SetElementProp('log','Value',false);
        win.SetElementProp('log','Enable','off');
    else
        win.SetElementProp('log','Value',true);
        win.SetElementProp('log','Enable','on');
    end
end
%-------------------------------------------------------------------------%
function SurrogateCB(varargin)
    if ~win.GetElementProp('surrogate','Value')
        win.SetElementProp('nsurrogate','String','0');
    else
        win.SetElementProp('nsurrogate','String',num2str(params.nsurrogate));
    end
end
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
end
