function SurrogatePSD(cData,nIter)

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

nTrial = cellfun(@(x) size(x,4),FT_DATA.power.data);
trl = numel(FT_DATA.power.time);
% data_length  = size(cData{1},2);
data_length  = size(FT_DATA.data.trial{1},2);

kStart = nan(sum(nTrial),1);
pnts = 1:(data_length-trl);
time = nan(sum(nTrial),1);
for k = 1:sum(nTrial)
	id = tic;
	srt = pnts(randi(numel(pnts),1));
	time(k,1) = toc(id);
	bRM = pnts > srt-trl & pnts < srt+trl;
	pnts(bRM) = [];
	kStart(k) = srt;
end

%-----------------------------------------------------------------------------%
function DoOne(d)

	%scramble the phases
	d = phaseran2(d);

	%randomly extract trials for each condition

	%make average matrix for each condition

	%add to the collection
end
%-----------------------------------------------------------------------------%
end