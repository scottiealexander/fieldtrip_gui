function PowerSpec()

% FT.PowerSpec
%
% Description: 
%
% Syntax: FT.PowerSpec
%
% In: 
%
% Out: 
%
% Updated: 2013-09-07
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

dbstop if error
global FT_DATA;

%make sure we have data...
if ~FT.CheckStage('power_spec')
    return;
end

%make sure segmentation has been done
if ~FT_DATA.done.segmentation
    FT.UserInput(['\color{red}This dataset has not been segmented!\n\color{black}'...
        'Please use:\n      \bfSegmentation->Segment Trials\rm\nbefore computing power spectra.'],...
        0,'title','Segmentation Not Yet Performed','button','OK');
    return;
end

FS = FT_DATA.data{1}.fsample;
FOILIM = {};
POWER = cell(numel(FT_DATA.data),1);

%get the size and position for the figure
pFig = GetFigPosition(400,325);

%main figure
h = figure('Units','pixels','OuterPosition',pFig,...
           'Name','Power Spectrum','NumberTitle','off','MenuBar','none',...
           'KeyPressFcn',@KeyPress);

bgColor = get(h,'Color');

strInst = ['Please specify the starting and ending frequency steps over which you would like to ',...
	'average the power spectra.'];
uicontrol('Style','text','Units','normalized','Position',[.05 .65 .9 .3],...
    'String',strInst,'FontSize',14,'FontWeight','bold','BackgroundColor',bgColor,...
    'HorizontalAlignment','left','Parent',h);

%edit box height
hEdit = .15;

%window start
hStrt = uicontrol('Style','edit','Units','normalized','Position',[.55 .5 .3 hEdit],...
    'String','','BackgroundColor',[1 1 1],'Parent',h);
uicontrol('Style','text','Units','normalized','Position',[.05 .46 .5 .15],...
    'String','Starting Frequencies [Hz]:','FontSize',14,'BackgroundColor',bgColor,...
    'HorizontalAlignment','center','Parent',h);

%window end
hEnd = uicontrol('Style','edit','Units','normalized','Position',[.55 .3 .3 hEdit],...
    'String','','BackgroundColor',[1 1 1],'Parent',h);
uicontrol('Style','text','Units','normalized','Position',[.05 .26 .5 .15],...
    'String','Ending Frequencies [Hz]:','FontSize',14,'BackgroundColor',bgColor,...
    'HorizontalAlignment','center','Parent',h);

%run and skip buttons
wBtn = .2;
lInit = .5-(wBtn*2+.05)/2;
uicontrol('Style','pushbutton','Units','normalized','Position',[lInit .05 wBtn .12],...
    'String','Run','Callback',@BtnCtrl,'Parent',h);

uicontrol('Style','pushbutton','Units','normalized','Position',[lInit+.25 .05 wBtn .12],...
    'String','Cancel','Callback',@BtnCtrl,'Parent',h);

uicontrol(hStrt);

uiwait(h);

if isempty(FOILIM) || any(cellfun(@(x) any(isnan(x)),FOILIM))
	return;
end

% %get output path
% strPathOut = fullfile(fileparts(FT_DATA.path.dataset),[FT_DATA.current_dataset '-power_spec.csv']);
% [strName,strDir] = uiputfile({'*.csv','Comma/Tab Seperated Spreadsheet (*.csv)'},'Select Output Path',strPathOut);

hMsg = FT.UserInput('Caclulating power spectra',1);

%caclulate power spectra
cfg = [];
cfg.method = 'mtmfft';
cfg.taper  = 'hanning';
cfg.output = 'pow';

for k = 1:numel(FT_DATA.data)
    POWER{k,1} = cell(numel(FOILIM),1);
    for kL = 1:numel(FOILIM)
        cfg.foilim = FOILIM{kL};
        freq = ft_freqanalysis(cfg,FT_DATA.data{k});

        sTmp.label = ['power [' num2str(FOILIM{kL}(1)) '-' num2str(FOILIM{kL}(2)) 'Hz]'];

        %average across all frequency bins
        sTmp.data  = mean(freq.powspctrm,2);

        POWER{k,1}{kL,1} = sTmp;
    end
end

if ishandle(hMsg)
    close(hMsg);
end

FT.UserInput('Please select an output directory',1,'button','OK');
strDirOut = uigetdir(fileparts(FT_DATA.path.dataset),'Select Output Directory');
if isequal(strDirOut,0)
    return;
end

hMsg = FT.UserInput('Writing stats to file',1);
for kC = 1:numel(POWER)
    strPathOut = fullfile(strDirOut,[FT_DATA.current_dataset '-' FT_DATA.epoch{kC}.name '-power_spec.csv']);

    cLabel = cell(numel(POWER{kC}),1);
    s = struct;
    s.field1 = FT_DATA.data{kC}.label;
    cLabel{1,1} = 'channel';

    for k = 1:numel(POWER{kC})
        s.(['field' num2str(k+1)]) = reshape(POWER{kC}{k}.data,[],1);
        cLabel{k+1,1} = POWER{kC}{k}.label;
    end
    
    strAction = 'overwrite';
    if exist(strPathOut,'file')==2
        strAction = FT.UserInput('\bfOutput file already exists, what would you like to do?',...
            1,'button',{'Overwrite','Append','Cancel'},'title','Output Exists');       
    end
    
    switch lower(strAction)
        case 'append'
            b = CSVAppend(strPathOut,s,'headers',cLabel);                
        case 'overwrite'
        	b = FT.WriteStruct(s,'output',strPathOut,'headers',cLabel);
        otherwise
            b = true;
    end
    if ~b
        me = MException('WriteStruct:WriteError',['Failed to write file ' strPathOut]);
        FT.ProcessError(me);
    end
end
if ishandle(hMsg)
    close(hMsg);
end
                
%------------------------------------------------------------------------------%
function BtnCtrl(obj,evt)
    switch lower(get(obj,'String'))
        case 'run'
            strMin = get(hStrt,'String');
            if isempty(strMin)
                strMin = '""';
            end
            strMax = get(hEnd,'String');
            if isempty(strMax)
                strMax = '""';
            end
            
            cMin = regexp(strMin,'\W+','split');
            cMax = regexp(strMax,'\W+','split');
            
            if numel(cMax) ~= numel(cMin)
                RaiseError('Number of minimum and maximum frequencies do not match');
                uicontrol(hStrt);
                return;
            end
            
            for kF = 1:numel(cMin)
            
                fMin = str2double(cMin{kF});
                fMax = str2double(cMax{kF});
                
                bErr = true;
                if isnan(fMin) || fMin < 0
                    uicontrol(hStrt);
                    RaiseError(['invalid value ''\color[rgb]{1 .08 .6}',...
                        strMin '\color{black}''\ngiven for ''Minimum Frequency''']);
                elseif isnan(fMax)
                    uicontrol(hEnd);
                    RaiseError(['invalid value ''\color[rgb]{1 .08 .6}',...
                        strMax '\color{black}''\ngiven for ''Maximum Frequency''']);
                elseif fMax > FS/2
                    uicontrol(hEnd);
                    RaiseError([ strMax 'Hz is beyond the frequency range\nfor which spectra can be calculated. ',...
                        'For this\ndataset the maximum frequency is ' num2str(FT_DATA.data.fsample/2) 'Hz.']);                    
                else
                    bErr = false;                    
                    FOILIM{kF,1} = [fMin fMax];
                end 
                if bErr
                    FOILIM = {};
                    return;
                end
            end
            
            if ishandle(h)
                close(h);
            end
                        
        case 'cancel'
            if ishandle(h)
                close(h);
            end
        otherwise
            %this should never happen
    end
end
%------------------------------------------------------------------------------%
function RaiseError(strMsg)
    strMsg = ['\bf[\color{red}ERROR\color{black}]: ' strMsg];
    FT.UserInput(strMsg,0,'button','OK','title','Invalid Value','wrap',false);
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