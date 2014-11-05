function evt = File2Event(data,fs,params)
% ***** Add description etc *****
global FT_DATA;
evt = [];

%% Find a file
while (1)
    % Select a file (repeats code from FT.io.Gui)
    strDirCur = pwd;
    if isdir(FT_DATA.path.base_directory)
        cd(FT_DATA.path.base_directory);
    end
    [strName,strPath] = uigetfile('*.evts','Events Files');
    cd(strDirCur);

    if isequal(strName,0) || isequal(strPath,0)
        return; % user selected cancel
    end

    strPathEvt = fullfile(strPath,strName);
    % check the file's contents
    err = []; try evts = load(strPathEvt,'-mat','evts'); catch err; end
    if ~isa(err,'MException') && exist('evts','var')
        evts = evts.evts;
        if isfield(evts,'time') && isfield(evts,'npulse') && ...
                numel(evts(1).time)==1 && numel(evts(1).npulse)==1 && ...
                isnumeric(evts(1).time) && isnumeric(evts(1).npulse)
            break;
        end
    end
    FT.UserInput('Cannot read specified events file.',0,...
        'button','OK','title','Invalid File');
end

%% Assorted preparations
% Notch filter
Wo = [1,2,3,4]*60/(fs/2);
for i = 1:sum(Wo < 1)
    [b,a] = iirnotch(Wo(i),Wo(i)/35,3);
    data = filtfilt(b,a,data);
end

% The parameters for modeling the stimulus channel
npulses = [evts.npulse];
times = [evts.time];
times = times-min(times);

% Convert from ms to sec
params.width = params.width/1000;
params.interval = params.interval/1000;

%% Align the events file time axis with the stim channel
% Generate a time axis and initialize x (stim channel model)
t = 0:(1/fs):(max(times)+(params.width+params.interval)*max(npulses)+1);
x = zeros(size(t));

% Convert from sec to samples
params.width = floor(fs*params.width);
params.interval = floor(fs*params.interval);

% Model of a single pulse
pulse = ((1:(params.width+params.interval)) > params.width)-0.5;

% Model the entire stimulus channel
for k = 1:numel(evts)
    % the pulse train for a particular event
    pulse_train = repmat(pulse,1,npulses(k));
    
    % insert the pulse train into the overall model
    istart = find(t>=times(k),1,'first');
    iend = istart + length(pulse_train) - 1;
    x(istart:iend) = pulse_train;
end

% Find the offset between the events file and stim channel time axes
[xc,off] = xcorr(data,x);
off = off(xc == max(xc));
% samples = round((times + t(off))*fs); % event samples adjusted for the offset
samples = round(times*fs+off); % event samples adjusted for the offset

%% Generate events
% Remove invalid samples
bGood = (1 <= samples) & (samples <= length(data));

% Set the sample field for the events
npulses = num2cell(npulses(bGood));
samples = num2cell(samples(bGood));

% Create output events struct
evt = rmfield(rmfield(evts(bGood),'npulse'),'time');
[evt.type] = deal('Stimulus');
[evt.value] = npulses{:};
[evt.sample] = samples{:};
[evt.duration] = deal(1);
[evt.offset] = deal([]);

% Use type field from .evts file if valid
if isfield(evts,'type')
    type = {evts(bGood).type};
    if iscellstr(type)
        [evts.type] = type{:};
    end
end

end