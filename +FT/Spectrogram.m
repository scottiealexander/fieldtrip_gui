function Spectrogram()

% FT.Spectrogram
%
% Description: 
%
% Syntax: FT.Spectrogram
%
% In: 
%
% Out: 
%
% Updated: 2013-09-05
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

cfg = [];
cfg.channel    = 'all';
cfg.method     = 'wavelet';                
cfg.width      = 7; 
cfg.output     = 'pow';	
cfg.foi        = 1:2:30;	                
cfg.toi        = min(FT_DATA.data.time{1}):0.05:max(FT_DATA.data.time{1});
freq = ft_freqanalysis(cfg, FT_DATA.data);


cfg              = [];
cfg.maskstyle    = 'saturation';
cfg.channel      = 1;
cfg.interactive  = 'no';
cfg.renderer     = 'opengl';
figure
ft_singleplotTFR(cfg, freq);

cfg = [];
cfg.method = 'mtmfft';
cfg.taper = 'hanning';
cfg.output = 'pow';
cfg.foilim = [30 80];
freq2 = ft_freqanalysis(cfg,FT_DATA.data);