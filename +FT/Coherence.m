function Coherence()

% Connectivity
%
% Description: 
%
% Syntax: Coherence
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

[fMin,fMax,smooth] = deal(NaN);
GetParameters;

[kChan,b] = listdlg('ListString',FT_DATA.data{1}.label,'Name','Choose Channels',...
                    'SelectionMode','multiple','ListSize',[180,300]);

if bRun && b
    cfg.channel    = FT_DATA.data{1}.label(kChan);
    cfg.channelcmb = PairElements(cfg.channel);
    cfg.trackcallinfo = false;
    
    hMsg = FT.UserInput('Calculating coherence...',1);

    freq = cellfun(@(x) ft_freqanalysis(cfg,x),FT_DATA.data,'uni',false);
    
    
    cfg2 = [];
    
    cfg2.method = 'coh';
    cfg2.channelcmb = cfg.channelcmb;
    cfg2.trackcallinfo = false;
    
    COH = cellfun(@(x) ft_connectivityanalysis(cfg2,x),freq,'uni',false);

    if ishandle(hMsg)
        close(hMsg);
    end
    
    hAX = NaN(numel(COH),1);
    kChan = 1;
    pMain = GetFigPosition(800,600);
    h = figure('Name','Coherence: ','Units','pixels','Position',pMain,'NumberTitle','off',...
               'MenuBar','none');
    PlotCoherence;
    set(h,'KeyPressFcn',@KeyPressCoh);

end

%------------------------------------------------------------------------------%
function PlotCoherence
    arrayfun(@RmAxes,hAX);
    set(h,'Name',['Coherence: ' FT.Join(COH{1}.labelcmb(kChan,:),' - ')]);

    x = cellfun(@(x) x.freq,COH,'uni',false);
    y = cellfun(@(x,y) x.cohspctrm(kChan,:),COH,'uni',false);
    cLegend = cellfun(@(x) x.name,FT_DATA.epoch,'uni',false);    

    t = FT.TSPlot(x(1),{y},...
        'title','Coherence',...
        'xlabel','Frequency [Hz]',...
        'ylabel','Coherence',...
        'legend',cLegend ,...
        'parent', h);
    hAX = t.hA;
    
    %     for k = 1:numel(COH)
    %        hAX(k,1) = subplot(1,numel(COH),k);
    %        strTitle = FT_DATA.epoch{k}.name;
    %        FT.TSPlot(COH{k}.freq,COH{k}.cohspctrm(kChan,:),...
    %            'title' , strTitle    ,...
    %            'xlabel', 'frequency' ,...
    %            'ylabel', 'coherence' ,...
    %            'parent', h           ,...
    %            'axes'  , hAX(k,1)     ...
    %            );
    %     end
end
%------------------------------------------------------------------------------%
function GetParameters
    
    FS = FT_DATA.data{1}.fsample;
    
    %get the size and position for the figure
    pFig = GetFigPosition(400,200);    

    %main figure
    h = figure('Units','pixels','OuterPosition',pFig,...
               'Name','Coherence','NumberTitle','off','MenuBar','none',...
               'KeyPressFcn',@KeyPress);

    bgColor = get(h,'Color');

    %edit box height
    hEdit = .22;
    lEdit = .55;
    bEdit = .7:-(hEdit+.1):.7-(hEdit+.1)*2;

    %freq range
    hFreq = uicontrol('Style','edit','Units','normalized','Position',[lEdit bEdit(1) .3 hEdit],...
        'String','1 100','BackgroundColor',[1 1 1],'Parent',h);
    uicontrol('Style','text','Units','normalized','Position',[.01 bEdit(1)-.04 .5 .25],...
        'String',['Frequency Range (Hz):' 10 '[min max] '],'FontSize',14,'BackgroundColor',bgColor,...
        'HorizontalAlignment','right','Parent',h);

    %smoothing
    hSmth = uicontrol('Style','edit','Units','normalized','Position',[lEdit bEdit(2) .1 hEdit],...
        'String','10','BackgroundColor',[1 1 1],'Parent',h);
    uicontrol('Style','text','Units','normalized','Position',[.01 bEdit(2)-.02 .5 .2],...
        'String','Smoothing [Hz]:','FontSize',14,'BackgroundColor',bgColor,...
        'HorizontalAlignment','right','Parent',h);

    %run and skip buttons
    wBtn = .2;
    lInit = .5-(wBtn*2+.05)/2;
    uicontrol('Style','pushbutton','Units','normalized','Position',[lInit .05 wBtn .2],...
        'String','Run','Callback',@BtnCtrl,'Parent',h);

    uicontrol('Style','pushbutton','Units','normalized','Position',[lInit+.25 .05 wBtn .2],...
        'String','Cancel','Callback',@BtnCtrl,'Parent',h);

    uicontrol(hFreq);

    uiwait(h);
    
    if bRun
        cfg.foilim     = [fMin fMax];
        cfg.tapsmofrq  = smooth;
        cfg.output     = 'powandcsd';
        cfg.method     = 'mtmfft';    
        cfg.keeptrials = 'yes';    
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
                
                strSmth = get(hSmth,'String');
                if isempty(strSmth)
                    strSmth = '10';
                end
                smooth = str2double(strSmth);
                
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
                 elseif isnan(smooth)
                    uicontrol(hSmth);
                    strMsg = ['\bf[\color{red}ERROR\color{black}]: invalid ',...
                        'smoothing value ''\color[rgb]{1 .08 .6}' strSmth ''''];
                    FT.UserInput(strMsg,0,'button','OK','title','Invalid Value','wrap',false);
                    set(hStep,'String','10')
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
function KeyPressCoh(obj,evt)
%allow the figure to be closed via Crtl+W shortcut
   switch lower(evt.Key)
       case 'w'
           if ismember(evt.Modifier,'control')
               if ishandle(h)
                   close(h);
               end
           end           
       case 'leftarrow'
           if kChan > 1
               kChan = kChan - 1;
           end
           PlotCoherence;
       case 'rightarrow'
           if kChan < size(COH{1}.labelcmb,1)
               kChan = kChan + 1;
           end
           PlotCoherence;
       otherwise
   end
end
%------------------------------------------------------------------------------%
function RmAxes(h)
    if ishandle(h)
        delete(h);
    end
end
%------------------------------------------------------------------------------%
end