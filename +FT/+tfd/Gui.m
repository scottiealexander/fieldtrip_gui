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
% Updated: 2014-10-09
% Scottie Alexander
%
% See also: FT.tfd.Run
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

if ~FT.tools.Validate('tfd','done',{'read_events','define_trials'},'todo',{'tfd','segment_trials'})
    return;
end

try % test if the wavelet toolbox is installed
    centfrq('morl');
    availableMethods = {'Hilbert','Wavelet','STFT'};
catch % wavelet toolbox not installed
    availableMethods = {'Hilbert','STFT'};
end

fnyq = floor(FT_DATA.data.fsample/2);
params = struct('lo',10,'hi',fnyq,'n',42,'w',10,'log',true,'surrogate',true,'nsurrogate',10);
params.method = availableMethods{1};

c = {...
    {'text','String','Select Method:'},...    
    {'listbox','String',availableMethods,'tag','method','Callback',@MethodCB};...
    {'text','String','Starting Frequency [Hz]:'},...
    {'edit','String',num2str(params.lo),'tag','lo','valfun',@CheckFreqN};...
    {'text','String','Ending Frequency [Hz]:'},...
    {'edit','String',num2str(params.hi),'tag','hi','valfun',@CheckFreqN};...
    {'text','String','Number of bins:'},...
    {'edit','String',num2str(params.n),'tag','n','valfun',@CheckFreqN};...
    {'text','String','Bin width [%]:'},...
    {'edit','String',num2str(params.w),'tag','w','valfun',{'inrange',1,90,true}};...
    ...
    {'text','string','Use logarithmmic spacing?:'},...
	{'checkbox','value',params.log,'tag','log'};...
    {'text','string','Generate surrogate data?:'},...
	{'checkbox','value',params.surrogate,'tag','surrogate','Callback',@SurrogateCB};...
    ...
    {'text','String','# Surrogate Datasets:'},...
    {'edit','String',num2str(params.nsurrogate),'tag','nsurrogate','valfun',{'inrange',0,1e4,true}};...
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

% Time-frequency decomposition
me = FT.tfd.Run(params);
FT.ProcessError(me);

if ~isa(me,'MException')
    % Segmentation of time series
    me = FT.trials.segment.Run([]);
    FT.ProcessError(me);
end

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
    if strcmpi(availableMethods{k},'hilbert')
        win.SetElementProp('w','Enable','on');
    else
        win.SetElementProp('w','Enable','off');
    end
end
%-------------------------------------------------------------------------%
function SurrogateCB(varargin)
    if ~win.GetElementProp('surrogate','Value')
        win.SetElementProp('nsurrogate','String','0');
        win.SetElementProp('nsurrogate','Enable','off');
    else
        win.SetElementProp('nsurrogate','String',num2str(params.nsurrogate));
        win.SetElementProp('nsurrogate','Enable','on');
    end
end
%-------------------------------------------------------------------------%
function [b,val] = CheckFreqN(str)
    b = false;
    
    lo = str2double(win.GetElementProp('lo','string'));
    hi = str2double(win.GetElementProp('hi','string'));
    n = str2double(win.GetElementProp('n','string'));
    tlen = diff(FT_DATA.data.sampleinfo)/FT_DATA.data.fsample;

    if ~(ceil(1/tlen) <= lo && lo <= fnyq)
        val = 'Invalid value for the starting frequency.';
    elseif ~(ceil(1/tlen) <= hi && hi <= fnyq)
        val = 'Invalid value for the ending frequency.';
    elseif ~(lo + 1 < hi)
        val = 'The ending frequency must be at least 1Hz above the starting frequency.';
    elseif ~(mod(n,1) == 0)
        val = 'The number of frequency bins must be an integer.';
    elseif  ~(1 < n && n < floor(tlen*(hi-lo)))
        val = 'The requested number of frequency bins cannot be obtained.';
    else
        b = true;
        val = str2double(str);
    end
end
%-------------------------------------------------------------------------%
end
