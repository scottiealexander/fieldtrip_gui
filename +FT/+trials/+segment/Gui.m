function Gui()

% FT.trials.segment.Gui
%
% Description: check the stage and then segment trials
%
% Syntax: FT.trials.segment.Gui
%
% In: 
%
% Out:
%
% Updated: 2014-07-22
% Peter Horak
%
% See also: FT.trials.segment.Run

params = [];

%make sure we are ready to run
if ~FT.tools.Validate('segment_trials','done',{'read_events','define_trials'},'todo',{'segment_trials'})
    return;
end

hMsg = FT.UserInput('Segmenting trials...',1);

me = FT.trials.segment.Run(params);

if ishandle(hMsg)
    close(hMsg);
end

FT.ProcessError(me);

FT.UpdateGUI;

end
