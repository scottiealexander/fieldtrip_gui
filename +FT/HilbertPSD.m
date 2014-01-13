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
fEnd = (FS/2)/1.1; %last bin center should be 10% less than the FS/2
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

data = cell(numel(FT_DATA.epoch),1);

tElap = nan(nFreq,1);

hWait = waitbar(0,'00% done | xx:xx:xx remaining');
set(hWait,'Name','Computing spectrogram...');
drawnow;

cellfun(@ProcessOne,cBands,num2cell(1:nFreq));

if ishandle(hWait)
    close(hWait);
end

%add to the data struct
FT_DATA.power.data    = data;
FT_DATA.power.centers = centers;
FT_DATA.power.bands   = cBands;
FT_DATA.power.time    = GetTime;

%-------------------------------------------------------------------------%
function ProcessOne(freq,kFreq)
%GOAL: freq x time x channel x trial matrix for each condition
    id = tic;
    cfg.bpfreq = freq;
    
    tmp = ft_preprocessing(cfg,FT_DATA.data);

    %channel x time matrix of power values
    tmp = transpose(abs(hilbert(transpose(tmp.trial{1}))).^2);

    %channel x time x trial matrix for each condition
    d = cellfun(@SegmentOne,FT_DATA.epoch,'uni',false);

    %reshape each matrix: add a singleton freq dimention (dim 1) and permute to be 
    %time x channel x trial
    d = cellfun(@(x) permute(reshape(x,[1,size(x)]),[1,3,2,4]),d,'uni',false);
    
    %assign our hilbert XFM-ed data matrix by its corresponding frequency
    for k = 1:numel(data)
        data{k}(kFreq,:,:,:) = d{k};
    end    

    %estimate time remaining
    tElap(kFreq) = toc(id);
    tRem = nanmean(tElap,1) * (nFreq-kFreq);

    %update the waitbar
    strMsg = sprintf('%02.0f%% done | %s remaining',(kFreq/nFreq)*100,FmtTime(tRem));
    waitbar(kFreq/nFreq,hWait,strMsg);
    drawnow;
    
    %---------------------------------------------------------------------%
    function out = SegmentOne(s)
    %GOAL: channel x time x trial matrix for a given condition
        kStart = s.trl(:,1);
        kEnd   = s.trl(:,2);

        %n-trial length cell of channel x time matricies
        out = arrayfun(@(x,y) tmp(:,x:y),kStart,kEnd,'uni',false);

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
function x = FmtTime(x)
%GOAL: format a duration in seconds as a hh:mm:ss string
    x = sprintf('%02d:%02d:%02.0f',floor(x/60^2),floor(rem(x,60^2)/60),rem(x,60));
end
%-------------------------------------------------------------------------%
end
