function ParseNLXEvents(varargin)
% ParseNLXEvents
%
% Description: convert neuralynx events into a usable format
%
% Syntax: ParseNLXEvents
%
% In:
%   options:
%       pulse_duration - (100) the duration of a event pulse in miliseconds as
%                        defined in the SuperLab pulse event
%       pulse_interval - (50) the interpulse interval in miliseconds as defined
%                        in the SuperLab pulse event
%
% Out:
%
% Updated: 2014-07-15
% Scottie Alexander
%
% Please send bu reports to: scottiealexander11@gmail.com

global FT_DATA;

TIME_ERROR = 1; %experically determined maximum error in miliseconds

opt = FT.ParseOpts(varargin ,...
    'pulse_duration' , 100  ,...
    'pulse_interval' , 50    ...
    );

if numel(FT_DATA.event) > 1
	evt = FT.ReStruct(FT_DATA.event);
end

bKeep = evt.value>0;

evt = FT.tools.structfieldfun(@(x) x(bKeep),evt);

%maximum time between pulses of the same pulse series (convert times to
%microseconds and add the error (*2 for pre and post))
durPulse = opt.pulse_duration + opt.pulse_interval + (TIME_ERROR*2);

durPulse = (durPulse/1000) * FT_DATA.data.fsample;

%get the elasped time between each pulse and the following pulse (note: the last
%event is left out because it has no following event)
dtEvt  = diff(evt.sample);

%find events whose following event occured greater than durPulse microseconds
%(i.e. the last pulse in a pulse series)
b = dtEvt>durPulse;

%get the times of the last pulse in each series (the last pulse is by definition
%the last puse in a pulse series and diff will miss it because it has no
%following event)
kOnset = [evt.sample(b);evt.sample(end)];

%get the times of the first pulse in eveny pulse series (i.e. the pulse after
%each pulse that we found above)
kStart = [evt.sample(1);evt.sample(find(b)+1)];

%count the number of pulses that occured between the first and last pulse of
%each pulse series (i.e. the code represented by the pulse series)
nPulse = arrayfun(@(x,y) sum(evt.sample >= x & evt.sample <= y),kStart,kOnset);

evt = FT.tools.structfieldfun(@(x) [x(b);x(end)],evt);
evt.value = nPulse;
FT_DATA.event = FT.ReStruct(evt);
FT_DATA.data.cfg.event = FT.ReStruct(evt);
