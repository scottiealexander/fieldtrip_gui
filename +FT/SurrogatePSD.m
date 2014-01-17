function data = SurrogatePSD(cData)

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

%total number of trials
nTrial = cellfun(@(x) size(x,4),FT_DATA.power.data);

%trial length in number of data points
trl = numel(FT_DATA.power.time);

% data_length  = size(cData{1},2);
data_length  = size(FT_DATA.data.trial{1},2);

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
kTrial = [kStart kStart+trl];
cKStart = mat2cell(kTrial,nTrial,2);

data = cell(size(FT_DATA.power.data));

nTotal = numel(FT_DATA.power.bands);
tElap = nan(nTotal,1);
hWait = waitbar(0,'00% done | xx:xx:xx remaining');
set(hWait,'Name','Computing spectrogram...');
drawnow;

cellfun(@ProcessOne,cData,num2cell(1:nTotal));

if ishandle(hWait)
    close(hWait);
end

%-----------------------------------------------------------------------------%
function ProcessOne(d,kFreq)
	id = tic;

	%scramble the phases: d remains channels x time
	d = phaseran2(d);

	%extract trials for each condition
	cD = cellfun(@(x) reshape(arrayfun(@(y,z) d(:,y:z),x(:,1),x(:,2),'uni',false),1,1,[]),cKStart,'uni',false);	
	
	%reformat to be 1 x time x channel x trial
	cD = cellfun(@(x) cat(3,x{:}),cD,'uni',false);
	cD = cellfun(@(x) permute(reshape(x,[1 size(x)]),[1,3,2,4]),cD,'uni',false);

	for k = 1:numel(cD)
		data{k}(kFreq,:,:,:) = cD{k};
	end

    %estimate time remaining
    tElap(kFreq) = toc(id);
    tRem = nanmean(tElap,1) * (nTotal-kFreq);

    %update the waitbar
    strMsg = sprintf('%02.0f%% done | %s remaining',(kFreq/nTotal)*100,FmtTime(tRem));
    waitbar(kFreq/nTotal,hWait,strMsg);
    drawnow;
end
%-----------------------------------------------------------------------------%
end