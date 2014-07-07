function RejectTrials(varargin)

% FT.RejectTrials
%
% Description: 
%
% Syntax: FT.RejectTrials
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

if ~FT_DATA.done.segmentation
    FT.UserInput(['\color{red}This dataset has not been segmented!\n\color{black}'...
        'Please use:\n      \bfSegmentation->Segment Trials\rm\nbefore checking for artefacts.'],...
        0,'title','Segmentation Not Yet Performed','button','OK');
    return;
end

strMsg = ['\bfHow would you like to view the data?\rm\n\n     ',...
    '\bfVertical\rm:   browse channels for each trial aranged vertically\n     ',...
    '\bfSegment\rm: vew all channels for each trial arranged in small sub-plots'];
btn = FT.UserInput(strMsg,1,...
    'button',{'Vertical','Segment','Cancel'},'title','Select View Mode');

cfg = CFGDefault;
cfg.feedback = 'none';
if iscell(FT_DATA.data) && numel(FT_DATA.data) > 1
    data = ft_appenddata(cfg,FT_DATA.data{:});
elseif iscell(FT_DATA.data)
    data = FT_DATA.data{1};
else
    data = FT_DATA.data;    
end
if iscell(data.cfg.previous)
    data.cfg.previous = data.cfg.previous{1};
end
trl = cellfun(@(x) x.trl,FT_DATA.epoch,'uni',false);
trl = cat(1,trl{:});

switch lower(btn)
    
    case 'vertical'
        %prepare cfg struct
        cfg.continuous  = 'no';
        cfg.trl         = trl;
        cfg.channel		= FT_DATA.data{1}.label(1:min(9,numel(FT_DATA.data{1}.label)));
        cfg.viewmode	= 'vertical';
        cfg.plotlabels  = 'yes';
        cfg.ylim		= [-100 100];

        %hide resampling so that fieldtrip will show us the events        
        if FT_DATA.done.resample            
            [origfs,data.cfg] = FT.EditCfg(data.cfg,'set','origfs',[]);
        end

        %plot 
        artf  = ft_databrowser(cfg,data);
        
        %convert artefact segments to trials
        artf  = Segment2Trial(artf);
        
        %reject
        FT_DATA.data = cellfun(@(x) ft_rejectartifact(artf,x),FT_DATA.data,'uni',false);

    case 'segment'
        cfg.channel     = 'all';
        cfg.trials      = 'all';
        cfg.method      = 'trial';
        cfg.keepchannel = 'yes';
        cfg.metric      = 'range';
        
        %ft_rejectvisual takes care of everything
        for k = 1:numel(FT_DATA.data)
            FT_DATA.data{k} = ft_rejectvisual(cfg,FT_DATA.data{k});
        end

    case 'cancel'
        return;
    otherwise
        %this should never happend
        return;
end

%update the history
FT_DATA.done.trial_rejection = true;
FT_DATA.history.trial_rejection = cfg;
FT_DATA.saved = false;
FT.UpdateGUI;

%------------------------------------------------------------------------------%
function artf = Segment2Trial(artf)
%convert artefact segments into trial indicies
    kArtf = artf.artfctdef.visual.artifact;
    for k = 1:size(kArtf,1)
        %reject the entire trial
        kTrl = find(kArtf(k,1) >= trl(:,1) & kArtf(k,2) <= trl(:,2),1,'first');
        
        %reject the whole trial
        artf.artfctdef.visual.artifact(k,:) = trl(kTrl,1:2);
    end
end
%------------------------------------------------------------------------------%
function RejectSegment

end
%------------------------------------------------------------------------------%
end