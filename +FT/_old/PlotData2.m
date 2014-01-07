function PlotData2(varargin)

% FT.PlotData
%
% Description: plot data using ft_databrowser
%
% Syntax: FT.PlotData
%
% In: 
%
% Out: 
%
% Updated: 2013-08-20
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

%make sure we are ready to run
if ~FT.CheckStage('plot')
    return;
end

if ~iscell(FT_DATA.data) && ~isfield(FT_DATA.data,'trial')
    if isfield(FT_DATA.data,'avg')
        strMsg = ['\bf[\color{red}OOPS\color{black}]: Sorry, this data viewer does not work for averaged data.',...
                  'Try:\n\n                    View->Plot ERP\ninstead.'];
        FT.UserInput(strMsg,0,'title','Oops','button','OK');
        return;
    else
        strMsg = ['\bf[\color{red}ERROR\color{black}]: No data could be found to plot.\n',...
                  'Please load data before viewing.'];
        FT.UserInput(strMsg,0,'title','ERROR','button','OK');
        return;
    end
end

if iscell(FT_DATA.data)
    cfg.feedback = 'none';
    data = ft_appenddata(cfg,FT_DATA.data{:});
    if iscell(data.cfg.previous)
        data.cfg.previous = data.cfg.previous{1};
    end
    trl = cellfun(@(x) x.trl,FT_DATA.epoch,'uni',false);
    trl = cat(1,trl{:});
else
    data = FT_DATA.data;
    trl = FT_DATA.trialdef;
end

%set up configuration for 'ft_databrowser'
cfg 			= [];
if numel(data.trial) > 1
    cfg.continuous = 'no';
    cfg.trl = trl;    
else
    cfg.continuous  = 'yes';        
    cfg.blocksize	= 30;				%how long a time segment in seconds to show
end
cfg.channel		= data.label(1:9);	%channels (and number of channels) to display initially
cfg.viewmode	= 'vertical';
cfg.plotlabels  = 'yes';
cfg.ylim		= [-100 100];

%hide resampling so that fieldtrip will show us the events
% bEdit = false;
if FT_DATA.done.resample
    % bEdit = true;
    [origfs,data.cfg] = FT.EditCfg(data.cfg,'set','origfs',[]);    
end

%plot
ft_databrowser(cfg,data);

% if bEdit
    % FT.EditCfg('set','origfs',origfs);
% end

