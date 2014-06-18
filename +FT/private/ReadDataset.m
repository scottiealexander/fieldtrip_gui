function ReadDataset(strPath)

% ReadDataset
%
% Description: read dataset or datafile from disk
%
% Syntax: ReadDataset
%
% In: 
%
% Out: 
%
% Updated: 2013-08-14
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA

%get extension
[~,~,ext] = fileparts(strPath);
ext = regexprep(ext,'^\.','');

if any(strcmpi(ext,{'mat','set'}))
    hMsg = FT.UserInput('Reading data from file, plese wait...',1);    

    %load FiledTripGUI dataset file
    sTmp = load(strPath,'-mat');
    cFields = fieldnames(sTmp);
    
    tmp_gui = FT_DATA.gui;
    
    %merge with the FT_DATA struct
    for k = 1:numel(cFields)
        FT_DATA.(cFields{k}) = sTmp.(cFields{k});
    end
        
    FT_DATA.gui.hAx = tmp_gui.hAx;
    FT_DATA.gui.hText = tmp_gui.hText;
    FT_DATA.gui.sizText = tmp_gui.sizText;
    FT_DATA.gui.screen_size = tmp_gui.screen_size;
    
    clear('sTmp','tmp_gui'); %clean up

    if ishandle(hMsg)
        close(hMsg);
    end
else
    %read data from raw eeg file
    cfg = CFGDefault;
    cfg.dataset    = FT_DATA.path.raw_file;
    cfg.continuous = 'yes';    
    if ~strcmpi(ext,'edf')
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

    hMsg = FT.UserInput('Reading data from file, plese wait...',1);

    FT_DATA.data = ft_preprocessing(cfg);
    
    if ishandle(hMsg)
        close(hMsg);
    end

    if strcmpi(ext,'edf')
        resp = FT.UserInput(['\bf[\color{red}WARNING\color{black}]\n',...
                    'It is highly recomended that you process events\n',...
                    'BEFORE preprocessing EDF files.\n\nWould you like to process events now?'],...
                    1,'button',{'Yes','No'},'title','WARNING!');
        switch lower(resp)
            case 'yes'
                FT.ProcessEvents;
            case 'no'
                FT.UserInput(['\bf[\color{red}WARNING\color{black}]\n',...
                    'Make SURE you process event BEFORE resampling!'],...
                    1,'button','OK','title','WARNING!');
        end
    elseif isempty(ext)
        nlx_parse_events;        
    end
end
