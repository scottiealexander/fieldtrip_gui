function evt = Pulse2Event(data,fs,opt)

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
% Updated: 2014-03-31
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt.width = opt.width/1000;
opt.interval = opt.interval/1000;

% Notch filter
dNotch = data;
Wo = [1,2,3,4]*60/(fs/2);
for i = 1:sum(Wo < 1)
    [b,a] = iirnotch(Wo(i),Wo(i)/35,3);
    dNotch = filtfilt(b,a,dNotch);
end

% Bandpass filter
% ***** FIX: frequencies should probably depend inversely on opt.width etc
[b,a] = butter(4,[2,16]/(fs/2),'bandpass');
data = filtfilt(b,a,data);

evt = struct('type',[],'value',[],'sample',[],'duration',[],'offset',[]);

nData = numel(data);

%event pluse thresholds
thresh = -150;
thresh2 = 50;
max_width = (opt.width+.1)*fs; %maximum pulse width (add 100ms cushion for jitter)
chunk_size = ceil((opt.width+opt.interval)*opt.max_pulse*fs);

%we flip the sign of the data here only to make use of the 'minpeakheight' option
%as the initial deviation of each pulse is negative and that is what we want to detect
[~,kP] = findpeaks(data*-1,'minpeakheight',-thresh,'minpeakdistance',opt.width*fs);

%step though all 'POI' and label them based on the number of peaks that occur within the
%window defined by chunk_size
kLast = 0;
for k = 1:numel(kP)
    kStart = max(kP(k)-0.1*fs,1);
    kEnd = min(kP(k)+0.2*fs,nData);
    
    r = FitPulse(data(kStart:kEnd),'max_width',max_width,'neg_thresh',thresh,'pos_thresh',thresh2,'plot',false);
    
    if r > .8 && (kP(k) > kLast)
        kChunk = kP(k):min(kP(k)+chunk_size,nData);
        
        if numel(kChunk) > 3
            dTmp = data(kChunk);
            [~,kPeak] = findpeaks(dTmp,'minpeakheight',100,'minpeakdistance',opt.width*fs);      
            if ~isempty(kPeak)
                %find the next point where the stim channel < 0, put the marker there
                kEvtEnd = kP(k)+kPeak(end)+find(dTmp(kPeak(end):end) < 80,1,'first');
                
                %put time-lock event at start or end of pulse train
                if opt.evt_at_start
                    %find steepest descent shortly preceding the first trough
                    kChunk = max(kP(k)-opt.width*fs,1):kP(k);
                    dTmp = diff(dNotch(kChunk));
                    kEvt = kChunk(1)+find(dTmp==min(dTmp) & dTmp<0,1,'first');
                    kEvtEnd = kP(k)+kPeak(end);
                else
                    kEvt = kEvtEnd;
                end
                if ~isempty(kEvt)
                    evt.sample(end+1,1) = kEvt;
                    evt.value(end+1,1) = numel(kPeak);
                    kLast = kEvtEnd;
                end
            end
        end
    end    
end

evt.type     = repmat({'Stimulus'},numel(evt.value),1);
evt.duration = ones(numel(evt.value),1);
evt.offset   = repmat({[]},numel(evt.value),1);
end