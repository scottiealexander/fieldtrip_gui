function Test

% FT.rereference.Test
%
% Description: test FT.rereference.Run on a known dataset (TEST.set). The
% dataset must be loaded before running the tests.
%
% Syntax: FT.rereference.Test
%
% In: 
%
% Out:
%
% Updated: 2014-06-27
% Peter Horak
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;
N = numel(FT_DATA.data.time{1});

% filter parameters
params = struct('refchannel','step5');
me = FT.rereference.Run(params);
FT.tools.Log(me);

% the channel used as reference should have no signal
step5 = FT_DATA.data.trial{1}(5,:);
FT.tools.Log(abs(mean(step5)) < 1e-6);
FT.tools.Log(var(step5) < 1e-6);

% the DC segment of step5 should shift the mean of the other channels
sin50 = FT_DATA.data.trial{1}(1,:);
FT.tools.Log(abs(mean(sin50(ceil(N*4.1/5):floor(N*4.9/5)))+1) < 1e-3);

end

