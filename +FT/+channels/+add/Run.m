function me = Run(params)

% FT.channels.add.Run
%
% Description: add (create) new channels
%
% Syntax: me = FT.channels.add.Run(params)
%
% In:   params - a struct holding parameters from the user
%
% Out:  me - an empty matrix if processing finished with out error,
%            otherwise a MException object caught from the error
%
% Updated: 2014-08-12
% Peter Horak
%
% See also: FT.channels.add.Gui

global FT_DATA;
me = [];

try
    for k = 1:numel(params.cExp)
        if isempty(params.cExp{k})
            %skip ahead to next loop iteration
            continue;
        end
        %parse the equation and re-format calls to 'mean' to be compatible with Matlab 
        %syntax
        sChan = FT.channels.add.ParseEquation(params.cExp{k});

        %swap ch# convention with eval-able variable and index notation
        strExpr = regexprep(sChan.expr,'ch(\d+)','FT_DATA.data.trial{1}($1,:)');

        %perform the operation and add the new channel to the data
        newChan = eval(strExpr);
        FT_DATA.data.trial{1}(end+1,:) = newChan;

        %add the label for the new channel
        kChan = numel(FT_DATA.data.label)+1;
        FT_DATA.data.label{kChan} = sChan.label;
    end
catch me
end

%mark data as not saved
FT_DATA.saved = false;

%update the history
FT.tools.AddHistory('add_channel',params);
FT_DATA.done.add_channel = isempty(me);

end
