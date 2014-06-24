function me = Run(cfg)

% FT.resample.Run
%
% Description: resample data and events
%
% Syntax: me = FT.resample.Run(cfg)
%
% In: 
%       cfg - a fieldtrip configuration struct holding the resampling parameters
%             see 'FT.resample.gui'
%
% Out:
%       me - an empty matrix if resampling finished without an error, otherwise a
%            MException object caught from the error
%
% Updated: 2014-06-23
% Peter Horak
%
% See also: FT.resample.Gui
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;
me = [];

%cannot resample segmented data
if numel(FT_DATA.data.trial)~=1
    me = MException('FT:resample','Error using FT.resample.Run\nCannot resample segmented data.');
else
    try
        %resample the data
        FT_DATA.data = ft_resampledata(cfg,FT_DATA.data);

        %resample events if they exist
        ResampleEvents;

        %fix trialdef
        FT_DATA.data.sampleinfo = [1 size(FT_DATA.data.trial{1},2)];
        [~,FT_DATA.data.cfg] = FT.EditCfg(FT_DATA.data.cfg,'set','trl',[FT_DATA.data.sampleinfo 0]);
    catch me
    end
end


%mark data as not saved
FT_DATA.saved = false; 

%update the history
FT.tools.AddHistory('resample',cfg);
FT_DATA.done.resample = FT.tools.Ternary(isempty(me),true,false);

%------------------------------------------------------------------------------%
function ResampleEvents
%resample event indicies according to new sampling rate
    if isfield(FT_DATA,'event') && ~isempty(FT_DATA.event)
        fs_ratio = FT_DATA.data.fsample/FT_DATA.data.hdr.Fs;
        evt = FT.ReStruct(FT_DATA.event);
        evt.sample = ceil(evt.sample*fs_ratio);
        FT_DATA.event = FT.ReStruct(evt);
        FT_DATA.data.cfg.event = FT_DATA.event;
    else
        %events have not been read, nothing to do
    end
end
%------------------------------------------------------------------------------%
end