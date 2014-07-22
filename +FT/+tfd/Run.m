function me = Run(params)

% FT.tfd.Run
%
% Description:  time-frequency decomposition based on specified method
%
% Syntax: me = FT.tfd.Run(params)
%
% In: 
%       params - a struct holding parameters from the user for performing
%                the time-frequency decomposition
%             see 'FT.tfd.Gui'
%
% Out:
%       me - an empty matrix if processing finished with out error, otherwise a
%            MException object caught from the error
%
% Updated: 2014-06-23
% Peter Horak
%
% See also: FT.tfd.Gui
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA
me = [];

try
    switch lower(params.method)
        case 'hilbert'
            FT.tfd.HilbertPSD(params);
        case 'wavelet'
            % Wavelet
        case 'stft'
            FT.tfd.FourierPSD(params);
        otherwise
            %shouldn't ever happen
            return;
    end
    %remove the data field to save memory
%     FT_DATA = rmfield(FT_DATA,'data');
    FT.segment.Run(FT_DATA.epoch);

    if params.surrogate && (params.nsurrogate > 0)
        FT.tfd.Surrogate(params.nsurrogate);
    end
catch me;
end

%mark data as not saved
FT_DATA.saved = false;

%update the history
FT.tools.AddHistory('tfd',params);
FT_DATA.done.tfd = isempty(me);

end