function Gui(varargin)

% FT.channels.remove.Gui
%
% Description: inspect channels and mark for removal
%
% Syntax: FT.channels.remove.Gui
%
% In: 
%
% Out: 
%
% Updated: 2014-07-18
% Peter Horak
%
% See also: FT.channels.remove.Run

global FT_DATA;

%make sure we are ready to run
% *** could potentially remove channels even after averaging
if ~FT.tools.Validate('remove_channels','todo',{'segment_trials','tfd','average'})
    return;
end

ch_rem = FT.tools.DataBrowser(FT_DATA.data.time{1},FT_DATA.data.trial{1},'trial',4,FT_DATA.data.label);
params.remove = FT_DATA.data.label(ch_rem);

if ~isempty(params.remove)
    hMsg = FT.UserInput('Removing channels...',1);

    me = FT.channels.remove.Run(params);

    if ishandle(hMsg)
        close(hMsg);
    end

    FT.ProcessError(me);
end

FT.UpdateGUI;

end
