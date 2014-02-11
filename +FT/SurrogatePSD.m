function SurrogatePSD()

% FT.SurrogatePSD
%
% Description: construct surrogate PSD by phase scrambling the instantaneous power values
%			   from a hilbert decomposition
%
% Syntax: FT.SurrogatePSD
%
% In:
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

nITER   = 5;

if ~isfield(FT_DATA,'power') || ~isfield(FT_DATA.power,'raw') || isempty(FT_DATA.power.raw)
	msg = ['\bf[\color{red}ERROR\color{black}]: Hilbert decomposition has not been ',...
		   'performed on this data set!'];
	FT.UserInput(msg,0,'button','OK');
	return;
end

if nITER > 3
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

%trial and data length in number of data points
trial_len = numel(FT_DATA.power.time);
data_length  = size(FT_DATA.power.raw{1},2);

%indicies of points that mark the start of a trial
kStart = nan(sum(nTrial),1);

%all possible starting points for trials
pnts = 1:(data_length-trial_len);

%choose a random starting point for each trial
%such that no trials will overlap
for k = 1:sum(nTrial)	
	trial_start = pnts(randi(numel(pnts),1));	
	bRM = (pnts > trial_start-trial_len) & (pnts < trial_start+trial_len);
	pnts(bRM) = [];
	kStart(k) = trial_start;
end

%group trials for each condition
%NOTE: we need to subtract 1 from the trial length as the point
%at which the trial starts is part of the trial
kTrial  = [kStart kStart+(trial_len-1)];
cKStart = mat2cell(kTrial,nTrial,2);

%init our cell of data
nBand = numel(FT_DATA.power.bands);
data = cell(nITER,1);

%generate the surrogate ERSP matricies
FT.Progress2(nBand*numel(cKStart)*nITER,'Generating surrogate data');
id = tic;
if bParallel
	%use multiple workers in parallel
	hMsg = FT.UserInput('Creating surrogate data',1);
	fprintf('Using %d threads for processing\n',nWorker);
    if matlabpool('size') > 0
        matlabpool('close');
    end    
    pc = parcluster;
	pc.NumWorkers = nWorker;
	matlabpool(pc,nWorker);
	parfor kIter = 1:nITER
		data{kIter,1} = SurrogateERSP(FT_DATA.power,cKStart,true);
	end
	matlabpool('close');
	if ishandle(hMsg)
		delete(hMsg);
	end
else
	%single worker
	for kIter = 1:nITER
		data{kIter,1} = SurrogateERSP(FT_DATA.power,cKStart,false);
	end
end
fprintf('TOTAL ELASPED TIME: %.2f\n',toc(id));

%group surrogates by condition
data = reshape(data,1,1,1,[]);
data = CellJoin(cat(4,data{:}),1);

%compute mean and std
%here mean and std are nCondition x 1 cells of freq x time x channel matricies
%representing the mean and std (respectivly) of all surrogate ERSP matricies
FT_DATA.power.surrogate.mean = cellfun(@(x) mean(x,4),data,'uni',false);
FT_DATA.power.surrogate.std  = cellfun(@(x) std(x,[],4),data,'uni',false);

%remove the raw data
FT_DATA.power = rmfield(FT_DATA.power,'raw');

FT_DATA.saved = false;

%-----------------------------------------------------------------------------%
function cD = SurrogateERSP(power,cKStart,bpar)
% SurrogateERSP
%
% Description: compute a surrogate ERSP from hilbert decomposition data
%
% Syntax: cD = SurrogateERSP(power,cKStart,bparallel)
%
% In:
%		power   - the power struct computed by FT.HilbertPSD
%		cKStart - a nCondition length cell of start and end indicies for each 
%				  trial
%		bpar    - true if this function is being called with a parfor loop
%				  (i.e. don't try and update a progress bar)
%
% Out:
%		cD - a nCondition length cell of ERSP matricies (freq x time x channel) 
%
% Updated: 2014-01-23
% Scottie Alexnader

%INFO the function that actually computes a surrogate ERSP by:
%		1) scrambling the phase of the hilbert decomposition matrix of each 
%		   frequency band => channel x time 
%		2) extracting the randomly positioned trials => channel x time x trial
%		3) reformatting our trials matrix to be freq x time x channel x trial
%		4) averaging accross trials to get a surrogate ERSP matrix that is
%		   freq x time x channel
	id = tic;

	%initialize a cell of nans for each condition
	nband 	  = numel(power.bands);
	trial_len = numel(power.time);
	nchan 	  = size(power.raw{1},1);

	cD = repmat({nan(nband,trial_len,nchan)},numel(cKStart),1);
	
	%iterate through the hilbert decomposition matrix for each power band
	for kA = 1:nband
		%scramble the phases
		d = phaseran2(power.raw{kA});	

		%iterate through the cell of trial start and end indicies
		for kB = 1:numel(cKStart)
			kStart = cKStart{kB};
			
			%extract trials for the current condition
			tmp = reshape(arrayfun(@(y,z) d(:,y:z),kStart(:,1),kStart(:,2),'uni',false),1,1,[]);

			%reformat to be 1 x time x channel x trial and insert into
			%the cell element that corresponds with the condition, and the row
			%of the contents of that cell element that corresponds to the
			%current frequency band	
			tmp = cat(3,tmp{:});
			cD{kB}(kA,:,:) = mean(permute(reshape(tmp,[1 size(tmp)]),[1,3,2,4]),4);
			
			FT.Progress2;            
		end
	end	
	fprintf('%s: iter done [%.2f]\n',datestr(now,13),toc(id));
%-----------------------------------------------------------------------------%