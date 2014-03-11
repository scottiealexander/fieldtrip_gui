function PlotData(varargin)

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

%set up configuration for 'ft_databrowser'
cfg = CFGDefault;

if iscell(FT_DATA.data)
    if numel(FT_DATA.data) > 1
        data = ft_appenddata(cfg,FT_DATA.data{:});
    else
        data = FT_DATA.data{1};
    end
    if iscell(data.cfg.previous)
        data.cfg.previous = data.cfg.previous{1};
    end
    trl = cellfun(@(x) x.trl,FT_DATA.epoch,'uni',false);
    
    cfg.trl = cat(1,trl{:});
    cfg.continuous = 'no';    
else
    data = FT_DATA.data;
    cfg.continuous  = 'yes';        
    cfg.blocksize   = 30; 
end

cfg.channel     = data.label(1:9);  %channels (and number of channels) to display initially
cfg.viewmode    = 'vertical';
cfg.plotlabels  = 'yes';
cfg.ylim        = [-100 100];

%hide resampling so that fieldtrip will show us the events
if FT_DATA.done.resample    
    [origfs,data.cfg] = FT.EditCfg(data.cfg,'set','origfs',[]);    
end

%plot
ft_databrowser(cfg,data);