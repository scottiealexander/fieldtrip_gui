function me = Run(params)

% FT.channels.remove.Run
%
% Description: remove channels
%
% Syntax: me = FT.channels.remove.Run(params)
%
% In:   params - a struct holding parameters from the user
%
% Out:  me - an empty matrix if processing finished with out error,
%            otherwise a MException object caught from the error
%
% Updated: 2014-07-18
% Peter Horak
%
% See also: FT.channels.remove.Gui

global FT_DATA;
me = [];

% Channels to keep
ch = ~params.ch_rem;

try
    if ~params.segmented
        FT_DATA.data.trial{1} = FT_DATA.data.trial{1}(ch,:);
        FT_DATA.data.label = FT_DATA.data.label(ch);
    else
        for i = 1:numel(FT_DATA.data)
            FT_DATA.data{i}.trial = cellfun(@(x) x(ch,:),FT_DATA.data{i}.trial,'uni',false);
            FT_DATA.data{i}.label = FT_DATA.data{i}.label(ch);
        end
    end
catch me
end

%mark data as not saved
FT_DATA.saved = false;

%update the history
FT.tools.AddHistory('remove_channel',params);
FT_DATA.done.remove_channel = isempty(me);

end
