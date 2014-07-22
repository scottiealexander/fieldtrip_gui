function Gui(varargin)

% FT.events.relabel.Gui
%
% Description: relabel events based on either user input or specified file
%
% Syntax: FT.events.relabel.Gui
%
% In: 
%
% Out: 
%
% SEE ALSO: FT.events.relabel.Run
%
% Updated: 2014-07-15
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

if ~FT.tools.Validate('relabel_events','done',{'read_events'},'todo',{'segment_trials'})
    return;
end

bRun = false;
strMap = '';

evt = FT.ReStruct(FT_DATA.event);

s.vals = unique(evt.value);

if isnumeric(evt.value)
    s.freq = arrayfun(@(x) sum(evt.value==x),s.vals);
else
    s.freq = arrayfun(@(x) sum(strcmpi(x,evt.value)),s.vals);
end

strCodeCur = FT.io.WriteStruct(s,'headers',{'code','# of occurances'},'delim',9);

strInst = ['#any line begining with a ''#'' is a comment' 10,...
           '#format: new_code = old_code' 10,...
           '#examples: ' 10,...
           '#   trial_start = 1' 10,...
           '#   stimulus_onset = [2,3,4]' 10,...
           '#   response = "S17"' 10,...
           '#   error = ["S9","S20","S30"]' 10];

%get the size and position for the figure
pFig = FT.tools.GetFigPosition(800,600);

%main figure
h = figure('Units','pixels','OuterPosition',pFig,...
           'Name','Recode Events','NumberTitle','off','MenuBar','none',...
           'KeyPressFcn',@FT.tools.KeyPress);

%--- current event codes --- %
hPanelCur = uipanel('Units','normalized','Position',[.63 .6 .35 .4],'HighlightColor',[0 0 0],...
    'Title','Current Event Codes','FontSize',12,'FontWeight','bold','Parent',h);

%show user current event codes
uicontrol('Style','edit','Units','normalized','Position',[.01 .01 .99 .99],...
            'String',strCodeCur,'Parent',hPanelCur,'BackgroundColor',[1 1 1],...
            'HorizontalAlignment','left','Max',2,'Min',0,'Enable','Inactive',...
            'FontSize',14);
        
% --- new event codes --- %
hPanelNew = uipanel('Units','normalized','Position',[.02 .02 .59 .98],...
    'HighlightColor',[0 0 0],'Title','New Event Codes','FontSize',12,'FontWeight','bold','Parent',h);

%edit box for new event codes
hEdit = uicontrol('Style','edit','Units','normalized','Position',[.01 .01 .99 .99],...
    'String',strInst,'Parent',hPanelNew,'BackgroundColor',[1 1 1],...
    'HorizontalAlignment','left','Max',2','Min',0,'FontSize',14);

% --- control buttons --- %
%load
uicontrol('Style','pushbutton','Units','normalized','Position',[.68 .26 .25 .1],...
    'String','Load New Codes From File','Callback',@LoadBtn,'Parent',h);

%write
uicontrol('Style','pushbutton','Units','normalized','Position',[.68 .14 .25 .1],...
    'String','Write New Codes To File','Callback',@WriteBtn,'Parent',h);

%submit
uicontrol('Style','pushbutton','Units','normalized','Position',[.68 .02 .25 .1],...
    'String','Submit','Callback',@SubmitBtn,'Parent',h);

% --- wait for user --- %
uicontrol(hEdit);
uiwait(h);

if bRun
    %parse the mapping and recode the events
    FT.events.relabel.Run(strMap);
end

%------------------------------------------------------------------------------%
function SubmitBtn(obj,evt)
%get the new event codes and terminate
    strMap = FT.tools.ReformatStr(get(hEdit,'String'));
    bRun = true;
    if ishandle(h)
        close(h);
    end
end
%------------------------------------------------------------------------------%
function LoadBtn(obj,evt)
%read event codes from file
    strDir = pwd;
    if isdir(FT_DATA.path.base_directory)
        cd(FT_DATA.path.base_directory);
    end
    [strName,strPath] = uigetfile({'*.txt;*.asc;*.cfg;*.evt','Event code files (*.txt *.asc *.cfg *.evt)'},...
                                   'Load Event Code File');
    cd(strDir);
    if ~isequal(strName,0) && ~isequal(strPath,0)
        strPathEvt = fullfile(strPath,strName);
        fid = fopen(strPathEvt,'r');
        if fid > 0
           str = reshape(cast(fread(fid,'char'),'char'),1,[]);
           set(hEdit,'String',str);
           fclose(fid);
        else
            %nothing to do
        end
    end    
end
%------------------------------------------------------------------------------%
function WriteBtn(obj,evt)
%write event codes to file
    strDir = pwd;
    cd(FT_DATA.path.base_directory);
    [strName,strPath] = uiputfile({'*.txt;*.asc;*.cfg;*.evt','Event code files (*.txt *.asc *.cfg *.evt)'},...
            'Load Event Code File',fullfile(FT_DATA.path.base_directory,'new_codes.evt'));
    cd(strDir);
    if ~isequal(strName,0) && ~isequal(strPath,0)
        strPathEvt = fullfile(strPath,strName);
        fid = fopen(strPathEvt,'w');
        if fid > 0
           str = FT.tools.ReformatStr(get(hEdit,'String'));           
           fprintf(fid,'%s\n',str);
           fclose(fid);
        else
            %nothing to do
        end
    end    
end
%------------------------------------------------------------------------------%
end

%{
prompt={'New Event Codes'};
name='Recode Events';
numlines=[20 50];
defaultanswer={['#any line begining with a ''#'' is a comment' 10 ...
    '#format: new_code = old_code' 10 ...
    '#examples: ' 10 ...
    '#   trial_start = 1' 10 ...
    '#   stimulus_onset = [2,3,4]' 10 ...
    '#   response = "S17"' 10 ...
    '#   error = ["S9","S20","S30"]' 10]};
resize='on';
answer=inputdlg(prompt,name,numlines,defaultanswer,resize);
%}
