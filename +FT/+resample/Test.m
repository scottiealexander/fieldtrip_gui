function Test

% FT.resample.Test
%
% Description: test FT.resample.Run on a known dataset (TEST.set). The
% dataset must be loaded before running the tests.
%
% Syntax: FT.resample.Test
%
% In: 
%
% Out:
%
% Updated: 2014-06-26
% Peter Horak
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

%resample to 250Hz
params = struct('resamplefs',400);
    
%check for errors/exceptions
me = FT.resample.Run(params);
FT.tools.Log(me);

%check that resampling worked as expected
t = FT_DATA.data.time{1};
FT.tools.Log(FT_DATA.data.fsample==400);
FT.tools.Log(round(1/median(diff(t)))==400);
FT.tools.Log(numel(t)==4000);
FT.tools.Log(mean(abs(sin(100*pi*t)-FT_DATA.data.trial{1}(1,:))) < 1e-3);

end

