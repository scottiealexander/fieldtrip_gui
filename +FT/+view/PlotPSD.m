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
% Updated: 2014-10-10
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com


global FT_DATA;
persistent BASELINE NORM_TYPE;

%make sure we are ready to run
if ~FT.tools.Validate('plot_psd','done',{'tfd'})
    return;
end

time = FT_DATA.power.time;

if isfield(FT_DATA.power,'surrogate')
	NORM_TYPE = FT.UserInput('Normalization method?',1,'button',{'z-score','baseline'});
	if isempty(NORM_TYPE)
		return;
	end
else
	NORM_TYPE = 'baseline';
end

if strcmpi(NORM_TYPE,'baseline')% && isempty(BASELINE)
	NORM_TYPE = 'baseline';	
	cfg = FT.trials.baseline.Gui;
    if ~isfield(cfg,'baselinewindow')
        NORM_TYPE = 'none';
% 		return;
    else
        BASELINE = cfg.baselinewindow;
        BASELINE = [find(time>=BASELINE(1),1,'first') find(time>=BASELINE(2),1,'first')];
    end
end


cLabel = FT_DATA.power.label;
data = cellfun(@(x) mean(x,4),FT_DATA.power.data,'uni',false);

wFig = numel(FT_DATA.power.data)*FT.tools.Inch2Px(5);
hFig = FT.tools.Inch2Px(6);
pFig = FT.tools.GetFigPosition(wFig,hFig,'xoffset',FT.tools.Inch2Px(1));
h = figure('Units','pixels','Position',pFig,'Name','Spectrogram',...
		   ...'Menubar','none',...
           'NumberTitle','off');

%smoothing
f = fspecial('gaussian',[10 10], 3);

[~,hctrl] = FT.view.PlotCtrl(h,cLabel,@PlotOne);
uiwait(hctrl);

%-----------------------------------------------------------------------------%
function PlotOne(strChan)	
	bChan = strcmpi(strChan,cLabel);

	if strcmpi(NORM_TYPE,'z-score')
		kChan = find(bChan);
        d = cell(size(data));
        for k = 1:numel(data)
            d{k} = surrogate_norm(data{k}(:,:,kChan),k,kChan);
        end
    elseif strcmpi(NORM_TYPE,'baseline')
		d = cellfun(@(x) BaselineCorr(x(:,:,bChan)),data,'uni',false);
    else
        d = cellfun(@(x) x(:,:,bChan),data,'uni',false);
	end
	
	%get min and max across all conditions
	cMax = max(cellfun(@(x) max(reshape(x,[],1)),d));
	cMin = min(cellfun(@(x) min(reshape(x,[],1)),d));
	
	%position for each axes
	axPos = FT.tools.GetAxPosition(h,numel(d),'pad',75,'v_pad',30);

	for k = 1:numel(d)		
        
		%init the axes
		hAx = axes('Units','normalized','Position',axPos{k},'Parent',h);		

		%init the spectogram image (flipud so higher frequencies are up)
		image(flipud(d{k}),'CDataMapping','scaled','Parent',hAx);

		%set x and y labels
		[xT,xTL] = FT.tools.GetAxLabels(FT_DATA.power.time,7,'round',-1);
		[yT,yTL] = FT.tools.GetAxLabels(FT_DATA.power.centers,10,'round',0);
        
        %in case the data is NaN
        if isnan(cMin) || isnan(cMax)
            set(hAx,'XTick',xT,'XTickLabel',xTL,'YTick',yT,'YTickLabel',yTL(end:-1:1));
        else
            set(hAx,'CLim',[cMin cMax],'XTick',xT,'XTickLabel',xTL,'YTick',yT,'YTickLabel',yTL(end:-1:1));
        end

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
	m = mean(d(:,BASELINE(1):BASELINE(2)),2);

	%avoid dividing by 0
	m(m==0) = 1;
	m = repmat(m,1,size(d,2));
	
	d = (d - m) ./ abs(m);
	d = imfilter(d,f,'replicate');
end
%-----------------------------------------------------------------------------%
function d = surrogate_norm(d,kCond,kChan)	
	m  = FT_DATA.power.surrogate.mean{kCond}(:,:,kChan);
	sd = FT_DATA.power.surrogate.std{kCond}(:,:,kChan);
	d = (d - m) ./ sd;
    d = imfilter(d,f,'replicate');
end
%-----------------------------------------------------------------------------%
end
