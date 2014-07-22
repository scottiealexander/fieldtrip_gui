function me = Run(params)

% FT.reference.Run
%
% Description: rereference data
%
% Syntax: me = FT.rereference.Run(params)
%
% In: 
%       params - a struct holding the rereferencing parameters from the user
%             see 'FT.rereference.gui'
%
% Out:
%       me - an empty matrix if rereferenced successfully, otherwise a
%            MException object caught from the error
%
% Updated: 2014-06-23
% Peter Horak
%
% See also: FT.reference.Gui
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;
me = [];

cfg = FT.tools.CFGDefault(params);
cfg.reref       = 'yes'; %we want to rereference
cfg.channel     = 'all'; %channels to reref, all of course
cfg.implicitref = [];    %the implicit (non-recorded) reference channel is added to the data representation (we'll have to figure out what this is if any)

try
    FT_DATA.data = ft_preprocessing(cfg, FT_DATA.data);
catch me
end

%mark data as not saved
FT_DATA.saved = false;

%update the history
FT.tools.AddHistory('rereference',params);
FT_DATA.done.rereference = isempty(me);
