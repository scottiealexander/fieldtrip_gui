function AverageERP(varargin)

% FT.AverageERP
%
% Description: calculate average ERP for a single dataset
%
% Syntax: FT.AverageERP
%
% In: 
%
% Out: 
%
% Updated: 2013-08-30
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

%check if averaging has already been preformed
if ~FT.CheckStage('average')
    return;
end

%make sure segmentation has been done
if ~FT_DATA.done.segmentation
    FT.UserInput(['\color{red}This dataset has not been segmented!\n\color{black}'...
        'Please use:\n      \bfSegmentation->Segment Trials\rm\nbefore averaging.'],...
        0,'title','Segmentation Not Yet Performed','button','OK');
    return;
end
hMsg = FT.UserInput('Making average ERPs',1);

for k = 1:numel(FT_DATA.data)

	fs = FT_DATA.data{k}.fsample;

	%get data as a nchannel x nsample x ntrial matrix
	d = reshape(FT_DATA.data{k}.trial,1,1,[]);
	tMax = max(cellfun(@(x) size(x,2),d));
	d = cellfun(@(x) [x nan(size(x,1),tMax-size(x,2))],d,'uni',false);
	d = cat(3,d{:});

	%perform the averaging
	cfg = CFGDefault;
	cfg.vartrllength = 2; %allow variable length trials, just use nans

	FT_DATA.data{k} = ft_timelockanalysis(cfg,FT_DATA.data{k});

	%caclulate standard err (std(data) / sqrt(sum(data))
	stdev = sqrt(FT_DATA.data{k}.var);
	n	  = sum(~isnan(d),3);
	FT_DATA.data{k}.err = stdev./sqrt(n);

	%add sampling rate back in
	FT_DATA.data{k}.fsample = fs;
end

if ishandle(hMsg)
    close(hMsg);
end
%update history and gui
FT_DATA.done.average = true;
FT_DATA.saved = false;
FT.UpdateGUI;
end