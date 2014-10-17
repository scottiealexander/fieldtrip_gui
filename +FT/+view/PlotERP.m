function PlotERP(varargin)

% FT.PlotERP
%
% Description: 
%
% Syntax: FT.PlotERP
%
% In: 
%
% Out: 
%
% Updated: 2014-10-06
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

%make sure we are ready to run
if ~FT.tools.Validate('plot_avg','done',{'average'})
    return;
end

pFig = FT.tools.GetFigPosition(800,600,'xoffset',100);
hF = figure('Units','pixels','OuterPosition',pFig,...
            'Name','Average ERP','NumberTitle','off','MenuBar','none',...
            'Color',[1 1 1]);

FT.view.PlotCtrl(hF,FT_DATA.data{1}.label,@PlotOne);
uiwait(hF);

%------------------------------------------------------------------------------%
function PlotOne(strChan)
    [cX,cY,cErr] = cellfun(@(x) GetData(x,strChan),FT_DATA.data,'uni',false);
    cLabel = cellfun(@(x) x.name,FT_DATA.epoch,'uni',false);
    strChan = regexprep(strChan,'([_]*)','\\$1');
    FT.TSPlot(cX,cY,...
        'error',cErr,...
        'title',['Average ERP: ' strChan ],...
        'xlabel','time (sec)',...
        'ylabel','Amplitude (\muV)',...
        'zeros' , true,...
        'legend',cLabel,...        
        'parent',hF);
end
%------------------------------------------------------------------------------%
function [x,y,err] = GetData(data,strChan)
    b   = strcmpi(strChan,data.label);
    x   = data.time;
    y   = data.avg(b,:);
    err = data.err(b,:);
end
%------------------------------------------------------------------------------%
end