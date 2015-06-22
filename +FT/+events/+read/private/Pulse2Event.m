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
Wo = [1,2,3,4]*60/(fs/2);
for i = 1:sum(Wo < 1)
    [b,a] = iirnotch(Wo(i),Wo(i)/35,3);
    data = filtfilt(b,a,data);
end

dd = diff(data);

% Detect starts (kP) and ends (kN) of each negative pulse
[aP,kP] = findpeaks(-dd,'minpeakheight',90);%,'minpeakdistance',opt.width*fs);
[aN,kN] = findpeaks(dd,'minpeakheight',90);%,'minpeakdistance',opt.width*fs);

% Find the starts and ends of pulse trains
[kPeaks,ord] = sort([kP,kN]);
aPeaks = [-aP,aN];
aPeaks = aPeaks(ord);
starts = [false, diff(kPeaks) > (opt.width+opt.interval)*fs];
% starts = starts(ord);
starts(1) = true;
ends = [starts(2:end), true];

% Create an event for each pulse train containing all the pulse indices and amplitudes
events = arrayfun(@(x,y) struct('inds',kPeaks(x:y),'amps',aPeaks(x:y)),find(starts),find(ends));

% Initialize the events structure
evt = struct('type',repmat({'Stimulus'},numel(events),1),'sample',NaN,'value',NaN,'duration',1,'offset',[]);
% For each pulse train, if it looks valid, insert it into the events structure
for i = 1:numel(events)
    x = events(i);
    % Check that pulse starts/ends alternate
    if ~any(diff(sign(x.amps)) == 0)
        nPulses = sum(x.amps > 0);
        % Check that the numbers of pulse starts/ends are equal and < the maximum number
        if (nPulses == sum(x.amps < 0)) && (nPulses <= opt.max_pulse)
            evt(i).value = nPulses;
            % Take the first or last pulse start/end depending on user input
            if opt.evt_at_start
                evt(i).sample = x.inds(1);
            else
                evt(i).sample = x.inds(end);
            end
        end
    end
end
evt = evt(arrayfun(@(x) ~isnan(x.sample),evt));

end