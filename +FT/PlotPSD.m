function PlotPSD()

% FT.PlotPSD
%
% Description: 
%
% Syntax: FT.PlotPSD
%
% In: 
%
% Out: 
%
% Updated: 2014-01-13
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;
persistent BASELINE;

if ~isfield(FT_DATA,'power') || isempty(FT_DATA.power)
	FT.UserInput('\bfPSD does not yet exist for this data set',0,'button','OK');
	return;
end

time = FT_DATA.power.time;

if isempty(BASELINE)
	cfg = FT.BaselineCorrect;
	BASELINE = cfg.baselinewindow;
	BASELINE = [find(time>=BASELINE(1),1,'first') find(time>=BASELINE(2),1,'first')];
end

cLabel = Ternary(iscell(FT_DATA.data),FT_DATA.data.label{1},FT_DATA.data.label);
data = cellfun(@(x) mean(x,4),FT_DATA.power.data,'uni',false);

pFig = GetFigPosition(1200,500);
h = figure('Units','pixels','Position',pFig,'Name','Spectrogram',...
		   'Menubar','none','NumberTitle','off');

%smoothing
f = fspecial('gaussian',[10 10], 3);

FT.PlotCtrl(h,cLabel,@PlotOne);

%-----------------------------------------------------------------------------%
function PlotOne(strChan)	
	bChan = strcmpi(strChan,cLabel);
	d = cellfun(@(x) BaselineCorr(x(:,:,bChan)),data,'uni',false);
	
	%get min and max across all conditions
	cMax = max(cellfun(@(x) max(reshape(x,[],1)),d));
	cMin = min(cellfun(@(x) min(reshape(x,[],1)),d));
	
	%position for each axes
	axPos = GetAxPosition(h,numel(d),'pad',60,'v_pad',30);

	for k = 1:numel(d)
		%get the labels for the x and y axes
		[xT,xTL] = GetAxLabels(time,7,'round',-1);
		[yT,yTL] = GetAxLabels(FT_DATA.power.centers,10,'space','log','round',0);

		%convert ticks to indicies
		yT = arrayfun(@(x) find(FT_DATA.power.centers>=x,1,'first'),yT);
		xT = arrayfun(@(x) find(time>=x,1,'first'),xT);

		%init the axes
		hAx = axes('Units','normalized','Position',axPos{k},'Parent',h);

		%add the image (flipud so that higher frequencies are up)
		image(flipud(d{k}),'CDataMapping','scaled','Parent',hAx);

		%add ticks and labels (flip y-labels to again, higher frequencies are up)
		set(hAx,'CLim',[cMin cMax],'XTick',xT,'XTickLabel',xTL,'YTick',yT,'YTickLabel',yTL(end:-1:1));
		
		%add the name of each condition
		set(get(hAx,'Title'),'String',FT_DATA.epoch{k}.name);
	end

	%colorbar
	hCol = colorbar('peer',hAx,'Location','EastOutside');
	set(hAx,'Position',axPos{end});

	%add channel to the figure name
	set(h,'Name',['Spectrogram: Channel ' strChan]);
end
%-----------------------------------------------------------------------------%
function d = BaselineCorr(d)
	m = repmat(mean(d(:,BASELINE(1):BASELINE(2)),2),1,size(d,2));
	d = (d - m) ./ m;
	d = imfilter(d,f,'replicate');
end
%-----------------------------------------------------------------------------%
end