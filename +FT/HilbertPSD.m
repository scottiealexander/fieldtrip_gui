function HilbertPSD()

% FT.HilbertPSD
%
% Description:
%
% Syntax: FT.HilbertPSD
%
% In:
%
% Out:
%
% Updated: 2014-01-09 Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

%STEPS:
%   1) bandpass filter
%       - 42 logspace centers (+- 10%) between 10 and 110
%   2) hilbert xfm
%   3) construct trial definition
%   4) segment data
%   5) view average spectrogram

n = 42;

global FT_DATA;
FS = FT_DATA.data.fsample;

if ~FT.DefineTrial
    return;
end

fEnd = (FS/2) - (FS/2)*.1;
centers = logspace(1,log10(fEnd),n);

cF = arrayfun(@(x) [x*.9 x*1.1],centers,'uni',false);

cfg = CFGDefault;
cfg.continuous  = 'yes';
cfg.channel     = 'all';
cfg.bpfilter 	= 'yes';   
cfg.bpfilttype  = 'but';         %butterworth type filter
cfg.bpfiltdir   = 'twopass';     %forward+reverse filtering
cfg.bpinstabilityfix = 'reduce'; %deal with filter instability

data = cell(n,1);

cellfun(@DoOne,cF,num2cell(1:n));

data = reshape(data,1,1,[]);

%data is nChan x nTimePt x freq
data = cat(3,data{:});

%-------------------------------------------------------------------------%
function DoOne(freq,k)
    cfg.bpfreq = freq;
    
    tmp = ft_preprocessing(cfg,FT_DATA.data);
    tmp = transpose(abs(hilbert(transpose(tmp.trial{1}))).^2);
    data{k} = SegmentOne;
    
    %---------------------------------------------------------------------%
    function out = SegmentOne(kStart,kEnd)
        out = tmp(:,kStart:kEnd);
    end
    %---------------------------------------------------------------------%
end
%-------------------------------------------------------------------------%
end




