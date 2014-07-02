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
% Updated: 2014-06-27
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA

%get extension
[~,~,ext] = fileparts(strPath);
ext = regexprep(ext,'^\.','');

if any(strcmpi(ext,{'mat','set'}))    
    FT.io.ReadSetFile(strPath);
else
    FT.io.ReadRawFile(strPath,ext);
end

%     %read data from raw eeg file
%     cfg = FT.tools.CFGDefault;
%     cfg.dataset    = FT_DATA.path.raw_file;
%     cfg.continuous = 'yes';    
%     if ~strcmpi(ext,'edf')
%         cfg.trialdef.triallength = Inf;
%         cfg = ft_definetrial(cfg);
%         evt = FT.ReStruct(cfg.event);
%         if iscell(evt.value)
%             bEmpty = cellfun(@isempty,evt.value);
%             evt    = structfieldfun(@(x) x(~bEmpty),evt);
%             bNum   = cellfun(@isnumeric,evt.value);
%             if ~any(bNum)
%                 evt.value(cellfun(@isempty,evt.value)) = {''};
%                 evt.value = cellfun(@(x) regexprep(x,'\s+',''),evt.value,'uni',false);
%             elseif all(bNum)
%                 evt.value(cellfun(@isempty,evt.value)) = {NaN};
%                 evt.value = cat(1,evt.value{:});
%             else
%                error('Poorly formated event code values. Please contact the developer with the circumstances of this error'); 
%             end
%         end

%         FT_DATA.event = FT.ReStruct(evt);        
%         FT_DATA.done.read_events = true;
%     end


%     FT_DATA.data = ft_preprocessing(cfg);

%     if strcmpi(ext,'edf')
%         resp = FT.UserInput(['\bf[\color{red}WARNING\color{black}]\n',...
%                     'It is highly recomended that you process events\n',...
%                     'BEFORE preprocessing EDF files.\n\nWould you like to process events now?'],...
%                     1,'button',{'Yes','No'},'title','WARNING!');
%         switch lower(resp)
%             case 'yes'
%                 FT.ProcessEvents;
%             case 'no'
%                 FT.UserInput(['\bf[\color{red}WARNING\color{black}]\n',...
%                     'Make SURE you process event BEFORE resampling!'],...
%                     1,'button','OK','title','WARNING!');
%         end
%     elseif isempty(ext)
%         nlx_parse_events;        
%     end
% end
