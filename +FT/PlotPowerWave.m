function freq = PlotPowerWave(freq)

% FT.PlotPowerWave
%
% Description: 
%
% Syntax: FT.PlotPowerWave
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

if isempty(freq)
    freq = FT.PowerWave;
end

[kChan,b] = listdlg('ListString',FT_DATA.data{1}.label,'Name','Choose a Channel','SelectionMode','single');

PlotOne;

%------------------------------------------------------------------------------%
function PlotOne
    cD = cellfun(@(x) nanmean(x.powspctrm(kChan,:,:),3),freq,'uni',false);
    cE = cellfun(@(x) nanstderr(x.powspctrm(kChan,:,:),3),freq,'uni',false);    
    cT = repmat({freq{1}.time},size(cD));
    for k = 1:numel(cD)
       bUse = ~isnan(cD{k});
       cD{k} = cD{k}(bUse); 
       cE{k} = cE{k}(bUse); 
       cT{k} = cT{k}(bUse); 
    end
    cLabel = cellfun(@(x) x.name,FT_DATA.epoch,'uni',false);
    ts = FT.TSPlot(cT,cD,'error',cE,...
        'xlabel','time (sec)',...
        'ylabel','power',...
        'title','Average Power Wave',...
        'legend',cLabel ...
        );    
end
%------------------------------------------------------------------------------%
function x = nanstderr(x,dim)
    n = sum(~isnan(x),dim);
    x = nanstd(x,[],dim)./sqrt(n);
end
%------------------------------------------------------------------------------%
function ChannelCtrl
    pFig = GetFigPosition(230,500);
    h = figure('Units','pixels','OuterPosition',pFig,...
           'Name','Channel Selector','NumberTitle','off','MenuBar','none'...
           );
    hSel = uicontrol('Style','listbox','Units','normalized','Position',[0 .2 1 .8],...
        'String',FT_DATA.data{1}.label,'BackgroundColor',[1 1 1]);
end
%------------------------------------------------------------------------------%
end