function me = Run(cfg)

% FT.filter.Run
%
% Description: run filtering
%
% Syntax: me = FT.filter.Run(cfg)
%
% In: 
%       cfg - a fieldtrip configuration struct holding the filtering parameters
%             see 'FT.filter.gui'
%
% Out:
%       me - an empty matrix if filtering finished with out error, otherwise a
%            MException object caught from the error
%
% Updated: 2014-03-31
% Scottie Alexander
%
% See also: FT.filter.Gui
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

%NOTE we are doing this in series to avoid errors thrown by ft_preprocessing
%when both hpfilter and lpfilter are specified and hpfreq < ~1Hz
me = [];
cFilt = {'hpfilter','lpfilter','dftfilter'};
bRun = cellfun(@(x) strcmpi(cfg.(x),'yes'),cFilt);
nFilt = numel(cFilt);

for kA = 1:nFilt
    for kB = 1:nFilt
        cfg.(cFilt{kB}) = 'no';
    end
    if bRun(kA)
        cfg.(cFilt{kA}) = 'yes';
        try
            if ~strcmpi(cfg.channel,'all')            
                %only filter specified channels
                datTmp = ft_preprocessing(cfg,FT_DATA.data);
                
                %replace orig channels with result of filtering
                bNew = ismember(FT_DATA.data.label,datTmp.label);
                FT_DATA.data.trial{1}(bNew,:) = datTmp.trial{1};
            else
                %filter everything
                FT_DATA.data = ft_preprocessing(cfg,FT_DATA.data);
            end
        catch me
        end
    end
end

for k = 1:nFilt
    cfg.(cFilt{k}) = FT.tools.Ternary(bRun(k),'yes','no');
end

%mark data as not saved
FT_DATA.saved = false;

%update the history
FT.tools.AddHistory('filter',cfg);
FT_DATA.done.filter = FT.tools.Ternary(isempty(me),true,false);