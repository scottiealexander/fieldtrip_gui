function freq = Test()

% Test
%
% Description: 
%
% Syntax: Test
%
% In: 
%
% Out: 
%
% Updated: 2013-10-29
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

cfg = [];
cfg.method = 'mtmfft';
cfg.taper  = 'hanning';
cfg.output = 'pow';
cfg.foilim = [0 FT_DATA.data{1}.fsample/2];
freq 	   = cellfun(@(x) ft_freqanalysis(cfg,x),FT_DATA.data,'uni',false);