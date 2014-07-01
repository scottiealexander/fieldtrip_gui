function FourierPSD(params)

% FT.tfd.FourierPSD
%
% Description:  time-frequency decomposition based on the short-time fourier transform
%
% Syntax: FT.tfd.FourierPSD(params)
%
% In: 
%       params - a struct holding parameters from the user for performing
%                the time-frequency decomposition
%             see 'FT.tfd.Gui'
%
% Out:
%
% Updated: 2014-06-25
% Peter Horak
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;
FS = FT_DATA.data.fsample;
nChan = size(FT_DATA.data.trial{1},1);

window = round(FS*(params.n-1)/(params.hi-params.lo));%128
overlap = round(window/2);%64

%convert to percent
params.w = params.w/100;

%n-condition length cell to hold all the data
data = cell(numel(FT_DATA.epoch),1);

FT.Progress2(nChan+params.n+1,'Computing spectrogram: Fourier');

%indices for cropping frequency range
fStart = ceil(params.n*params.lo/(params.hi-params.lo));%find(freq>=lo,1,'first');
fEnd = floor(params.n*params.hi/(params.hi-params.lo));%find(freq>=hi,1,'first');

data_raw = cell(params.n,1);
% id = tic;
for ch = 1:nChan
    % PSD: freq x time    
    [~,freq,time,PSD] = spectrogram(FT_DATA.data.trial{1}(ch,:),window,overlap,window,FS);
    PSD = PSD(fStart:fEnd,:);

    PSD = spline(time,PSD,FT_DATA.data.time{1});    
    % PSD: freq x 1 cell of 1 x time
    PSD = mat2cell(PSD,ones(1,params.n));    
    % data_raw: freq x 1 cell of channel x time
    data_raw = cellfun(@(raw,psd) cat(1,raw,psd),data_raw,PSD,'uni',false);    
    FT.Progress2;
end
% fprintf('TOTAL TIME: %f\n',toc(id));
freq = freq(fStart:fEnd);
cBands = arrayfun(@(x) [x*(1-params.w) x*(1+params.w)],freq,'uni',false);


%scale each channel/frequency band by total mean power across bands, but within channel
mean_power = cellfun(@(x) mean(x,2),data_raw,'uni',false);
mean_power = mean(cat(2,mean_power{:}),2);
data_raw   = cellfun(@(x) x./repmat(mean_power,1,size(x,2)),data_raw,'uni',false);
FT.Progress2;

%segment and reshape data
%yields a ncondition x 1 cell of freq x time x channel x trial matricies
cellfun(@SegmentData,data_raw,num2cell(1:params.n)','uni',false);

%add to the data struct
% fprintf('Creating ROA instance\n');
% id = tic;
FT_DATA.power.raw     = FT.ROA(cat(3,data_raw{:}));
% fprintf('Done | %.3f\n',toc(id));
FT_DATA.power.data    = data;
FT_DATA.power.centers = freq;
FT_DATA.power.bands   = cBands;
FT_DATA.power.time    = GetTime;
FT_DATA.power.label   = FT_DATA.data.label;
FT_DATA.power.fsample = FT_DATA.data.fsample;

%-------------------------------------------------------------------------%
function SegmentData(freq_data,kFreq)
%GOAL: segment data from a given frequency band into trials 
%      reformat the matrix to be 1 x time x channel x trial

    %segment into channel x time x trial matrix for each condition
    epochs = cellfun(@SegmentOne,FT_DATA.epoch,'uni',false);

    %reshape each matrix: add a singleton freq dimention (dim 1) and permute to be 
    %time x channel x trial
    epochs = cellfun(@(x) permute(reshape(x,[1,size(x)]),[1,3,2,4]),epochs,'uni',false);
    
    %assign our hilbert XFM-ed data matrix by its corresponding frequency
    for k = 1:numel(data)
        if size(epochs{k},4) == 1
            % if there's only one trial, epochs{k} is a 3D array (not 4D)
            data{k}(kFreq,:,:) = epochs{k};
        else
            data{k}(kFreq,:,:,:) = epochs{k};
        end
    end
    
    FT.Progress2;

    %---------------------------------------------------------------------%
    function out = SegmentOne(s)
    %GOAL: channel x time x trial matrix for a given condition
        kStart = s.trl(:,1);
        kEnd   = s.trl(:,2);

        %n-trial length cell of channel x time matricies
        out = arrayfun(@(x,y) freq_data(:,x:y),kStart,kEnd,'uni',false);

        %reshape to channel x time x trial
        out = reshape(out,1,1,[]);
        out = cat(3,out{:});
    end
    %---------------------------------------------------------------------%
end
%-------------------------------------------------------------------------%
function t = GetTime
%GOAL: calculate the time vector (in seconds) given the segmentation scheme
    nPts = size(FT_DATA.power.data{1},2);
    s = FT_DATA.epoch{1}.ifo;
    switch lower(s.format)        
        case 'timelock'
            t = linspace(-s.pre,s.post,nPts);
        case 'endpoints'
            t = linspace(0,nPts/FS,nPts);
        otherwise
            error('invalid epoch format: %s',s.format);
    end
end
%-------------------------------------------------------------------------%
end