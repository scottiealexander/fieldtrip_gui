function me = Run(params)

% FT.tfd.Run
%
% Description: transform data into time-frequency domain and then segment
%
% Syntax: me = FT.tfd.Run(params)
%
% In: 
%       params - a struct holding parameters from the user for performing
%                the time-frequency decomposition
%             see 'FT.tfd.Gui'
%
% Out:
%       me - an empty matrix if processing finished with out error, otherwise a
%            MException object caught from the error
%
% Updated: 2014-08-20
% Peter Horak
%
% See also: FT.tfd.Gui

global FT_DATA
me = [];

try
% Perform time-frequency decomposition with specified method
    switch lower(params.method)
        case 'hilbert'
            [centers,cBands,data_raw] = FT.tfd.HilbertPSD(params);
        case 'wavelet'
            [centers,cBands,data_raw] = FT.tfd.WaveletPSD(params);
        case 'stft'
            [centers,cBands,data_raw] = FT.tfd.FourierPSD(params);
        otherwise
            %shouldn't ever happen
            error('Error: unrecognized method ''%s'' in CreatePSD',params.method)
    end

    % scale each channel/frequency band by total mean power across bands, but within channel
    mean_power = cellfun(@(x) mean(x,2),data_raw,'uni',false);
    mean_power = mean(cat(2,mean_power{:}),2);
    data_raw   = cellfun(@(x) x./repmat(mean_power,1,size(x,2)),data_raw,'uni',false);
    FT.Progress2;

% Segment and reshape data
    %n-condition length cell to hold all the data
    data = cell(numel(FT_DATA.epoch),1);
    
    %yields a ncondition x 1 cell of freq x time x channel x trial matricies
    cellfun(@SegmentData,data_raw,num2cell(1:params.n)','uni',false);

    %add to the data struct
    FT_DATA.power.raw     = (cat(3,data_raw{:}));
    FT_DATA.power.data    = data;
    FT_DATA.power.centers = centers;
    FT_DATA.power.bands   = cBands;
    FT_DATA.power.time    = GetTime;
    FT_DATA.power.label   = FT_DATA.data.label;
    FT_DATA.power.fsample = FT_DATA.data.fsample;

% Generate surrogate data
    if params.surrogate && (params.nsurrogate > 0)
        FT.tfd.Surrogate(params.nsurrogate);
    end
    % Remove the raw data used to generate the surrogates
    FT_DATA.power = rmfield(FT_DATA.power,'raw');
    
catch me
end

%mark data as not saved
FT_DATA.saved = false;

%update the history
FT.tools.AddHistory('tfd',params);
FT_DATA.done.tfd = isempty(me);

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
    t = linspace(-s.pre,s.post,nPts);
end
%-------------------------------------------------------------------------%
end