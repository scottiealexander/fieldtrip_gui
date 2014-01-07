function freq = PowerWave(varargin)

% FT.PowerWave
%
% Description: 
%
% Syntax: FT.PowerWave
%
% In: 
%
% Out: 
%
% Updated: 2013-11-25
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

opt = FT.ParseOpts(varargin,...
    'freq' , [] ...
    );

if isempty(opt.freq)
    [cfg,base] = GetFreqParameters;

    cfg2.baseline      = base;
    cfg2.baselinetype  = 'relchange';
    cfg2.trackcallinfo = 'off';
    cfg2.feedback      = 'no';

    hWait = waitbar(0,'0% done','Name','Calculating power wave');
    nProc = sum(cellfun(@(x) numel(x.trial),FT_DATA.data));
    nDone = 0;

    freq = cellfun(@TrialSpectrogram,FT_DATA.data,'uni',false);

    if ishandle(hWait)
        close(hWait);
    end
else
    freq = opt.freq;
    clear('opt');
end

cLabel = FT_DATA.data{1}.label;

% pMain = GetFigPosition(800,600);
% h     = figure('Name','Power wave','Units','pixels','Position',pMain,...
%                'NumberTitle','off','MenuBar','none','Color',[1 1 1]);
% PlotOne(cLabel{1});

FT.PlotCtrl([],cLabel,@PlotOne);
           
%------------------------------------------------------------------------------%
function PlotOne(strChan)
    bChan   = strcmpi(strChan,cLabel);   
    cT      = cellfun(@(x) x.time(4:end-5),freq,'uni',false);
    cD      = cellfun(@(x) nanmean(x.powspctrm(bChan,4:end-5,:),3),freq,'uni',false);
    cE      = cellfun(@(x) nanstderr(x.powspctrm(bChan,4:end-5,:),3),freq,'uni',false);
    cLegend = cellfun(@(x) x.name,FT_DATA.epoch,'uni',false);
    
    FT.TSPlot(cT,cD,...
        'error'  , cE          ,...
        'title'  , strChan     ,...
        'xlabel' , 'time (sec)',...
        'ylabel' , 'Power'     ,...
        'zeros'  , true        ,...
        'legend' , cLegend     ,...
        'parent' , h            ...
        );    
end
%------------------------------------------------------------------------------%
function freq = TrialSpectrogram(data)
    freq.powspctrm = NaN(numel(data.label),numel(cfg.toi),numel(data.trial));
    freq.time = [];
    for kT = 1:numel(data.trial)
        d = data;
        d.sampleinfo = data.sampleinfo(kT,:);
        d.time = data.time(kT);
        d.trial = data.trial(kT);
        tmp = ft_freqbaseline(cfg2,ft_freqanalysis(cfg,d));
        
        %nchan X time_pt matrix of average power values
        freq.powspctrm(:,:,kT) = squeeze(nanmean(tmp.powspctrm,2));
                
        if isempty(freq.time)
            freq.time = tmp.time;
        end
        nDone = nDone+1;
        waitbar(nDone/nProc,hWait,[num2str(round((nDone/nProc)*100)) '% done']);
    end
end
%------------------------------------------------------------------------------%
end