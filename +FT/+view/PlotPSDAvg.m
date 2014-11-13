function PlotPSDAvg()

% FT.PlotPDSAvg
%
% Description: plot PSD averaged across time bins and trials
%
% Syntax: FT.PlotPDSAvg
%
% In: 
%
% Out: 
%
% Updated: 2014-11-05
% Peter Horak

global FT_DATA;

%make sure we are ready to run
if ~FT.tools.Validate('plot_psd','done',{'tfd'})
    return;
end

pFig = FT.tools.GetFigPosition(800,600,'xoffset',100);
hF = figure('Units','pixels','OuterPosition',pFig,...
            'Name','Average PSD','NumberTitle','off','MenuBar','none',...
            'Color',[1 1 1]);

FT.view.PlotCtrl(hF,FT_DATA.data{1}.label,@PlotOne);
uiwait(hF);

%------------------------------------------------------------------------------%
function PlotOne(strChan)
    [cX,cY,cErr] = cellfun(@(x) GetData(x,strChan),FT_DATA.power.data,'uni',false);
    cLabel = cellfun(@(x) x.name,FT_DATA.epoch,'uni',false);
    strChan = regexprep(strChan,'([_]*)','\\$1');
    
    % log or linear frequency scale
    kTFD = find(strcmpi(cellfun(@(x) x.operation,FT_DATA.history,'uni',false),'tfd'),1,'last');
    fscale = FT.tools.Ternary(FT_DATA.history{kTFD}.params.log,'log','linear');

    FT.TSPlot(cX,cY,...
        'error',cErr,...
        'title',['Average PSD: ' strChan ],...
        'xlabel','Frequency (Hz)',...
        'ylabel','Power (arb)',...
        'zeros' , true,...
        'legend',cLabel,...
        'xscale',fscale,...
        'yscale','log',...
        'parent',hF);
end
%------------------------------------------------------------------------------%
function [x,y,err] = GetData(data,strChan)
    % freq x time x channel x trial matricies
    b   = strcmpi(strChan,FT_DATA.power.label);
    x   = FT_DATA.power.centers;
    data = permute(mean(data(:,:,b,:),2),[1,4,2,3]);
    y   = mean(data,2);
    err = std(data,[],2)/sqrt(size(data,2));
end
%------------------------------------------------------------------------------%
end
