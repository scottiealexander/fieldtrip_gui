function PlotPower(type)

% FT.PlotPower
%
% Description: 
%
% Syntax: FT.PlotPower
%
% In: 
%
% Out: 
%
% Updated: 2013-09-09
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

%make sure we have data...
if ~FT.CheckStage('plot_power')
    return;
end

%make sure segmentation has been done
if ~FT_DATA.done.segmentation
    FT.UserInput(['\color{red}This dataset has not been segmented!\n\color{black}'...
        'Please use:\n      \bfSegmentation->Segment Trials\rm\nbefore plotting power spectra.'],...
        0,'title','Segmentation Not Yet Performed','button','OK');
    return;
end

switch lower(type)
	case 'spectra'
		%calculate power spectra
% 		cfg = [];
% 		cfg.method = 'mtmfft';
% 		cfg.taper  = 'hanning';
% 		cfg.output = 'pow';
% 		cfg.foilim = [0 FT_DATA.data{1}.fsample/2];
% 		freq 	   = cellfun(@(x) ft_freqanalysis(cfg,x),FT_DATA.data,'uni',false);
        fprintf('Not yet implemented... SORRY!\n');

		%plot it

	case 'spectrogram'
        if isfield(FT_DATA,'spectrogram') && (isstruct(FT_DATA.spectrogram) || iscell(FT_DATA.spectrogram))
            str = ['Spectrograms have already been computed for this dataset.\n',...
                'What do you want to do?'];
            resp = FT.UserInput(str,1,'button',{'View','Re-calculate'},'title','Spectrogram');
            bCalc = strcmpi(resp,'re-calculate');
        else
            bCalc = true;
        end
        
        if bCalc
            %get parameters for frequency analysis            
            [cfg,base] = GetFreqParameters;
            if isempty(fieldnames(cfg))
                return;
            end

            hMsg = FT.UserInput('Calculating spectrogram using wavelet transform...',1);
                        
            cfg2.baseline = base;
            cfg2.baselinetype ='relative';
            cfg2.feedback = 'off';           
            
            %calculate time-frequency data            
            freq = cellfun(@(x) ft_freqbaseline(cfg2,ft_freqanalysis(cfg,x)),FT_DATA.data,'uni',false);            
            
            FT_DATA.spectrogram = freq;
            if ishandle(hMsg)
                close(hMsg);
            end
            
            FT.UserInput('Use the RIGHT and LEFT arrow keys to scroll through channels.',1,'title','Spectrogram','button','OK');
            
        else
            freq = FT_DATA.spectrogram;
        end
        
        kChan = 1;
        pMain = GetFigPosition(1200,400);
        cAxPos = GetAxPosition(numel(freq));
        h = figure('Units','pixels','Position',pMain);
        PlotSpectrogram;
        set(h,'KeyPressFcn',@KeyPressFreq);
	otherwise
		%this should never happen
end

%------------------------------------------------------------------------------%
function PlotSpectrogram
    %plot em
    cLIM = zeros(numel(freq),2);
    hA = NaN(numel(freq),1);
    for k = 1:numel(freq)
        hA(k) = subplot(1,numel(freq),k);
		pCfg              = [];
		pCfg.maskstyle    = 'saturation';
		pCfg.channel      = kChan;
		pCfg.interactive  = 'no';
		pCfg.renderer     = [];
        pCfg.trackcallinfo= false; %prevent status messages
		ft_singleplotTFR(pCfg, freq{k});
        set(get(hA(k),'XLabel'),'String','Time (sec)');
        set(get(hA(k),'YLabel'),'String','Frequency (Hz)');
        if k == numel(freq)
            hB = colorbar;
            set(get(hB,'YLabel'),'String','Power');
        end
        strTitle = get(get(hA(k),'Title'),'String');
        set(get(hA(k),'Title'),'String',[FT_DATA.epoch{k}.name '  ' strTitle]);
        set(hA(k),'Position',cAxPos{k});
        cLIM(k,:) = get(hA(k),'CLim');
    end
    cLIM = [min(cLIM(:,1)) max(cLIM(:,2))];
    set(hA,'cLim',cLIM);
end
%------------------------------------------------------------------------------%
function pos = GetAxPosition(n)
    pad = 75/1200;
    pad_total = pad*(n+1);
    w_ax = (1-pad_total)/3;
    pos = cell(n,1);
    left = pad;
    for kP = 1:n
        pos{kP} = [left .2 w_ax .7];
        left = left+w_ax+pad;
    end
end
%------------------------------------------------------------------------------%
function KeyPressFreq(obj,evt)
%allow the figure to be closed via Crtl+W shortcut
   switch lower(evt.Key)
       case 'w'
           if ismember(evt.Modifier,'control')
               if ishandle(h)
                   close(h);
               end
           end           
       case 'leftarrow'
           if kChan > 1
               kChan = kChan - 1;
           end
           PlotSpectrogram;
       case 'rightarrow'
           if kChan < numel(FT_DATA.data{1}.label)
               kChan = kChan + 1;
           end
           PlotSpectrogram;
       otherwise
   end
end
%------------------------------------------------------------------------------%
end
