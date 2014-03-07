function RemoveChannels(varargin)

% FT.RemoveChannels
%
% Description: remove bad channels based on visual inspection
%
% Syntax: FT.RemoveChannels
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
if ~FT.CheckStage('rm_channel')
    return;
end

%set up configuration for 'ft_rm_channels'
cfg             = CFGDefault;
cfg.continuous  = 'yes';
cfg.channel		= FT_DATA.data.label(1:9);	%channels (and number of channels) to display initially
cfg.ylim		= [-100 100];
cfg.blocksize	= 30;				%how long a time segment in seconds to show
cfg.viewmode	= 'vertical';
cfg.plotlabels  = 'yes';

res = ft_rm_channels(cfg,FT_DATA.data);

%find the indicies of the bad channels
if isfield(res,'rm_channel') && ~isempty(res.rm_channel)
    [~,kRm] = ismember(res.rm_channel,FT_DATA.data.label);
    
    %allow user to re-consider their selection
    strAns = FT.UserInput(['\bfThe following channels will be removed:\n\rm' FT.Join(res.rm_channel,[44 32])],1,'button',{'Continue','Cancel'});
    if strcmpi(strAns,'cancel')
        %user selected cancel, so just abort
        return;
    end

    %remove 'em
    orig_label = FT_DATA.data.label;
    cfg = [];
    cfg.channel  = setdiff(1:numel(orig_label),kRm);

    FT_DATA.data = ft_preprocessing(cfg, FT_DATA.data);
    
    %update history (so it shows what we actually removed)
    cfg.channel = orig_label(kRm);
    FT_DATA.history.rm_channel = cfg;
    FT_DATA.done.rm_channel = true;
    
    %mark data as not saved
    FT_DATA.saved = false;
    
    FT.UpdateGUI;
else
   %user selected cancel 
end