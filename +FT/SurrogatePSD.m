function data = SurrogatePSD()

% FT.SurrogatePSD
%
% Description: construct surrogate PSD by phase scrambling the instantaneous power values
%			   from a hilbert decomposition
%
% Syntax: FT.SurrogatePSD(x)
%
% In:
%		cData - a nFrequency length cell of channel x time data matricies
%				to phase scramble
%		nIter - the number of times to scramble and average the data
%
% Out: 
%
% Updated: 2014-01-17
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

%GOAL:
%	given a cell of bandpass hilbert decompositions...
%	1) scramble the phases of the signal
%	2) randomly extract trials for each condition
%	3) average trials within condition
%	4) collect average ERSPs
%	5) compute mean and std of average ERSPs

global FT_DATA;

nITER = 5;
nWorker = 5;

s = ver;
bParallel = any(strcmpi({s(:).Name},'Parallel Computing Toolbox'));

%total number of trials
nTrial = cellfun(@(x) size(x,4),FT_DATA.power.data);

%trial length in number of data points
trl = numel(FT_DATA.power.time);

data_length  = size(FT_DATA.power.raw{1},2);
% data_length  = size(FT_DATA.data.trial{1},2);

%indicies of points that mark the start of a trial
kStart = nan(sum(nTrial),1);

%all possible starting points for trials
pnts = 1:(data_length-trl);

%choose a random starting point for each trial
%such that no trials will overlap
for k = 1:sum(nTrial)	
	srt = pnts(randi(numel(pnts),1));	
	bRM = pnts > srt-trl & pnts < srt+trl;
	pnts(bRM) = [];
	kStart(k) = srt;
end

%group trials for each condition
kTrial = [kStart kStart+trl-1];
cKStart = mat2cell(kTrial,nTrial,2);

nBand = numel(FT_DATA.power.bands);%*nITER;

%init our cell of data
% data = repmat({nan(nBand,trl,numel(FT_DATA.data.label))},numel(cKStart),1);
nChan = numel(FT_DATA.data.label);
data = repmat({nan(nBand,trl,nChan,nITER)},numel(cKStart),1);

FT.Progress(nBand*numel(cKStart));

%ERROR FIXME TODO: use CellJoin!!!
if bParallel
    
	fprintf('Using %d threads for processing\n',nWorker);
    if matlabpool('size') > 0
        matlabpool('close');
    end
    
    pc = parcluster;
	pc.NumWorkers = nWorker;
	matlabpool(pc,nWorker);
	parfor kIter = 1:nITER
		for kA = 1:nBand
			d = phaseran2(FT_DATA.power.raw{kA});
			for kB = 1:numel(cKStart)
				data{kB}(kA,:,:,kIter) = SegmentData(d,cKStart{kB});
			end
		end
	end
	matlabpool('close');
else	
	for kIter = 1:nITER
		for kA = 1:nBand
			d = phaseran2(FT_DATA.power.raw{kA});
			for kB = 1:numel(cKStart)
				data{kB}(kA,:,:,kIter) = SegmentData(d,cKStart{kB});
			end
		end
	end
end

%-----------------------------------------------------------------------------%
function cD = SegmentData(d,kStart)
	%extract trials for each condition
	cD = reshape(arrayfun(@(y,z) d(:,y:z),kStart(:,1),kStart(:,2),'uni',false),1,1,[]);

	%reformat to be 1 x time x channel x trial	
	cD = cat(3,cD{:});
	cD = mean(permute(reshape(cD,[1 size(cD)]),[1,3,2,4]),4);

	FT.Progress;
%-----------------------------------------------------------------------------%