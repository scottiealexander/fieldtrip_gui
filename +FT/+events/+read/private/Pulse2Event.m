function evt = Pulse2Event(data,fs,varargin)

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

opt = FT.ParseOpts(varargin,...
    'width'    , 50 ,...
    'interval' , 50 ,...
    'max_pulse', 8   ...
    );

opt.width = opt.width/1000;
opt.interval = opt.interval/1000;

evt = struct('type',[],'value',[],'sample',[],'duration',[],'offset',[]);

nData = numel(data);

%event pluse thresholds
thresh = -150;
thresh2 = 50;
max_width = (opt.width+.1)*fs; %maximum pulse width (add 100ms cushion for jitter)
chunk_size = ceil((opt.width+opt.interval)*opt.max_pulse*fs);

% data = -data;
% thresh = -50;
% thresh2 = 150;

%we flip the sign of the data here only to make use of the 'minpeakheight' option
%as the initial deviation of each pulse is negative and that is what we want to detect
[~,kP] = findpeaks(data*-1,'minpeakheight',-thresh,'minpeakdistance',opt.width*fs);

%step though all 'POI' and label them based on the number of peaks that occur within the
%window defined by chunk_size
kLast = 0;
for k = 1:numel(kP)

    kStart = .1*fs;
    if kP(k)-kStart < 1
        kStart = 1;
    else
        kStart = kP(k)-kStart;
    end
    
    kEnd = .2*fs;
    if kP(k)+kEnd > nData
        kEnd = nData;
    else
        kEnd = kP(k)+kEnd;
    end
    
    r = FitPulse(data(kStart:kEnd),'max_width',max_width,'neg_thresh',thresh,'pos_thresh',thresh2,'plot',false);
    
%     if kP(k) > kLast
    if r > .8 && kP(k) > kLast
        if  kP(k)+chunk_size > nData
            kChunk = kP(k):nData;
        else
            kChunk = kP(k):kP(k)+chunk_size;
        end
        if kChunk(end) > numel(data)
            error('invalid chunk size detected!');
        end
        if numel(kChunk) > 3
            dTmp = data(kChunk);
            [~,kPeak] = findpeaks(dTmp,'minpeakheight',100,'minpeakdistance',opt.width*fs);      
            if ~isempty(kPeak)
                %find the next point where the stim channel < 0, put the marker there
                kEvt = kP(k)+kPeak(end)+find(dTmp(kPeak(end):end) < 80,1,'first');
                if ~isempty(kEvt)
                    evt.sample(end+1,1) = kEvt-ceil((opt.width+opt.interval)*numel(kPeak)*fs);
%                     evt.sample(end+1,1) = kEvt;
                    evt.value(end+1,1) = numel(kPeak);
                    kLast = kEvt;
                end
            end
        end
    end    
end

evt.type     = repmat({'Stimulus'},numel(evt.value),1);
evt.duration = ones(numel(evt.value),1);
evt.offset   = repmat({[]},numel(evt.value),1);