function Test(method)

% FT.tfd.Test
%
% Description: test FT.tfd.Run on a known dataset (TEST.set). The
% dataset must be loaded before running the tests.
%
% Syntax: FT.tfd.Test
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
FS = FT_DATA.data.fsample;
TOLERANCE = 10; % +/-10Hz

fnyq = floor(FS/2);
params = struct('lo',5,'hi',fnyq,'n',42,'w',10,'log',true,'surrogate',false,'nsurrogate',10);
params.method = method;

% check for errors running the frequency decomposition
% [~,me] = evalc('FT.tfd.Run(params);');
me = FT.tfd.Run(params);
FT.tools.Log(me);

freq = FT_DATA.power.centers;

% start & end freq within 10Hz of target and right number of freq bins
FT.tools.Log(abs(freq(1)-params.lo) < TOLERANCE);
if strcmpi('Hilbert',method)
    FT.tools.Log(abs(freq(end)-(params.hi-1)/(1+params.w/100)) < TOLERANCE);
else
    FT.tools.Log(abs(freq(end)-params.hi) < TOLERANCE);
end
FT.tools.Log(size(FT_DATA.power.data{1},1) == params.n);

% % did generate surrogate data
% FT.tools.Log(~isempty(FT_DATA.power.surrogate));

% 1st condition, 1st channel (50Hz), trial 1/3
psd = mean(FT_DATA.power.data{1}(:,:,1,1),2);
i = find(psd==max(psd),1,'first');
FT.tools.Log(abs(freq(i)-50) < TOLERANCE);

% 2nd condition, 2nd channel (noisy 50Hz), trial 3/3
psd = mean(FT_DATA.power.data{2}(:,:,2,3),2);
i = find(psd==max(psd),1,'first');
FT.tools.Log(abs(freq(i)-50) < TOLERANCE);

% 2nd condition, 3nd channel (50Hz & 90Hz), trial 6/6
psd = mean(FT_DATA.power.data{2}(:,:,3,6),2);
i = find(psd==max(psd),1,'first');
FT.tools.Log(abs(freq(i)-90) < TOLERANCE);

% 3rd condition, 5th channel (steps in freq), trial 1/1
psd = FT_DATA.power.data{3}(:,:,5,1);
avg = (psd(:,end)+psd(:,1))/2;
dff = (psd(:,end)-psd(:,1));
i = find(avg==max(avg),1,'first');
j = find(dff==max(dff),1,'first');
FT.tools.Log(abs(freq(i)-8) < TOLERANCE);
FT.tools.Log(abs(freq(j)-90) < TOLERANCE);

end

