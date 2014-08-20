function Gui()

% FT.average.Gui
%
% Description: check the stage and then average trials
%
% Syntax: FT.average.Gui
%
% In: 
%
% Out:
%
% Updated: 2014-08-20
% Peter Horak
%
% See also: FT.average.Run

params = [];

%check if averaging has already been preformed
if ~FT.tools.Validate('average','done',{'segment_trials'},'todo',{'average'})
    return;
end

hMsg = FT.UserInput('Making average ERPs...',1);

me = FT.average.Run(params);

if ishandle(hMsg)
    close(hMsg);
end

FT.ProcessError(me);

FT.UpdateGUI;

end
