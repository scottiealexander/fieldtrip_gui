function trl = MakeTRL(fmt,sOpt,field)

% FT.MakeTRL
%
% Description: construct a 'trl', trial definition matrix according to the
%              fieldtrip conventions
%
% Syntax: FT.MakeTRL(fmt,sOpt,field)
%
% In:
%       fmt - the trial definition format, one of:
%                'endpoints' - trial is defined by starting and ending events
%                'timelock'  - trial is defined as pre and post duration
%                              relative to a time-locking event
%       sOpt - a trail definition struct whos fields are based on 'fmt':
%                'endpoints':
%                             start - the starting event code
%                             end   - the ending event code
%                'timelock':
%                             event - the time-locking event code
%                             pre   - the pre-event duration
%                             post  - the post-event duration
%       field - the event code field to use for reference, either 'type' or
%               'value'
%
% Out:
%       trl - a Nx3 trial definition matrix, where N is the number of trials.
%             The first column contains the sample-indices of the start of each trial 
%             relative to the start of the raw data, the second column contains the 
%             sample-indices of the end of each trial, and the third column contains 
%             the offset of the trigger with respect to the trial. An offset of 0 
%             means that the first sample of the trial corresponds to the trigger. A 
%             positive offset indicates that the first sample is later than the trigger, 
%             a negative offset indicates that the trial begins before the trigger.
%
% Updated: 2013-08-19
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

%get the field from the event struct that we are interested in
evt = FT.ReStruct(FT_DATA.event);
codes = evt.(field);

%make sure codes are formatted optimally
bCnvt = false;
if iscell(codes) && all(cellfun(@isnumeric,codes))
    codes = cat(1,codes{:});
    bCnvt = true;
elseif isnumeric(codes)
    bCnvt = true;
end

if bCnvt
    fFind = @(x) find(x==codes);
else
    fFind = @(x) find(strcmpi(x,codes));
end

switch lower(fmt)    
    case 'endpoints'
        sOpt.start = CnvtCode(sOpt.start);
        sOpt.end   = CnvtCode(sOpt.end);
        trl = EndPoints;
    case 'timelock'
        sOpt.event = CnvtCode(sOpt.event);
        sOpt.pre   = Time2Samp(sOpt.pre);
        sOpt.post  = Time2Samp(sOpt.post);
        trl = TimeLock;
    otherwise
        %this should never happen
end

% %add trialdef
% FT_DATA.trialdef = trl;
% 
% %add history
% sOpt.field = field;
% sOpt.format = fmt;
% FT_DATA.history.segmentation = sOpt;

%------------------------------------------------------------------------------%
function trl = EndPoints
    trl = [0 0 0];
    inc = 1;
    kStart = fFind(sOpt.start);
    kEnd   = fFind(sOpt.end);
    kEnd = evt.sample(kEnd);
    for k = 1:numel(kStart)
       tmp_start = evt.sample(kStart(k));       
       tmp_end = kEnd(find(kEnd>tmp_start,1,'first'));
       if ~isempty(tmp_end) && ~any(evt.sample(kStart(k+1:end))<tmp_end)
          %make sure there are no other trial starts between the current trial
          %start and the closest following trial end
          trl(inc,:) = [tmp_start,tmp_end,0]; 
          inc = inc+1;
       end
    end
end
%------------------------------------------------------------------------------%
function trl = TimeLock
    kEvt = fFind(sOpt.event);
    nEvt = numel(kEvt);
    trl = zeros(nEvt,3);
    trl(:,1) = evt.sample(kEvt)-sOpt.pre;
    trl(:,2) = evt.sample(kEvt)+sOpt.post;
    
%An offset of 0 means that the first sample of the trial corresponds to the 
%trigger. A positive offset indicates that the first sample is later than the
%trigger, a negative offset indicates that the trial begins before the trigger.
    trl(:,3) = zeros(nEvt,1) - sOpt.pre;
end
%------------------------------------------------------------------------------%
function s = CnvtCode(s)
    if bCnvt && all(ismember(s,'0123456789.+-e'))
        s = str2double(s);
    end
end
%------------------------------------------------------------------------------%
function t = Time2Samp(t)
%convert time in seconds to samples
    t = ceil(t*FT_DATA.data.fsample);
end
%------------------------------------------------------------------------------%
end