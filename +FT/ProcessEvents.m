function ProcessEvents(varargin)

% FT.ProcessEvents
%
% Description: read events from file into the FT_DATA struct
%
% Syntax: FT.ProcessEvents
%
% In: 
%
% Out: 
%
% Updated: 2013-08-14
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;
 
if ~FT.CheckStage('read_events')
    return;
end

%get file format
[~,~,ext] = fileparts(FT_DATA.path.raw_file);
ext = strrep(ext,'.','');

%convert code pulses to events if need be
if strcmpi(ext,'edf')    
    %auto convert pulses to events
    FT.DetectEvents;
    
    %make sure struct is Nx1 array of structs to be consistent with
    %ft_definetrial (below)
    if numel(FT_DATA.event) == 1
        FT_DATA.event = FT.ReStruct(FT_DATA.event);
    end
    FT_DATA.data.cfg.event = FT_DATA.event;
elseif ~isfield(FT_DATA,'event') || isempty(FT_DATA.event)    
    hMsg = FT.UserInput('Reading events, please wait...',1);
    
    %use fieldtrip's ft_definetrial
    cfg.trialdef.triallength = Inf;
    cfg.dataset = s.path.raw_file;
    cfg = ft_definetrial(cfg);
    FT_DATA.event = cfg.event;
    
    if ishandle(hMsg)
        close(hMsg);
    end
    
    FT_DATA.done.read_events = true;
    FT_DATA.saved = false;
    FT.UpdateGUI;
else
   %nothing to do
end
