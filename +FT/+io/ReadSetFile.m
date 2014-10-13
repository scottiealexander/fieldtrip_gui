function ReadSetFile(strPath)
% ReadSetFile
%
% Description: read a FT dataset file
%
% Syntax: ReadSetFile(strPath)
%
% In:
%		strPath - the path to s FT .set file 
%
% Out: 
%
% Updated: 2014-06-27
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA

%load FiledTripGUI dataset file
sTmp = load(strPath,'-mat');
cFields = fieldnames(sTmp);

%%%%%%%%%%%%%%%%%%%%%%%%%%% LEGACY SUPPORT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rename fields known to have new names
sDone = sTmp.done;
if ~isfield(sDone,'remove_channels') && isfield(sDone,'rm_channel')
    sDone.remove_channels = sDone.rm_channel;
    sDone = rmfield(sDone,'rm_channel');
end
if ~isfield(sDone,'segment_trials') && isfield(sDone,'segmentation')
    sDone.segment_trials = sDone.segmentation;
    sDone = rmfield(sDone,'segmentation');
end
if ~isfield(sDone,'baseline_trials') && isfield(sDone,'baseline_correction')
    sDone.baseline_trials = sDone.baseline_correction;
    sDone = rmfield(sDone,'baseline_correction');
end
if ~isfield(sDone,'reject_trials') && isfield(sDone,'trial_rejection')
    sDone.reject_trials = sDone.trial_rejection;
    sDone = rmfield(sDone,'trial_rejection');
end

% Create any remaining fields that should exist assuming a value of false
new_fields = setdiff(fieldnames(FT_DATA.done),fieldnames(sDone));
for i = 1:numel(new_fields)
    sDone.(new_fields{i}) = false;
end
sTmp.done = sDone;

% Make history field compatible in type
if ~iscell(sTmp.history)
    sTmp.history = {};
end

% if ~isempty(setxor(cFields,fieldnames(FT_DATA.done)))
%      FT.UserInput('\bf[\color{yellow}NOTICE\color{black}]: Cannot load old .set file because of incompatible fields.',1,'title','Notice','button',{'OK'});
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%save GUI params that are unique to the graphical session
tmp_gui = FT_DATA.gui;

%save current template
template = FT_DATA.template;
template_path = FT_DATA.path.template;

%save current organization
org = FT_DATA.organization;

%merge with the FT_DATA struct
for k = 1:numel(cFields)
    FT_DATA.(cFields{k}) = sTmp.(cFields{k});
end

%replace GUI params
FT_DATA.gui.hAx = tmp_gui.hAx;
FT_DATA.gui.hText = tmp_gui.hText;
FT_DATA.gui.sizText = tmp_gui.sizText;
FT_DATA.gui.screen_size = tmp_gui.screen_size;
FT_DATA.gui.display_fields = tmp_gui.display_fields;

%replace organizaton
FT_DATA.organization = org;

%replace template
FT_DATA.template = template;
FT_DATA.path.template = template_path;