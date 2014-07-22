function SegmentTrials(varargin)

% FT.SegmentTrials
%
% Description: segment continuous data into trials
%
% Syntax: FT.SegmentTrials
%
% In: 
%
% Out: 
%
% Updated: 2013-08-19
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

me = [];

%make sure we have events
if ~FT_DATA.done.read_events || ~isfield(FT_DATA,'event') || isempty(FT_DATA.event)
    FT.UserInput(['\color{red}Event have not been processed for this dataset!\n\color{black}'...
        'Please use:\n      \bfSegmentation->Process Events\rm\nbefore segmenting.'],...
        0,'title','No Events Exist','button','OK');
    return;
end

%get trial definition
bRun = FT.DefineTrial;

if bRun && ~isempty(FT_DATA.epoch)
    
    %get baseline correction parameters
    b_cfg = FT.baseline.Gui;

    hMsg = FT.UserInput('Segmenting data into trials',1);

    %segment into trials
    nCondition = numel(FT_DATA.epoch);
    EPOCH = cell(nCondition,1);
    for k = 1:nCondition

        %segment
        cfg = CFGDefault;
        cfg.trl = FT_DATA.epoch{k}.trl;
        EPOCH{k,1} = ft_redefinetrial(cfg,FT_DATA.data);
    end
    
    FT_DATA.data = EPOCH;

    if ~isempty(b_cfg)
        me = FT.baseline.Run(b_cfg);
    end

    if ishandle(hMsg)
        close(hMsg);
    end

    if isa(me,'MException')
        FT.ProcessError(me);
        return;
    end

    %update history
    FT_DATA.done.segmentation = true;    
    FT_DATA.saved = false;
    FT_DATA.gui.display_mode = 'segment';    

    %update display
    FT.UpdateGUI;
else
    %user selected cancel...
end