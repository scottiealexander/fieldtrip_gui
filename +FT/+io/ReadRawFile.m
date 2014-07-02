function ReadRawFile(strPath,strType)
% ReadRawFile
%
% Description: read a raw EEG file
%
% Syntax: ReadRawFile(strPath,strType)
%
% In:
%       strPath - the path to a raw EEG file (.eeg, .bdf etc.)
%       strType - the type/file extension for the data file
%
% Out: 
%
% Updated: 2014-06-27
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

%read data from raw eeg file
cfg = FT.tools.CFGDefault;
cfg.dataset    = strPath;
cfg.continuous = 'yes';

if ~strcmpi(strType,'edf')

    cfg.trialdef.triallength = Inf;
    cfg = ft_definetrial(cfg);
    evt = FT.ReStruct(cfg.event);

    if iscell(evt.value)
        bEmpty = cellfun(@isempty,evt.value);
        evt    = structfieldfun(@(x) x(~bEmpty),evt);
        bNum   = cellfun(@isnumeric,evt.value);
        if ~any(bNum)
            evt.value(cellfun(@isempty,evt.value)) = {''};
            evt.value = cellfun(@(x) regexprep(x,'\s+',''),evt.value,'uni',false);
        elseif all(bNum)
            evt.value(cellfun(@isempty,evt.value)) = {NaN};
            evt.value = cat(1,evt.value{:});
        else
           error('Poorly formated event code values. Please contact the developer with the circumstances of this error'); 
        end
    end

    FT_DATA.event = FT.ReStruct(evt);
    FT_DATA.done.read_events = true;
end

FT_DATA.data = ft_preprocessing(cfg);

if strcmpi(ext,'nlx')
    nlx_parse_events;
end
