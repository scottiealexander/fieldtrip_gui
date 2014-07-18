function me = Run(params)

% FT.reject.Run
%
% Description: remove trials
%
% Syntax: me = FT.reject.Run(params)
%
% In:   params - a struct holding parameters from the user
%
% Out:  me - an empty matrix if processing finished with out error,
%            otherwise a MException object caught from the error
%
% Updated: 2014-07-18
% Peter Horak
%
% See also: FT.reject.Gui

global FT_DATA;
me = [];

try
    tr = ~params.tr_rem;
    c = params.condition;
    
    
    evt_tr = [];
    for i = 1:numel(FT_DATA.epoch)
        if i == c
            evt_tr = cat(1,evt_tr,c);
        else
            evt_tr = cat(1,evt_tr,true(size(FT_DATA.epoch{i}.trl,1),1));
        end
    end
    FT_DATA.event = FT_DATA.event(evt_tr);
    
    FT_DATA.epoch{c}.trl = FT_DATA.epoch{c}.trl(tr,:);
    FT_DATA.data{c}.trial = FT_DATA.data{c}.trial(tr);
    
    if isfield(FT_DATA.done,'tfd') && FT_DATA.done.tfd
        FT_DATA.power.data{c} = FT_DATA.power.data{c}(:,:,:,tr);
    end    
catch me
end

%mark data as not saved
FT_DATA.saved = false;

%update the history
FT.tools.AddHistory('reject_trials',params);
FT_DATA.done.reject_events = isempty(me);

end
