function [centers,cBands,data_raw] = HilbertPSD(params)

% FT.tfd.HilbertPSD
%
% Description:  time-frequency decomposition based on the Hilbert transform
%
% Syntax: FT.tfd.HilbertPSD(params)
%
% In:   params - a struct holding parameters from the user for performing
%                the time-frequency decomposition
%             see 'FT.tfd.Gui'
%
% Out:  centers - frequency band centers (freq x 1)
%       cBands - frequency bands (freq x 2)
%       data_raw - time-frequency data (freq x 1 cell of channel x time)
%
% Updated: 2014-08-20
% Peter Horak

global FT_DATA;

%convert to percent
params.w = params.w/100;

fEnd = ((params.hi-1)/(1+params.w)); %last bin center should be param.w% less than param.hi
fBeg = ((params.lo+1)/(1-params.w)); %last bin center should be param.w% more than param.lo
if params.log
    centers = logspace(log10(fBeg),log10(fEnd),params.n)';
else
    centers = linspace(fBeg,fEnd,params.n)';
end

%frequency band edges
cBands = arrayfun(@(x) [x*(1-params.w) x*(1+params.w)],centers,'uni',false);

%bandpass filtering parameters
cfg = FT.tools.CFGDefault;
cfg.continuous  = 'yes';
cfg.channel     = 'all';
cfg.bpfilter 	= 'yes';   
cfg.bpfilttype  = 'but';         %butterworth type filter
cfg.bpfiltdir   = 'twopass';     %forward+reverse filtering
cfg.bpinstabilityfix = 'reduce'; %deal with filter instability

FT.Progress2((params.n*2)+1,'Computing spectrogram: Hilbert');

%bandpass filter and hilbert transform for each frequency band
% yields a cfg.n x 1 cell of channel x time power values
data_raw   = cellfun(@HilbertXFM,cBands,'uni',false);

%-------------------------------------------------------------------------%
function tmp = HilbertXFM(freq)

    %bandpass filter
    cfg.bpfreq = freq;
    tmp = ft_preprocessing(cfg,FT_DATA.data);

    %channel x time matrix of power values
    tmp = transpose(abs(hilbert(transpose(tmp.trial{1}))).^2);
    
    FT.Progress2;

end
%-------------------------------------------------------------------------%
end