function Gui(varargin)

% FT.findpeaks.Gui
%
% Description: get parameters for finding peaks and valleys
%
% Syntax: FT.findpeaks.Gui
%
% In: 
%
% Out: 
%
% Updated: 2014-09-23
% Peter Horak
%
% See also: FT.findpeaks.Run

global FT_DATA;

% make sure we are ready to run this analysis
if ~FT.tools.Validate('findpeaks','done',{'segment_trials'})
    return;
end

% get the window in which to find peaks
cfg = FT.trials.baseline.Gui('Peak & Valley Finder');

if isempty(cfg) || ~isfield(cfg,'baselinewindow')
    return; % user selected cancel
end

FS = FT_DATA.data{1}.fsample; % sample frequency
PRE = FT_DATA.epoch{1}.ifo.pre; % offset of event from trial start
window = round((cfg.baselinewindow+PRE)*FS)+1; % convert window from secs to samples

% select output format
resp = FT.UserInput('\bfWould you like the output to be:\n1 file per-condition or\n1 file per-statistic?',...
                    1,'button',{'Condition','Statistic','Cancel'},'title','Output Format');
if isempty(resp) || strcmpi(resp,'cancel')
    return; % user selected cancel
else
    bSingle = strcmpi(resp,'condition');
end

% get the output directory
strDirOut = fileparts(FT_DATA.path.base_directory);
strDirOut = uigetdir(strDirOut,'Select Output Directory');

if isequal(strDirOut,0)
    return; % user selected cancel
end

params = struct('window',window,'bSingle',bSingle,'strDirOut',strDirOut);

% find peaks
hMsg = FT.UserInput('Finding peaks & valleys...',1);
me = FT.findpeaks.Run(params);
if ishandle(hMsg)
    close(hMsg);
end

FT.ProcessError(me);

FT.UpdateGUI;

end
