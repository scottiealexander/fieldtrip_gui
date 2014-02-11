function evt = Pulse2Event(data,fs)

% Pulse2Event
%
% Description: convert event pulse sequences into an event structure
%
% Syntax: evt = Pulse2Event(data,fs)
%
% In: 
%       data - the stimulus channel as a 1xN vector
%       fs   - the sampling rate of the data
%
% Out: 
%       evt  - an event struct with fields:
%               'sample': the index/latency of each event in samples relative to
%                         the start of the data sample
%               'value' : the code of each event (i.e. the number of consecutive
%                         pulses detected for each event/pulse sequence)
%
% NOTE: for compatibility the evt struct also contains the fields 'type'
%       ('Stimulus' for all events), 'duration' (1 for all events) and
%       'offset' ([])
%
% Updated: 2013-08-14
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

evt = struct('type',[],'value',[],'sample',[],'duration',[],'offset',[]);

%event pluse thresholds
thresh = -150;
thresh2 = 50;
max_width = fs*(1/5); %# of sample in a 200ms window
chunk_size = (.15*8)*fs; %FIXME TODO FINISH: this is temporary

%find all points that exceede the threshold
% kAll = find(data<thresh);
% 
% %find all places where supra-threshold values are *NOT* immediatly preceeded by
% %other supra-threshold values, and get indicies of those points within our
% %original data, we'll call these 'points-of-interest' (POI)
% kD = diff(kAll);
% kP = kAll(find(kD>1)+1); %+1 to account for diff offset

[~,kP] = findpeaks(data*-1,'minpeakheight',150,'minpeakdistance',.05*fs);

%step though all 'POI' and label them based on the number of other 'POI' that 
%occur within 100 samples of each other
bDone = false;
k = 1;
kLast = 0;
while ~bDone
    %make sure there is a > 100mV positive peak within 100 samples
    %FIXME TODO FINISH
    % the hard coded 400 here needs to be detirmined from the pulse duration
    % specified by the user
    if kP(k)+400 > numel(data)
        kEnd = numel(data);
    else
        kEnd = kP(k)+400;
    end
    
    r = FitPulse(data(kP(k)-100:kEnd),'max_width',max_width,'neg_thresh',thresh,'pos_thresh',thresh2,'plot',false);
    
    if r > .8 && kP(k) > kLast
        kChunk = kP(k):kP(k)+chunk_size;%+500;
%         kAll = find(data(kChunk) > thresh2)+kP(k)-1;
%         kDAll = diff(kAll);
%         kPAll = [kAll(1) kAll(find(kDAll>1)+1)];
%         kI = 1;
%         label = 1;
%         if numel(kPAll) > 1
%             while kPAll(kI+1) - kPAll(kI) < max_width && sum(data(kPAll(kI):kPAll(kI+1))<-max_width) > 0
%                 label = label+1;
%                 kI = kI+1;
%                 if kI > numel(kPAll)-1
%                     break;
%                 end
%             end
%         else
%             kPAll = kAll(1);
%         end
        dTmp = data(kChunk);
        [~,kPeak] = findpeaks(dTmp,'minpeakheight',100,'minpeakdistance',.05*fs);
        if ~bDone
         %find the next point where the stim channel < 0, put the marker there
         %kEvt = kPAll(kI)+find(data(kPAll(kI)+1:kPAll(kI)+100) < 80 ,1,'first');
         kEvt = kP(k)+kPeak(end)+find(dTmp(kPeak(end):end) < 80,1,'first');
         if ~isempty(kEvt)
             evt.sample(end+1,1) = kEvt;
             evt.value(end+1,1) = numel(kPeak);%label;
             kLast = kEvt;
         end
         k = k+1;
        end
    else
        k = k+1;
    end
    bDone = k >= numel(kP);
end

evt.type     = repmat({'Stimulus'},numel(evt.value),1);
evt.duration = ones(numel(evt.value),1);
evt.offset   = repmat({[]},numel(evt.value),1);