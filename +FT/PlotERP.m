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
% Updated: 2013-12-13
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

if ~FT_DATA.done.average || ~isfield(FT_DATA.data{1},'avg')
    FT.UserInput(['\color{red}Average ERPs do not exist for this dataset!\n\color{black}'...
        'Please use:\n      \bfAnalysis->Average ERPs\rm\nbefore viewing ERPs.'],...
        0,'title','Averaging Not Done','button','OK');
    return
end

pFig = GetFigPosition(800,600);
hF = figure('Units','pixels','OuterPosition',pFig,...
            'Name','Average ERP','NumberTitle','off','MenuBar','none',...
            'Color',[1 1 1]);

FT.PlotCtrl(hF,FT_DATA.data{1}.label,@PlotOne);

%------------------------------------------------------------------------------%
function PlotOne(strChan)
    [cX,cY,cErr] = cellfun(@(x) GetData(x,strChan),FT_DATA.data,'uni',false);
    cLabel = cellfun(@(x) x.name,FT_DATA.epoch,'uni',false);
    
    FT.TSPlot(cX,cY,...
        'error',cErr,...
        'title',['Average ERP at ' strChan ],...
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