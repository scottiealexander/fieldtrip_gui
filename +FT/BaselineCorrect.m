function CFG = BaselineCorrect(varargin)

% FT.BaselineCorrect
%
% Description: get parameters for baseline correcting segmented data
%
% Syntax: CFG = FT.BaselineCorrect
%
% In: 
%
% Out:
%       CFG - the configuration struct for ft_preprocessing to perform baseline correction
%
% Updated: 2013-09-17
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;
CFG = CFGDefault;

%check if this baseline correction has already been preformed
%if ~FT.CheckStage('baseline_correction')
if (~isfield(FT_DATA,'data') || isempty(FT_DATA.data)) && (~isfield(FT_DATA,'power') || isempty(FT_DATA.power))
    FT.UserInput('\bfThis dataset appears to lack data...',0,'button','OK');
    return;
end

%get the size and position for the figure
pFig = GetFigPosition(400,300);

%main figure
h = figure('Units','pixels','OuterPosition',pFig,...
           'Name','Baseline Correction','NumberTitle','off','MenuBar','none',...
           'KeyPressFcn',@KeyPress);

bgColor = get(h,'Color');

%edit box height
hEdit = .15;

%window start
wGrp = .85;
lInit = .5 - wGrp/2;
hStrt = uicontrol('Style','edit','Units','normalized','Position',[lInit+.55 .8 .3 hEdit],...
    'String','','BackgroundColor',[1 1 1],'Parent',h);
uicontrol('Style','text','Units','normalized','Position',[lInit .77 .5 .15],...
    'String',['Baseline Window Start:' 10 '(in seconds)'],'FontSize',14,'BackgroundColor',bgColor,...
    'HorizontalAlignment','center','Parent',h);

%window end
hEnd = uicontrol('Style','edit','Units','normalized','Position',[lInit+.55 .57 .3 hEdit],...
    'String','','BackgroundColor',[1 1 1],'Parent',h);
uicontrol('Style','text','Units','normalized','Position',[lInit .54 .5 .15],...
    'String',['Baseline Window End:' 10 '(in seconds)'],'FontSize',14,'BackgroundColor',bgColor,...
    'HorizontalAlignment','center','Parent',h);

%reference time point
uicontrol('Style','text','String','Times are relative too:',...
        'Units','normalized','FontSize',14,...
        'Position',[.005 .1 .5 .3],'BackgroundColor',bgColor,...
        'Parent',h);
    
hBtn = uibuttongroup('Units','normalized','Position',[.55 .25 .4 .2],...
             'BackgroundColor',[1 1 1],'HighlightColor',[0 0 0],'Parent',h); 
uicontrol('Style','Radio','String','Event','Units','normalized',...
             'Position',[.05 .3 .4 .3],'BackgroundColor',[1 1 1],'Parent',hBtn);
uicontrol('Style','Radio','String','Trial Start','Units','normalized',...
             'Position',[.45 .3 .55 .3],'BackgroundColor',[1 1 1],'Parent',hBtn);

%run and skip buttons
wBtn = .2;
lInit = .5-(wBtn*2+.05)/2;
uicontrol('Style','pushbutton','Units','normalized','Position',[lInit .05 wBtn .16],...
    'String','Run','Callback',@BtnCtrl,'Parent',h);

uicontrol('Style','pushbutton','Units','normalized','Position',[lInit+.25 .05 wBtn .16],...
    'String','Skip','Callback',@BtnCtrl,'Parent',h);

uicontrol(hStrt);

uiwait(h);

%------------------------------------------------------------------------------%
function BtnCtrl(obj,evt)
    switch lower(get(obj,'String'))
        case 'run'
            strStart = get(hStrt,'String');
            if isempty(strStart)
                strStart = '""';
            end
            strEnd = get(hEnd,'String');
            if isempty(strEnd)
                strEnd = '""';
            end
            tStart = str2double(strStart);
            tEnd = str2double(strEnd);
            
            if isnan(tStart)
                uicontrol(hStrt);
                strMsg = ['\bf[\color{red}ERROR\color{black}]: invalid value ''\color[rgb]{1 .08 .6}',...
                    strStart '\color{black}''\ngiven for ''Baseline Window Start'''];
                FT.UserInput(strMsg,0,'button','OK','title','Invalid Value','wrap',false);
                return;
            elseif isnan(tEnd)
                uicontrol(hEnd);
                strMsg = ['\bf[\color{red}ERROR\color{black}]: invalid value ''\color[rgb]{1 .08 .6}',...
                    strEnd '\color{black}''\ngiven for ''Baseline Window End'''];
                FT.UserInput(strMsg,0,'button','OK','title','Invalid Value','wrap',false);
                return;
            elseif tStart >= tEnd
                uicontrol(hEnd);
                strMsg = ['\bf[\color{red}ERROR\color{black}]: invalid input.\n'...
                          'Baseline start must occur before baseline end.'];
                FT.UserInput(strMsg,0,'button','OK','title','Invalid Input','wrap',false);
                return;
            else
                CFG.demean = 'yes';
                CFG.baselinewindow = [tStart tEnd]; 
            end
            
            %are time relative to trial start or the timelocking event?
            if strcmpi(get(get(hBtn,'SelectedObject'),'String'),'event')
                if strcmpi(FT_DATA.history.segmentation.format,'timelock')
                    %segments are defined relateive to a timelocking event                    
                    if any(CFG.baselinewindow < -abs(FT_DATA.history.segmentation.pre))
                        strMsg = ['\bf[\color{red}ERROR\color{black}]: The baseline start and/or end times that you\n',...
                                  'entered fall outside the time range of the trials.\n\nPlease check your input and try again.']; 
                        FT.UserInput(strMsg,0,'button','OK','title','Invalid Value','wrap',false);
                        return;
                    end
                else
                    %segments are defined b/t start and end events
                    if any(CFG.baselinewindow<0)
                        strMsg = ['\bfBaseline start and end times \color{red}MUST\color{black} be non-negative when\n',...
                                  'segments are defined realtive to start and end events.']; 
                        FT.UserInput(strMsg,0,'button','OK','title','Invalid Value','wrap',false);
                        return;
                    end
                end
            else
                if strcmpi(FT_DATA.history.segmentation.format,'timelock')
                    %baseline is given relative to trial start but segments are
                    %defined relative to an event
                    tEvt = FT_DATA.history.segmentation.pre/FT_DATA.data.fsample;
                    CFG.baselinewindow = CFG.baselinewindow - tEvt;
                end
                %times are given relative to trial start
                if any(CFG.baselinewindow<0)
                    strMsg = ['\bfBaseline start and end times \color{red}MUST\color{black} be non-negative when\n',...
                              'times are relative to trial start.']; 
                    FT.UserInput(strMsg,0,'button','OK','title','Invalid Value','wrap',false);
                    return;
                end
            end

            if ishandle(h)
                close(h);
            end
                        
        case 'skip'
            CFG = [];
            if ishandle(h)
                close(h);
            end
        otherwise
            %this should never happen
    end
end
%------------------------------------------------------------------------------%
function KeyPress(obj,evt)
%allow the figure to be closed via Crtl+W shortcut
   switch lower(evt.Key)
       case 'w'
           if ismember(evt.Modifier,'control')
               if ishandle(h)
                   close(h);
               end
           end
       otherwise
   end
end
%------------------------------------------------------------------------------%
end