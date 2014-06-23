function me = Run(cfg)

% FT.reference.Run
%
% Description: rereference data
%
% Syntax: me = FT.rereference.Run(cfg)
%
% In: 
%       cfg - a fieldtrip configuration struct holding the rereferencing parameters
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

try
    FT_DATA.data = ft_preprocessing(cfg, FT_DATA.data);
catch me
end

%mark data as not saved
FT_DATA.saved = false;

%update the history
FT.tools.AddHistory('rereference',cfg);
FT_DATA.done.rereference = FT.tools.Ternary(isempty(me),true,false);
