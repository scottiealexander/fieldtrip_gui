function [cfg,base] = GetFreqParameters()

% GetFreqParameters
%
% Description: 
%
% Syntax: GetFreqParameters
%
% In: 
%
% Out: 
%
% Updated: 2013-10-25
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

cfg = struct;
base = [];

[fMin,fMax,tStep,width] = deal([]);
bRun = false;
FS = FT_DATA.data{1}.fsample;

def = struct('t_step','.01','width','5');

%get the size and position for the figure
pFig = GetFigPosition(500,400);    

%main figure
h = figure('Units','pixels','OuterPosition',pFig,...
           'Name','Frequency Parameters','NumberTitle','off','MenuBar','none',...
           'KeyPressFcn',@KeyPress);

bgColor = get(h,'Color');

%edit box height
hEdit = .13;
lEdit = .55;
bEdit = .8:-(hEdit+.05):.8-(hEdit+.05)*3;

%freq range
hFreq = uicontrol('Style','edit','Units','normalized','Position',[lEdit bEdit(1) .3 hEdit],...
    'String','1 100','BackgroundColor',[1 1 1],'Parent',h);
uicontrol('Style','text','Units','normalized','Position',[.01 bEdit(1)-.06 .5 .16],...
    'String',['Frequency Range (Hz):' 10 '[min max] '],'FontSize',14,'BackgroundColor',bgColor,...
    'HorizontalAlignment','right','Parent',h);

%baseline
hBase = uicontrol('Style','edit','Units','normalized','Position',[lEdit bEdit(2) .3 hEdit],...
    'String','','BackgroundColor',[1 1 1],'Parent',h);
uicontrol('Style','text','Units','normalized','Position',[.01 bEdit(2)-.06 .5 .16],...
    'String',['Baseline (sec):' 10 '[min max]'],'FontSize',14,'BackgroundColor',bgColor,...
    'HorizontalAlignment','right','Parent',h);

%time step
hStep = uicontrol('Style','edit','Units','normalized','Position',[lEdit bEdit(3) .3 hEdit],...
    'String',def.t_step,'BackgroundColor',[1 1 1],'Parent',h);
uicontrol('Style','text','Units','normalized','Position',[.01 bEdit(3)-.06 .5 .15],...
    'String','Timestep (sec):','FontSize',14,'BackgroundColor',bgColor,...
    'HorizontalAlignment','right','Parent',h);

%width
hWidth = uicontrol('Style','edit','Units','normalized','Position',[lEdit bEdit(4) .3 hEdit],...
    'String',def.width,'BackgroundColor',[1 1 1],'Parent',h);
uicontrol('Style','text','Units','normalized','Position',[.01 bEdit(4)-.06 .5 .15],...
    'String',['Wavelet width:' 10 ' (# of cycles) '],'FontSize',14,'BackgroundColor',bgColor,...
    'HorizontalAlignment','right','Parent',h);

%run and skip buttons
wBtn = .2;
lInit = .5-(wBtn*2+.05)/2;
uicontrol('Style','pushbutton','Units','normalized','Position',[lInit .05 wBtn .12],...
    'String','Run','Callback',@BtnCtrl,'Parent',h);

uicontrol('Style','pushbutton','Units','normalized','Position',[lInit+.25 .05 wBtn .12],...
    'String','Cancel','Callback',@BtnCtrl,'Parent',h);

uicontrol(hFreq);

uiwait(h);

if bRun
    cfg.channel       = 'all';
    cfg.method        = 'wavelet';
    cfg.output        = 'pow';        
    cfg.foi           = fMin:1:fMax;
    cfg.toi           = min(FT_DATA.data{1}.time{1}):tStep:max(FT_DATA.data{1}.time{1});
    cfg.width         = width;
    cfg.trackcallinfo = 'off'; %prevent status messages
    cfg.feedback      = 'no';
    base              = [bMin bMax];
end    

%--------------------------------------------------------------------------%
function BtnCtrl(obj,evt)
    switch lower(get(obj,'String'))
        case 'run'
            strRange = get(hFreq,'String');
            if isempty(strRange)
                strRange = '1 100';
            end
            re = regexp(strRange,'[^\d\.]*(?<min>\d*\.?\d*)[\s:\-\+_]+(?<max>\d*\.?\d*)[^\d\.]*','names');
            if isempty(re) || isempty(re.min) || isempty(re.max)
                [fMin,fMax] = deal(NaN);
            else
                fMin = str2double(re.min);
                fMax = str2double(re.max);
            end
            
            strBase = get(hBase,'String');
            re = regexp(strBase,'[^\d\.\-]*(?<min>\-?\d*\.?\d*)[\s:_]+(?<max>\-?\d*\.?\d*)[^\d\.]*','names');
            if isempty(re) || isempty(re.min) || isempty(re.max)
                [bMin,bMax] = deal(NaN);
            else
                bMin = str2double(re.min);
                bMax = str2double(re.max);
            end

            strStep = get(hStep,'String');
            if isempty(strStep)
                strStep = def.t_step;
            end
            tStep = str2double(strStep);

            strWidth = get(hWidth,'String');
            if isempty(strWidth)
                strWidth = def.width;
            end
            width = str2double(strWidth);

            if isnan(fMin) || isnan(fMax)
                uicontrol(hFreq);
                strMsg = ['\bf[\color{red}ERROR\color{black}]: invalid ',...
                    'frequency range: ''\color[rgb]{1 .08 .6}' strRange '\color{black}''.'];
                FT.UserInput(strMsg,0,'button','OK','title','Invalid Value','wrap',false);
                return;
            elseif fMax > FS/2
                uicontrol(hFreq);
                strMsg = ['\bf[\color{red}ERROR\color{black}]: ' num2str(fMax),...
                    'Hz is beyond the frequency range\nfor which spectra can be calculated.',...
                    'For this\ndataset the maximum frequency is ' num2str(FT_DATA.data.fsample/2) 'Hz.'];
                FT.UserInput(strMsg,0,'button','OK','title','Invalid Value','wrap',false);
                return;
            elseif fMin < 1
                uicontrol(hFreq);
                strMsg = ['\bf[\color{red}ERROR\color{black}]: spectrograms ',...
                    'cannot be calculated\nfor frequencies less than 1Hz when using wavelets.'];
                FT.UserInput(strMsg,0,'button','OK','title','Invalid Value','wrap',false);
                return;
            elseif fMin >= fMax
                uicontrol(hFreq);
                strMsg = ['\bf[\color{red}ERROR\color{black}]: invalid ',...
                    'frequency range: ''\color[rgb]{1 .08 .6}' strRange ''...
                    '\color{black}''\nmaximum frequency must be greater than minimum.'];
                FT.UserInput(strMsg,0,'button','OK','title','Invalid Value','wrap',false);
                return;
            elseif isnan(bMin) || isnan(bMax)
                uicontrol(hBase);
                strMsg = ['\bf[\color{red}ERROR\color{black}]: invalid ',...
                    'baseline range: ''\color[rgb]{1 .08 .6}' strBase '\color{black}''.'];
                FT.UserInput(strMsg,0,'button','OK','title','Invalid Value','wrap',false);
                return;
            elseif bMin < min(FT_DATA.data{1}.time{1}) || bMax > max(FT_DATA.data{1}.time{1})
                uicontrol(hBase);
                strMsg = ['\bf[\color{red}ERROR\color{black}]: invalid ',...
                    'baseline range: ''\color[rgb]{1 .08 .6}' strBase '\color{black}''.'];
                FT.UserInput(strMsg,0,'button','OK','title','Invalid Value','wrap',false);
                return;
            elseif isnan(tStep)
                uicontrol(hStep);
                strMsg = ['\bf[\color{red}ERROR\color{black}]: invalid ',...
                    'time step ''\color[rgb]{1 .08 .6}' strStep ''''];
                FT.UserInput(strMsg,0,'button','OK','title','Invalid Value','wrap',false);
                set(hStep,'String',def.t_step)
                return;
            elseif isnan(width)
                uicontrol(hWidth);
                strMsg = ['\bf[\color{red}ERROR\color{black}]: invalid ',...
                    'width given ''\color[rgb]{1 .08 .6}' strWidth ''''];
                FT.UserInput(strMsg,0,'button','OK','title','Invalid Value','wrap',false);
                set(hWidth,'String',def.width)
                return;
            end

            if ishandle(h)
                close(h);
            end
            bRun = true;

        case 'cancel'
            bRun = false;
            if ishandle(h)
                close(h);
            end
        otherwise
            %this should never happen
    end
end
%--------------------------------------------------------------------------%
end
%------------------------------------------------------------------------------%