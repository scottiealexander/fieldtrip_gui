function [centers,cBands,data_raw] = WaveletPSD(params)

% FT.tfd.WaveletPSD
%
% Description:  time-frequency decomposition based on the wavelet transform
%
% Syntax: FT.tfd.WaveletPSD(params)
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

%convert to percent
params.w = params.w/100;

fEnd = ((params.hi-1)/(1+params.w)); %last bin center should be param.w% less than param.hi
fBeg = ((params.lo+1)/(1-params.w)); %last bin center should be param.w% more than param.lo
if params.log
    centers = logspace(log10(fBeg),log10(fEnd),params.n)';
else
    centers = linspace(fBeg,fEnd,params.n)';
end

scales = centfrq('morl')*FS./centers;

FT.Progress2(nChan+params.n+1,'Computing spectrogram: Wavelet');
data_raw = cell(params.n,1);
for ch = 1:nChan
    cf = cwtft(FT_DATA.data.trial{1}(ch,:),'scales',scales,'wavelet','morl');

    % freq x time
    PSD = abs(cf.cfs).^2;

    % freq x 1 cell of 1 x time
    PSD = mat2cell(PSD,ones(1,params.n));

    % data_raw: freq x 1 cell of channel x time
    data_raw = cellfun(@(raw,psd) cat(1,raw,psd),data_raw,PSD,'uni',false);    
    FT.Progress2;
end

%frequency band edges
cBands = arrayfun(@(x) [x*(1-params.w) x*(1+params.w)],centers,'uni',false);

end