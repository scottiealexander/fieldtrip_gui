function HilbertPSD()

% FT.HilbertPSD
%
% Description: time-frequency decomposition based on the Hilbert transform
%
% Syntax: FT.HilbertPSD
%
% In:
%
% Out:
%
% Updated: 2014-01-10
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

%GOAL:
%   1) bandpass filter
%       - 42 logspace centers (+- 10%) between 10 and 110
%   2) hilbert xfm
%   3) construct trial definition
%   4) segment data

%TODO:
%   scale the power at each frequency by the total mean power
nFreq = 42;

global FT_DATA;
FS = FT_DATA.data.fsample;

%make sure there is trial info
if ~isfield(FT_DATA,'epoch') || isempty(FT_DATA.epoch)
    if ~FT.DefineTrial
        data = [];
        return;
    end
end

%caclulate frequency bin centers
fEnd = ((FS/2)/1.1)-1; %last bin center should be 10% less than the FS/2
centers = logspace(1,log10(fEnd),nFreq);

%frequency band edges
cBands = arrayfun(@(x) [x*.9 x*1.1],centers,'uni',false);

%bandpass filtering parameters
cfg = CFGDefault;
cfg.continuous  = 'yes';
cfg.channel     = 'all';
cfg.bpfilter 	= 'yes';   
cfg.bpfilttype  = 'but';         %butterworth type filter
cfg.bpfiltdir   = 'twopass';     %forward+reverse filtering
cfg.bpinstabilityfix = 'reduce'; %deal with filter instability

%n-condition length cell to hold all the data
data = cell(numel(FT_DATA.epoch),1);

FT.Progress((nFreq*2)+1,'title','Computing spectrogram');

%bandpass filter and hilbert transform for each frequency band
% yields a nFreq x 1 cell of channel x time power values
data_tmp   = cellfun(@HilbertXFM,cBands,'uni',false);

%scale each frequency band by total mean power
%NOTE: should we calculate total mean power within or across channels?
mean_power = mean(cellfun(@(x) mean(reshape(x,[],1),1),data_tmp));
data_tmp   = cellfun(@(x) x/mean_power,data_tmp,'uni',false);
FT.Progress;

%segment and reshape data
%yields a ncondition x 1 cell of freq x time x channel x trial
cellfun(@SegmentData,data_tmp,num2cell(1:nFreq),'uni',false);

%add to the data struct
FT_DATA.power.raw     = data_tmp;
FT_DATA.power.data    = data;
FT_DATA.power.centers = centers;
FT_DATA.power.bands   = cBands;
FT_DATA.power.time    = GetTime;

%-------------------------------------------------------------------------%
function tmp = HilbertXFM(freq)

    %bandpass filter
    cfg.bpfreq = freq;
    tmp = ft_preprocessing(cfg,FT_DATA.data);

    %channel x time matrix of power values
    tmp = transpose(abs(hilbert(transpose(tmp.trial{1}))).^2);
    
    FT.Progress;

end
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
        data{k}(kFreq,:,:,:) = epochs{k};
    end
    
    FT.Progress;

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