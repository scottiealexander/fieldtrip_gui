function Gui(varargin)

% FT.filter.Gui
%
% Description: get filtering parameters from user via a GUI
%
% Syntax: FT.filter.Gui
%
% In: 
%
% Out: 
%
% Updated: 2014-06-26
% Scottie Alexander
%
% See also: FT.filter.Run
%
% Please report bugs to: scottiealexander11@gmail.com


% FT.PeakFinder
%
% Description: 
%
% Syntax: FT.PeakFinder
%
% In: 
%
% Out: 
%
% Updated: 2013-09-05
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com
dbstop if error
global FT_DATA;

%make sure we have data...
if ~FT.tools.Validate('findpeaks','done',{'segment_trials'})
    return;
end


%get the window in which to find peaks
cfg = FT.trials.baseline.Gui('Peak & Valley Finder');

if isempty(cfg) || ~isfield(cfg,'baselinewindow')
    return;
end

FS = FT_DATA.data{1}.fsample;
window = round(cfg.baselinewindow*FS)+1; 

resp = FT.UserInput('\bfWould you like the output to be:\n1 file per-condition or\n1 file per-statistic?',...
                    1,'button',{'Condition','Statistic'},'title','Output Format');
if isempty(resp)
    return;
else
    bSingle = strcmpi(resp,'condition');
end

FT.UserInput('Please select an output directory.',1,'button','OK');
strDirOut = fileparts(FT_DATA.path.dataset);
strDirOut = uigetdir(strDirOut,'Select Output Directory');

if isequal(strDirOut,0)
    return;
end

params = struct('window',window,'bSingle',bSingle,'strDirOut',strDirOut);

hMsg = FT.UserInput('Finding peaks & valleys...',1);

me = FT.findpeaks.Run(params);

if ishandle(hMsg)
    close(hMsg);
end

FT.ProcessError(me);

FT.UpdateGUI;

end
