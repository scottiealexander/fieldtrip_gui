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
% Updated: 2013-08-14
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt = FT.ParseOpts(varargin,...
    'width'    , 50 ,...
    'interval' , 50 ,...
    'max_pulse', 8   ...
    );

opt = structfieldfun(@(x) x/1000, opt);

evt = struct('type',[],'value',[],'sample',[],'duration',[],'offset',[]);

%event pluse thresholds
thresh = -150;
thresh2 = 50;
max_width = fs*(1/5); %# of sample in a 200ms window
%chunk_size = (opt.width+opt.interval)*opt.max_pulse*fs;
chunk_size = (.15*8)*fs; %FIXME TODO FINISH: this is temporary

%we flip the sign of the data here only to make use of the 'minpeakheight' option
%as the initial deviation of each pulse is negative and that is what we want to detect
[~,kP] = findpeaks(data*-1,'minpeakheight',-thresh,'minpeakdistance',.05*fs); %opt.width*fs

%step though all 'POI' and label them based on the number of other 'POI' that 
%occur within 100 samples of each other
kLast = 0;
% while ~bDone
for k = 1:numel(kP)    
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
        kChunk = kP(k):kP(k)+chunk_size;
        dTmp = data(kChunk);
        [~,kPeak] = findpeaks(dTmp,'minpeakheight',100,'minpeakdistance',.05*fs);%opt.width*fs        
        
        %find the next point where the stim channel < 0, put the marker there
        kEvt = kP(k)+kPeak(end)+find(dTmp(kPeak(end):end) < 80,1,'first');
        if ~isempty(kEvt)
            evt.sample(end+1,1) = kEvt;
            evt.value(end+1,1) = numel(kPeak);%label;
            kLast = kEvt;
        end
    end    
end

evt.type     = repmat({'Stimulus'},numel(evt.value),1);
evt.duration = ones(numel(evt.value),1);
evt.offset   = repmat({[]},numel(evt.value),1);