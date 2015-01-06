function [trl,evtifo] = MakeTRL(sOpt)

% FT.MakeTRL
%
% Description: construct a 'trl', trial definition matrix according to the
%              fieldtrip conventions
%
% Syntax: FT.MakeTRL(fmt,sOpt,field)
%
% In:   sOpt - a trail definition struct with field:
%                     type  - the type of event of interest
%                     pre   - the pre-event duration
%                     post  - the post-event duration
%
% Out:  trl - a Nx3 trial definition matrix, where N is the number of trials.
%             The first column contains the sample-indices of the start of each trial 
%             relative to the start of the raw data, the second column contains the 
%             sample-indices of the end of each trial, and the third column contains 
%             the offset of the trigger with respect to the trial. An offset of 0 
%             means that the first sample of the trial corresponds to the trigger. A 
%             positive offset indicates that the first sample is later than the trigger, 
%             a negative offset indicates that the trial begins before the trigger.
%
% Updated: 2014-08-19
% Peter Horak

global FT_DATA;

%get the field from the event struct that we are interested in
evt = FT.ReStruct(FT_DATA.event);
% Make sure type field is a cellstr (need to fix if numel(events)=1)
if ~iscell(evt.type), evt.type = {evt.type}; end

evt_types = evt.type(:);

% Convert pre/post times from seconds to samples
sOpt.pre   = ceil(sOpt.pre*FT_DATA.data.fsample);
sOpt.post  = ceil(sOpt.post*FT_DATA.data.fsample);

% Find all events of the given type
kEvt = arrayfun(@(type) find(strcmpi(type,evt_types)),sOpt.types,'uni',false);
kEvt = cat(1,kEvt{:});
nEvt = numel(kEvt);

% Create trials for these events
trl = zeros(nEvt,3);
trl(:,1) = evt.sample(kEvt)-sOpt.pre;
trl(:,2) = evt.sample(kEvt)+sOpt.post;
%An offset of 0 means that the first sample of the trial corresponds to the 
%trigger. A positive offset indicates that the first sample is later than the
%trigger, a negative offset indicates that the trial begins before the trigger.
trl(:,3) = zeros(nEvt,1) - sOpt.pre;

%make sure no trial definition samples fall outside the data range
bad_trials = (trl(:,1) < 1) | (trl(:,2) > size(FT_DATA.data.trial{1},2));
%%% bad_trials = (trl(:,1) < FT_DATA.data.sampleinfo(1)) | (trl(:,2) > FT_DATA.data.sampleinfo(2));
trl = trl(~bad_trials,:);

evtifo = FT_DATA.event(kEvt);
evtifo = evtifo(~bad_trials);

end