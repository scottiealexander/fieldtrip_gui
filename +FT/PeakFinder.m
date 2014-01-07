function PeakFinder()

% FT.PeakFinder
%
% Description: 
%
% Syntax: FT.PeakFinder
%
% In: 
%
% Out: 
%
% Updated: 2013-09-05
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com
dbstop if error
global FT_DATA;

%make sure we have data...
if ~FT.CheckStage('peak_finder')
    return;
end

%make sure segmentation has been done
if ~FT_DATA.done.segmentation
    FT.UserInput(['\color{red}This dataset has not been segmented!\n\color{black}'...
        'Please use:\n      \bfSegmentation->Segment Trials\rm\nbefore finding peaks and valleys.'],...
        0,'title','Segmentation Not Yet Performed','button','OK');
    return;
end

%initialize the important variables
WINDOW = [NaN NaN];
STAT = struct;
FS = FT_DATA.data{1}.fsample;
tEvt = 0;

%get the size and position for the figure
pFig = GetFigPosition(400,300);

%main figure
h = figure('Units','pixels','OuterPosition',pFig,...
           'Name','Peak & Valley Finder','NumberTitle','off','MenuBar','none',...
           'KeyPressFcn',@KeyPress);

bgColor = get(h,'Color');

%edit box height
hEdit = .15;

%window start
hStrt = uicontrol('Style','edit','Units','normalized','Position',[.55 .8 .3 hEdit],...
    'String','','BackgroundColor',[1 1 1],'Parent',h);
uicontrol('Style','text','Units','normalized','Position',[.1 .8 .4 .15],...
    'String',['Window Start:' 10 '(in seconds)'],'FontSize',14,'BackgroundColor',bgColor,...
    'HorizontalAlignment','center','Parent',h);

%window end
hEnd = uicontrol('Style','edit','Units','normalized','Position',[.55 .57 .3 hEdit],...
    'String','','BackgroundColor',[1 1 1],'Parent',h);
uicontrol('Style','text','Units','normalized','Position',[.1 .57 .4 .15],...
    'String',['Window End:' 10 '(in seconds)'],'FontSize',14,'BackgroundColor',bgColor,...
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
    'String','Cancel','Callback',@BtnCtrl,'Parent',h);

uicontrol(hStrt);

uiwait(h);

if ~any(isnan(WINDOW))
    resp = FT.UserInput('\bfWould you like the output to be:\n1 file per-condition or\n1 file per-statistic?',...
                        1,'button',{'Condition','Statistic'},'title','Output Format');
    if isempty(resp)
        return;
    else
        bSingle = strcmpi(resp,'condition');
    end
    
    FT.UserInput('Please select an output directory.',1,'button','OK');
    strDirOut = fileparts(FT_DATA.path.dataset);
    strDirOut = uigetdir(strDirOut,'Select Output Directory');
    
    if isequal(strDirOut,0)
        return;
    end
    
    for k = 1:numel(FT_DATA.data)
        % --- OUTPUT PATH --- %
        if bSingle
            strPathOut = fullfile(strDirOut,[FT_DATA.current_dataset '-' FT_DATA.epoch{k}.name '-peak_stats.csv']);

            %add channel labels
            STAT.channel = FT_DATA.data{k}.label;
        else
           %add channel label
           STAT.peak_amplitude.channel   = FT_DATA.data{k}.label;
           STAT.peak_latency.channel     = FT_DATA.data{k}.label;
           STAT.valley_amplitude.channel = FT_DATA.data{k}.label;
           STAT.valley_latency.channel   = FT_DATA.data{k}.label;
        end

        hMsg = FT.UserInput('Finding peaks & valleys...',1);        
    
    
        %is this averaged data?
        if isfield(FT_DATA.data{k},'trial')
            cellfun(@(x,y) FindPeak(x,y),FT_DATA.data{k}.trial,num2cell(1:numel(FT_DATA.data{k}.trial)));
        elseif isfield(FT_DATA.data{k},'avg')
            FindPeak(FT_DATA.data{k}.avg,1);
        else
            error('could not find data. make sure data has been loaded before proceeding');
        end

        %write the data
        if bSingle
            %single file
            fprintf('[INFO]: Writing file: %s\n',strPathOut);
            if ~FT.WriteStruct(STAT,'output',strPathOut)
                me = MException('WriteStruct:WriteError',['Failed to write file ' strPathOut]);
                FT.ProcessError(me);
            end
        else
            %multiple files
            cPathOut = cellfun(@(x) fullfile(strDirOut,[x '-' FT_DATA.epoch{1}.name '-' FT_DATA.current_dataset '.csv']),fieldnames(STAT),'uni',false);
            fprintf('[INFO]: Writing files:\n%s\n',FT.Join(cPathOut,10));
            b = cellfun(@(x,y) FT.WriteStruct(STAT.(x),'output',y),fieldnames(STAT),cPathOut);
            if ~all(b)
                me = MException('WriteStruct:WriteError',['Failed to write file(s) :' 10 FT.Join(cPathOut(~b),10)]);
                FT.ProcessError(me);
            end
        end
    end
    if ishandle(hMsg)
        close(hMsg);
    end
end

%------------------------------------------------------------------------------%
function FindPeak(data,kTrial)
    
    strTrial = num2str(kTrial);
    
    [mx_amp,mx_lat] = max(data(:,WINDOW(1):WINDOW(2)),[],2);
    [mn_amp,mn_lat] = min(data(:,WINDOW(1):WINDOW(2)),[],2);
    
    %NOTE: latencies are converted to seconds relative to the time locking event
    %so tEvt is the latency of the timelocking event relative to the
    %start of the trial. if segments are defined relative to trial start then
    %tEvt is 0 and samples are just converted to seconds
    if bSingle
        STAT.(['max_amp_' strTrial ]) = reshape(mx_amp,[],1);
        STAT.(['max_lat_' strTrial ]) = (reshape(mx_lat,[],1) + WINDOW(1)-1)/FS - tEvt;
        STAT.(['min_amp_' strTrial ]) = reshape(mn_amp,[],1);
        STAT.(['min_lat_' strTrial ]) = (reshape(mn_lat,[],1) + WINDOW(1)-1)/FS - tEvt;
    else
        STAT.peak_amplitude.(['trial_' strTrial]) = reshape(mx_amp,[],1);
        STAT.peak_latency.(['trial_' strTrial]) = (reshape(mx_lat,[],1) + WINDOW(1)-1)/FS - tEvt;
        STAT.valley_amplitude.(['trial_' strTrial]) = reshape(mn_amp,[],1);
        STAT.valley_latency.(['trial_' strTrial]) = (reshape(mn_lat,[],1) + WINDOW(1)-1)/FS - tEvt;
    end
end
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
                    strStart '\color{black}''\ngiven for ''Window Start'''];
                FT.UserInput(strMsg,0,'button','OK','title','Invalid Value','wrap',false);
                return;
            elseif isnan(tEnd)
                uicontrol(hEnd);
                strMsg = ['\bf[\color{red}ERROR\color{black}]: invalid value ''\color[rgb]{1 .08 .6}',...
                    strEnd '\color{black}''\ngiven for ''Window End'''];
                FT.UserInput(strMsg,0,'button','OK','title','Invalid Value','wrap',false);
                return;
            else                            
                WINDOW = [tStart tEnd];
            end
            
            %are time relative to trial start or the timelocking event?
            if strcmpi(get(get(hBtn,'SelectedObject'),'String'),'event')
                if strcmpi(FT_DATA.history.segmentation.format,'timelock')
                    %segments are defined relateive to a timelocking event
                    tEvt = FT_DATA.history.segmentation.pre;
                    WINDOW = WINDOW + tEvt;
                    if any(WINDOW<0)
                        strMsg = ['\bf[\color{red}ERROR\color{black}]: The window start and/or end times that you\n',...
                                  'entered fall outside the time range of the trials.\n\nPlease check your input and try again.']; 
                        FT.UserInput(strMsg,0,'button','OK','title','Invalid Value','wrap',false);
                        return;
                    end
                else
                    %segments are defined b/t start and end events
                    if any(WINDOW<0)
                        strMsg = ['\bfWindow start and end times \color{red}MUST\color{black} be non-negative when\n',...
                                  'segments are defined realtive to start and end events.']; 
                        FT.UserInput(strMsg,0,'button','OK','title','Invalid Value','wrap',false);
                        return;
                    end
                end
            else
                %times are given relative to trial start
                if any(WINDOW<0)
                    strMsg = ['\bfWindow start and end times \color{red}MUST\color{black} be non-negative when\n',...
                              'times are relative to trial start.']; 
                    FT.UserInput(strMsg,0,'button','OK','title','Invalid Value','wrap',false);
                    return;
                end
            end                                    
            
            %translate time to samples (+1 as samples are indexed from 1, time is
            %indexed from 0)
            WINDOW = round(WINDOW*FS)+1;            
            
            if ishandle(h)
                close(h);
            end
                        
        case 'cancel'
            WINDOW = [NaN,NaN];
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