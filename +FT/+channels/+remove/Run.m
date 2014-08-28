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

try
    % Channels to keep
    ch = ~ismember(FT_DATA.data.label,params.remove);
    
    % Remove channels
    FT_DATA.data.trial{1} = FT_DATA.data.trial{1}(ch,:);
    FT_DATA.data.label = FT_DATA.data.label(ch);
catch me
end

%mark data as not saved
FT_DATA.saved = false;

%update the history
FT.tools.AddHistory('remove_channels',params);
FT_DATA.done.remove_channels = isempty(me);

end
