function [centers,cBands,data_raw] = FourierPSD(params)

% FT.tfd.FourierPSD
%
% Description:  time-frequency decomposition based on the short-time fourier transform
%
% Syntax: FT.tfd.FourierPSD(params)
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
FS = FT_DATA.data.fsample;
nChan = size(FT_DATA.data.trial{1},1);

% Choose window so as to give the desired number of frequencies (params.n)
% between params.lo and params.hi
window = ceil(FS*(params.n-1)/(params.hi-params.lo));
while (floor(params.hi*window/FS)-ceil(params.lo*window/FS)+1) < params.n
    window = window + 1;
end
overlap = round(window*.9);

%convert to percent
params.w = params.w/100;

FT.Progress2(nChan+params.n+1,'Computing spectrogram: Fourier');

data_raw = cell(params.n,1);

for ch = 1:nChan
    % PSD: freq x time    
    [~,centers,time,PSD] = spectrogram(FT_DATA.data.trial{1}(ch,:),window,overlap,window,FS);
    % Find indices of frequency range of interest
    if ~exist('keep','var')
        fStart = find(centers>=params.lo,1,'first');
        fEnd = find(centers<=params.hi,1,'last');
        fKeep = round(linspace(fStart,fEnd,params.n));
    end
    
    % Crop frequencies to range of interest
    PSD = PSD(fKeep,:);
    % Interpolate between spectrogram and data time axes
    PSD = spline(time,PSD,FT_DATA.data.time{1}-FT_DATA.data.time{1}(1));    
    % PSD: freq x 1 cell of 1 x time
    PSD = mat2cell(PSD,ones(params.n,1));    
    % data_raw: freq x 1 cell of channel x time
    data_raw = cellfun(@(raw,psd) cat(1,raw,psd),data_raw,PSD,'uni',false);    
    FT.Progress2;
end

centers = centers(fKeep);

%frequency band edges
cBands = arrayfun(@(x) [x*(1-params.w) x*(1+params.w)],centers,'uni',false);

end