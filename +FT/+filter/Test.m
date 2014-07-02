function Test

% FT.filter.Test
%
% Description: test FT.filter.Run on a known dataset (TEST.set). The
% dataset must be loaded before running the tests.
%
% Syntax: FT.filter.Test
%
% In: 
%
% Out:
%
% Updated: 2014-06-27
% Peter Horak
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;
FS = FT_DATA.data.fsample;
N = numel(FT_DATA.data.time{1});

%filter parameters
params = struct;
params.lpfilttype  = 'but';
params.hpfilttype  = 'but';
params.hpfilter    = 'no';
params.lpfilter    = 'no';
params.dftfilter   = 'no';
params.hpfreq      = 125;
params.lpfreq      = 125;
params.dftfreq     = 50;

%% notch filter two channels
params.channel = {'sin50','sin50+2cos90'};
params.hpfilter    = 'no';
params.lpfilter    = 'no';
params.dftfilter   = 'yes';
me = FT.filter.Run(params);
FT.tools.Log(me);

% notch filter should remove most power from clean 50Hz signal
sin50 = FT_DATA.data.trial{1}(1,:);
[psd,~] = periodogram(sin50,[],N,FS);
FT.tools.Log(mean(psd) < 1e-6);

% notch filter should remove 50Hz signal but leave 90Hz signal
sin50cos90 = FT_DATA.data.trial{1}(3,:);
[psd,f] = periodogram(sin50cos90,[],N,FS);
i = find(psd==max(psd),1,'first');
FT.tools.Log(abs(f(i)-90) < 0.2);
FT.tools.Log(psd(i) > 0);
FT.tools.Log(mean(psd([1:(i-1),(i+1):end])) < 1e-6);

%% high-pass filter the channel with noise
params.channel = 'sin50+nrnd';
params.hpfilter    = 'yes';
params.lpfilter    = 'no';
params.dftfilter   = 'no';
me = FT.filter.Run(params);
FT.tools.Log(me);

% hp filter should skew power distribution towards higher-frequency bands
sin50n = FT_DATA.data.trial{1}(2,:);
[psd,f] = periodogram(sin50n,[],N,FS);
i = find(f>=params.hpfreq,1,'first');
FT.tools.Log(mean(psd(ceil(1.2*i):end))/mean(psd(1:floor(0.8*i))) > 1e3);

%% low-pass filter the chirp signal
params.channel = 'chirp10to200';
params.hpfilter    = 'no';
params.lpfilter    = 'yes';
params.dftfilter   = 'no';
me = FT.filter.Run(params);
FT.tools.Log(me);

% lp filter should skew power distribution towards lower-frequency bands
chp = FT_DATA.data.trial{1}(4,:);
[psd,f] = periodogram(chp,[],N,FS);
i = find(f>=params.lpfreq,1,'first');
FT.tools.Log(mean(psd(ceil(1.2*i):end))/mean(psd(1:floor(.8*i))) < 1e-3);
FT.tools.Log(var(chp(ceil(1.2*.5*N):end))/var(chp(1:floor(.8*.5*N))) < 1e-3);

end

