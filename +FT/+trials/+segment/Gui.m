function varargout = Gui(varargin)

% FT.trials.segment.Gui
%
% Description: define trials for segmentation
%
% Syntax: FT.trials.segment.Gui
%
% In: 
%
% Out:  epoch
%
% Updated: 2014-07-22
% Peter Horak
%
% See also: FT.trials.segment.Run

global FT_DATA;
EPOCH = {};
num_output = nargout;

%make sure we are ready to run
if ~FT.tools.Validate('segment_trials','done',{'read_events'},'todo',{'segment_trials'})
    return;
end

%main figure
pFig = FT.tools.GetFigPosition(700,500);
h = figure('Units','pixels','OuterPosition',pFig,...
           'Name','Define Trial','NumberTitle','off','MenuBar','none',...
           'KeyPressFcn',@KeyPress);

bgColor = get(h,'Color');

% --- event code display --- %
evt = FT.ReStruct(FT_DATA.event);
[vals,k] = unique(evt.value,'first');
s.type = evt.type(k);
s.vals = vals;
if isnumeric(evt.value)
    s.freq = arrayfun(@(x) sum(evt.value==x),s.vals);
else
    s.freq = arrayfun(@(x) sum(strcmpi(x,evt.value)),s.vals);
end

%make the event code dsipay look nice
lenMax = max(cellfun(@length,s.type));
lenMax = lenMax+(4-mod(lenMax,4));
s.type = cellfun(@(x) Fill(x,lenMax),s.type,'uni',false);

%pad first header so that 2nd and 3rd column headers are aligned with their
%column
strHD1 = 'type';
nAdd = lenMax-length(strHD1);
if nAdd > 0
    strHD1 = [strHD1 repmat(' ',1,nAdd)];
end

%get the string
strCodeCur = FT.io.WriteStruct(s,'headers',{strHD1,'code','# of occurances'},'delim',9);       

% --- current event codes --- %
pPanel = [.42 .15 .56 .83];
hPanelCur = uipanel('Units','normalized','Position',pPanel,'HighlightColor',[0 0 0],...
    'Title','Current Event Codes','FontSize',12,'FontWeight','bold',...
    'FontName','FixedWidth','Parent',h);

uicontrol('Style','edit','Units','normalized','Position',[.01 .01 .99 .99],...
            'String',strCodeCur,'Parent',hPanelCur,'BackgroundColor',[1 1 1],...
            'HorizontalAlignment','left','Max',2,'Min',0,'Enable','Inactive',...
            'FontSize',14);

% --- GUI PARAMS --- %
wTxt   = .23;
hEdit  = .1;
wEdit  = .15;
lEdit  = wTxt+.01;
pad    = .02;
top    = .84;
offset = .12;
f      = @(x) top-(hEdit*x + pad*(x-1));

% --- TIME-LOCK EVENT --- %
hTL = uicontrol('Style','edit','Units','normalized','Position',[lEdit f(0) wEdit hEdit],...
    'String','','BackgroundColor',[1 1 1],'Parent',h);
uicontrol('Style','text','Units','normalized','Position',[0 f(0)-offset wTxt .2],...
    'String','Time-lock Event:','FontSize',14,'BackgroundColor',bgColor,...
    'HorizontalAlignment','right','Parent',h);

hPre = uicontrol('Style','edit','Units','normalized','Position',[lEdit f(1) wEdit-.05 hEdit],...
    'String','','BackgroundColor',[1 1 1],'Parent',h);
uicontrol('Style','text','Units','normalized','Position',[0 f(1)-offset wTxt .2],...
    'String','Time Before (sec):','FontSize',14,'BackgroundColor',bgColor,...
    'HorizontalAlignment','right','Parent',h);

hPost = uicontrol('Style','edit','Units','normalized','Position',[lEdit f(2) wEdit-.05 hEdit],...
    'String','','BackgroundColor',[1 1 1],'Parent',h);
uicontrol('Style','text','Units','normalized','Position',[0 f(2)-offset wTxt .2],...
    'String','Time After (sec):','FontSize',14,'BackgroundColor',bgColor,...
    'HorizontalAlignment','right','Parent',h);

uicontrol('Style','text','Units','normalized','Position',[0 f(2.5) .4 .05],...
    'String','%--------------------------------%','BackgroundColor',bgColor,...
    'HorizontalAlignment','center','Parent',h);

% --- START/END EVENT --- %

%checkbox
hChkP = uipanel(h,'Units','normalized','Position',[lEdit f(3) .04 .04*(7/5)],...
    'BackgroundColor',bgColor,'HighlightColor',[0 0 0]);

hChk = uicontrol('Style','checkbox','Units','normalized','Value',0,...
    'Position',[.07 .16 .7 .65],'BackgroundColor',bgColor,...
    'Callback',@CheckCtrl,'Parent',hChkP);

uicontrol('Style','text','Units','normalized','Position',[0 f(3)-.1 wTxt .15],...
    'String','Define Start:End - ','FontSize',12,'FontWeight','bold',...
    'BackgroundColor',bgColor,'HorizontalAlignment','right','Parent',h);

%start event
hStrt = uicontrol('Style','edit','Units','normalized','Position',[lEdit f(4) wEdit hEdit],...
    'String','','BackgroundColor',[1 1 1],'Enable','off','Parent',h);
uicontrol('Style','text','Units','normalized','Position',[0 f(4)-offset wTxt .2],...
    'String','Starting Event:','FontSize',14,'BackgroundColor',bgColor,...
    'HorizontalAlignment','right','Parent',h);

%end event
hEnd = uicontrol('Style','edit','Units','normalized','Position',[lEdit f(5) wEdit hEdit],...
    'String','','BackgroundColor',[1 1 1],'Enable','off','Parent',h);
uicontrol('Style','text','Units','normalized','Position',[0 f(5)-offset wTxt .2],...
    'String','Ending Event:','FontSize',14,'BackgroundColor',bgColor,...
    'HorizontalAlignment','right','Parent',h);

uicontrol('Style','text','Units','normalized','Position',[0 f(6) .4 .1],...
    'String','%--------------------------------%','BackgroundColor',bgColor,...
    'HorizontalAlignment','center','Parent',h);

strDesc = 'Name for this condition: ';
uicontrol('Style','text','Units','normalized','Position',[0 f(6.4) lEdit-.01 .1],...
    'String',strDesc,'FontSize',14,'BackgroundColor',bgColor,...
    'HorizontalAlignment','right','Parent',h);

hName = uicontrol('Style','edit','Units','normalized','Position',[lEdit f(6.4) wEdit hEdit],...
    'String','','BackgroundColor',[1 1 1],'Parent',h);

% --- BUTTONS --- %
wBtn = .15;
lInit = pPanel(1)+(pPanel(3)/2) - ((wBtn*2 + .05)/2);

uicontrol('Style','pushbutton','Units','normalized','Position',[.05 .01 wBtn+.19 .07],...
    'String','Define Another Condition','Callback',@BtnCtrl,'Parent',h);

uicontrol('Style','pushbutton','Units','normalized','Position',[lInit .02 wBtn .1],...
    'String','Run','Callback',@BtnCtrl,'Parent',h);

uicontrol('Style','pushbutton','Units','normalized','Position',[lInit+wBtn+.05 .02 wBtn .1],...
    'String','Cancel','Callback',@BtnCtrl,'Parent',h);

uicontrol(hTL);
uiwait(h);

%------------------------------------------------------------------------------%
function BtnCtrl(obj,~)
%process the users input (quit or make the trial definition)
    strBtn = regexp(get(obj,'String'),'[^\s]*','match','once');
    bError = false;
    [strMsg,strType] = deal('');
    switch lower(strBtn)
        case {'run','define'}
            if get(hChk,'Value')
                %trials are defined by start and end events (i.e. endpoint
                %format)
                sOpt.start = get(hStrt,'String');
                sOpt.end = get(hEnd,'String');
                
                %make sure user input is a valid event type/code
                field1 = CheckEvtLabel(sOpt.start);
                field2 = CheckEvtLabel(sOpt.end);
                if isempty(field1)
                    bError = true;
                    strMsg = ['\bfEvent type ''\color{red}' sOpt.start ...
                        '\color{black}'' does not match any event type or event code. Please check your input and try again.'];
                    strType = 'Event Type Error';                    
                elseif isempty(field2)
                    bError = true;
                    strMsg = ['\bfEvent type ''\color{red}' sOpt.end ...
                        '\color{black}'' does not match any event type or event code. Please check your input and try again.'];
                    strType = 'Event Type Error';                    
                elseif ~strcmpi(field1,field2)
                     bError = true;
                     strMsg = ['\bfAn inconsistency was detected in given event codes/types.\n'...
                        'Please use either event codes OR event types, not a mix of both.'];
                        strType = 'Event Type Error';                    
                end
                
                all_empty = isempty(sOpt.start) && isempty(sOpt.end);

                %trial def format
                fmt = 'endpoints';
            else
                %trials are defined relative to a single event (typical
                %timelock)
                strPre     = get(hPre,'String');
                strPost    = get(hPost,'String');
                sOpt.event = get(hTL,'String');
                sOpt.pre   = abs(str2double(strPre));
                sOpt.post  = abs(str2double(strPost));
                
                if isnan(sOpt.pre) || isnan(sOpt.post)
                    bError = true;
                    strMsg = ['\bf\color{red}One of the times you entered was not a number.\n' ...
                        '\color{black}Please check your input and try again.'];
                    strType = 'Time Entry Error';                    
                end
                
                %verify that user input is a valid event type/code
                field1 = CheckEvtLabel(sOpt.event);
                if isempty(field1) && ~bError
                    bError = true;
                    strMsg = ['\bfEvent type ''\color{red}' sOpt.event ...
                        '\color{black}'' does not match any event type or event code. Please check your input and try again.'];
                    strType = 'Event Type Error';                    
                end
                
                all_empty = isempty(sOpt.event);

                %trial def format
                fmt = 'timelock';
            end
            
            strName = get(hName,'String');
            if isempty(strName) && ~bError
                bError = true;
                strMsg = ['\bf\color{red}No Condition Name Given\color{black}',...
                          ':\nPlease enter a name for this condition.'];
                strType = 'Condition Name Required';                
                uicontrol(hName);
            elseif ~bError
                all_empty = false;
            end

            if ~bError
                % --- MAKE TRIAL DEFINITION --- %
                trl = FT.trials.segment.MakeTRL(fmt,sOpt,field1);
                
                %save the info
                sOpt.field = field1;
                sOpt.format = fmt;
%                 FT_DATA.history.segmentation = sOpt;
                EPOCH{end+1,1}.name = strName;
                EPOCH{end,1}.trl = trl;
                EPOCH{end,1}.ifo = sOpt;
            elseif ~all_empty || ~strcmpi(strBtn,'run')
                FT.UserInput(strMsg,0,'button','OK','title',strType);
                return;
            end

            if strcmpi(strBtn,'run')
                if ~num_output;
                    %get baseline correction parameters
                    b_cfg = FT.trials.baseline.Gui;
                    
                    %run segmentation with trial definitions
                    hMsg = FT.UserInput('Segmenting data into trials',1);
                    
                    params.epoch = EPOCH;
                    me = FT.trials.segment.Run(params);
                    if ishandle(hMsg)
                        close(hMsg);
                    end
                    
                    %baseline correct if selected and no errors occured
                    if ~isempty(b_cfg) && ~isa(me,'MException')
                        me = FT.trials.baseline.Run(b_cfg);
                    end
                    
                    FT.ProcessError(me);
                    FT.UpdateGUI;
                else
                    %return trial definitions
                    varargout{1} = EPOCH;
                end    
                if ishandle(h)
                    close(h);
                end
            else                
                if get(hChk,'Value')
                    set([hStrt,hEnd,hName,hChk],'String','');
                    uicontrol(hStrt);
                else                    
                    set([hTL,hName],'String','');
                    set([hPre,hPost,hChk],'enable','off');
                    uicontrol(hTL);
                end
            end

        case 'cancel'
            varargout{1} = []; 
            if ishandle(h)
                close(h);
            end            
        otherwise
            %should never happen
    end
end
%------------------------------------------------------------------------------%
function CheckCtrl(obj,~)
%toggle endpoint and timelock trial definition formats so that user can give us
%*EITHER* endpoints (start and end events) *OR* an event and pre and post
%durations but not both
    b = get(obj,'Value');
    if b
        set([hStrt hEnd],'Enable','on');
        set([hTL hPre hPost],'enable','off');
    else
        set([hStrt hEnd],'Enable','off');
        set([hTL hPre hPost],'enable','on');
    end
end
%------------------------------------------------------------------------------%
function str = Fill(str,n)
%fill a string to a given length for pretty printing
    n = n-length(str);
    if n > 0
        str = [str repmat(' ',1,n)];
    end
end
%------------------------------------------------------------------------------%
function strField = CheckEvtLabel(str)
%make sure the event type/code that the user gave us is valid
    strField = '';
    %check event types first
    if any(strcmpi(str,evt.type))
        strField = 'type';        
    else
        %now check event values
        if iscell(evt.value) && iscellstr(evt.value)
            %cell of strings, check membership
            if any(strcmpi(str,evt.value))
                strField = 'value';
            end
        elseif iscell(evt.value) && all(cellfun(@isnumeric,evt.value))
            %cell of doubles (this SHOULD never happen but...)
            %str should be a number in this case
            str = str2double(str);
            if any(str==cat(1,evt.value{:}))
                strField = 'value';
            end
        elseif isnumeric(evt.value)
            %array of doubles (most common)
            %again, user input (str) should be a num-string
            str = str2double(str);
            if any(str==evt.value)
                strField = 'value';
            end
        else
            %WTF??? either the fieldtrip people, or more likely I, really 
            %screwed something up...
            me = MException('EventError:InconsistentEventType',...
                'Inconsistent event values detected, this is a major issue and should be solved before continuing.');
            FT.ProcessError(me);
        end
    end
end
%------------------------------------------------------------------------------%
end
