function SurrogatePSD(nITER)

% FT.SurrogatePSD
%
% Description: construct surrogate PSD by phase scrambling the instantaneous power values
%			   from a time-frequency decomposition
%
% Syntax: FT.SurrogatePSD(nITER)
%
% In:
%		nITER - the number of surrogate datasets to generate
%
% Out: 
%
% Updated: 2014-06-20
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

%GOAL:
%	given a 3D matrix of power values (channels x time x frequency)
%	1) scramble the phases of the signal
%	2) randomly extract trials for each condition
%	3) average trials within condition
%	4) collect average ERSPs
%	5) compute mean and std of average ERSPs

global FT_DATA;

if ~isfield(FT_DATA,'power') || ~isfield(FT_DATA.power,'raw') || isempty(FT_DATA.power.raw)
	msg = ['\bf[\color{red}ERROR\color{black}]: Hilbert decomposition has not been ',...
		   'performed on this data set!'];
	FT.UserInput(msg,0,'button','OK');
	return;
end

if nITER > 1
	s = ver;
	bParallel = any(strcmpi({s(:).Name},'Parallel Computing Toolbox'));
	if bParallel
		nWorker = java.lang.Runtime.getRuntime().availableProcessors-1;
	end
	if isnan(nWorker) || nWorker < 2
		bParallel = false;
	elseif nWorker > nITER
		nWorker = nITER;
	end
else
	bParallel = false;
end

%total number of trials
nTrial = cellfun(@(x) size(x,4),FT_DATA.power.data);
nTrialTotal = sum(nTrial);

%trial and data length in number of data points
trial_len 	 = numel(FT_DATA.power.time);
data_length  = size(FT_DATA.power.raw,2);

%indicies of points that mark the start of a trial
kStart = nan(nTrialTotal,1);

%split up the entire timeseries into nTrialTotal equally sized 'bins',
%assign trial start indicies to a random point within each 'bin' such
%that each trial is fully contained within each bin
bin_length = floor(data_length/nTrialTotal);
for k = 1:nTrialTotal
	%the first point within the bin that could serve as out trial start index
	kfirst = (bin_length*(k-1))+1;

	%the last point in the bin that could serve as our trial start index
	klast = (bin_length*k) - (trial_len-1);
	kStart(k) = randi([kfirst klast],1,1);
end
kStart = randomize(kStart);

%group trials for each condition
%NOTE: we need to subtract 1 from the trial length as the point
%at which the trial starts is part of the trial
kTrial  = [kStart kStart+(trial_len-1)];
cKStart = mat2cell(kTrial,nTrial,2);

%init our cell of data
nBand = numel(FT_DATA.power.bands);
data = cell(nITER,1);

%lock the underlying matrix to prevent clearing
FT_DATA.power.raw.lock;

%get the data we need as local variables
raw   = FT_DATA.power.raw;
bands = FT_DATA.power.bands;

%generate the surrogate ERSP matricies
FT.Progress2(nBand*numel(cKStart)*nITER,'Generating surrogate data');
id = tic;
if bParallel
	%use multiple workers in parallel
	fprintf('Using %d threads for processing\n',nWorker);
    if matlabpool('size') > 0
        matlabpool('close');
    end    
    pc = parcluster;
    pc.NumWorkers = nWorker;
    if exist('parpool','file') == 2
        bUsePar = true;
        pp = parpool(pc);
    else
        bUsePar = false;
        matlabpool(pc,nWorker);
    end	
    parfor kIter = 1:nITER
        data{kIter,1} = SurrogateERSP(raw,bands,trial_len,cKStart);
    end
    if bUsePar
        delete(pp);
    else
        matlabpool('close');
    end
else
	%single worker
	for kIter = 1:nITER
		data{kIter,1} = SurrogateERSP(raw,bands,trial_len,cKStart);
	end
end
fprintf('TOTAL ELASPED TIME: %.2f\n',toc(id));

%unlock the underlying matrix
FT_DATA.power.raw.unlock;

%group surrogates by condition
data = reshape(data,1,1,1,[]);
data = CellJoin(cat(4,data{:}),1);

%compute mean and std
%here mean and std are nCondition x 1 cells of freq x time x channel matricies
%representing the mean and std (respectivly) of all surrogate ERSP matricies
FT_DATA.power.surrogate.mean = cellfun(@(x) nanmean(x,4),data,'uni',false);
FT_DATA.power.surrogate.std  = cellfun(@(x) nanstd(x,[],4),data,'uni',false);

%remove the raw data
FT_DATA.power = rmfield(FT_DATA.power,'raw');

FT_DATA.saved = false;

FT.UpdateGUI;

%-----------------------------------------------------------------------------%
function cD = SurrogateERSP(raw,bands,trial_len,cKStart)
% SurrogateERSP
%
% Description: compute a surrogate ERSP from time-frequency data
%
% Syntax: cD = SurrogateERSP(raw,bands,trial_len,cKStart)
%
% In:
%		raw       - the 3D matrix of power values (channels x time x frequency band)
%		bands     - the upper and lower cutoff frequency for each frequency band
%		trial_len - the lenght of a trial in samples
%		cKStart   - a nCondition length cell of start and end indicies for each 
%				    trial
%
% Out:
%		cD - a nCondition length cell of ERSP matricies (freq x time x channel) 
%
% Updated: 2014-06-20
% Scottie Alexnader

%INFO the function that actually computes a surrogate ERSP by:
%		1) scrambling the phase of the tfd matrix of each 
%		   frequency band => channel x time 
%		2) extracting the randomly positioned trials => channel x time x trial
%		3) reformatting our trials matrix to be freq x time x channel x trial
%		4) averaging accross trials to get a surrogate ERSP matrix that is
%		   freq x time x channel
	id2 = tic;
	%initialize a cell of nans for each condition
	nband 	  = numel(bands);	
	nchan 	  = size(raw,1);

	cD = repmat({nan(nband,trial_len,nchan)},numel(cKStart),1);
	
	%iterate through the decomposition matrix for each power band
	for kA = 1:nband
		%scramble the phases
		d = phaseran2(raw(:,:,kA));

		%iterate through the cell of trial start and end indicies
		for kB = 1:numel(cKStart)
			kStart = cKStart{kB};
			%extract trials for the current condition
			nTrial   = size(kStart,1);			
			tmp 	 = zeros(size(d,1),trial_len,nTrial);
			for kC = 1:nTrial
				tmp(:,:,kC) =  d(:,kStart(kC,1):kStart(kC,2));
			end			

			%reformat to be 1 x time x channel x trial and insert into
			%the cell element that corresponds with the condition, and the row
			%of the contents of that cell element that corresponds to the
			%current frequency band			
			cD{kB}(kA,:,:) = mean(permute(reshape(tmp,[1 size(tmp)]),[1,3,2,4]),4);
			FT.Progress2;            
		end
	end	
	fprintf('%s: iter done [%.2f]\n',datestr(now,13),toc(id2));
%-----------------------------------------------------------------------------%