function me = Run(params)

% FT.average.Run
%
% Description: calculate average ERP for a single dataset
%
% Syntax: me = FT.average.Run(params)
%
% In:   params - a struct holding parameters from the user
%
% Out:  me - an empty matrix if processing finished with out error,
%            otherwise a MException object caught from the error
%
% Updated: 2014-03-30
% Scottie Alexander
%
% See also: FT.average.Gui

global FT_DATA
me = [];

try
    for k = 1:numel(FT_DATA.data)

        fs = FT_DATA.data{k}.fsample;

        %get data as a nchannel x nsample x ntrial matrix
        d = reshape(FT_DATA.data{k}.trial,1,1,[]);
        tMax = max(cellfun(@(x) size(x,2),d));
        d = cellfun(@(x) [x nan(size(x,1),tMax-size(x,2))],d,'uni',false);
        d = cat(3,d{:});

        %perform the averaging
        cfg = FT.tools.CFGDefault;
        cfg.vartrllength = 2; %allow variable length trials, just use nans

        FT_DATA.data{k} = ft_timelockanalysis(cfg,FT_DATA.data{k});

        %caclulate standard err (std(data) / sqrt(sum(data))
        stdev = sqrt(FT_DATA.data{k}.var);
        n	  = sum(~isnan(d),3);
        FT_DATA.data{k}.err = stdev./sqrt(n);

        %add sampling rate and raw data back in
        FT_DATA.data{k}.fsample = fs;
        FT_DATA.data{k}.raw = d;
    end
catch me
end

%mark data as not saved
FT_DATA.saved = false;

%update history
FT.tools.AddHistory('average',params);
FT_DATA.done.average = isempty(me);

end