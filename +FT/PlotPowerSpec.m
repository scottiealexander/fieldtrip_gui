function PlotPowerSpec()

% FT.PlotPowerSpec
%
% Description: 
%
% Syntax: FT.PlotPowerSpec
%
% In: 
%
% Out: 
%
% Updated: 2014-03-20
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

cfg = CFGDefault;
cfg.method = 'mtmfft';
cfg.taper  = 'hanning';
cfg.output = 'pow';
cfg.foi = 1:1:100;
freq = ft_freqanalysis(cfg,FT_DATA.data);

pFig = GetFigPosition(800,600);
hF = figure('Units','pixels','OuterPosition',pFig,...
            'Name','Average ERP','NumberTitle','off','MenuBar','none',...
            'Color',[1 1 1]);

FT.PlotCtrl(hF,FT_DATA.data.label,@PlotOne);

%------------------------------------------------------------------------------%
function PlotOne(strChan)
	y = freq.powspctrm(strcmpi(strChan,freq.label),:);
    strChan = regexprep(strChan,'([_]*)','\\$1');
    FT.TSPlot(freq.freq,y,...        
        'title',['Power Spectrum: ' strChan ],...
        'xlabel','Frequency (Hz)',...
        'ylabel','Power (??)',...
        'parent',hF);
end
%------------------------------------------------------------------------------%
end