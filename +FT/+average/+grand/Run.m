function me = Run(params)

% FT.average.grand.Run
%
% Description: calculate average ERP across multiple datasets
%
% Syntax: me = FT.average.grand.Run(params)
%
% In:   params - a struct holding parameters from the user
%
% Out:  me - an empty matrix if processing finished with out error,
%            otherwise a MException object caught from the error
%
% Updated: 2014-03-30
% Scottie Alexander
%
% See also: FT.average.grand.Gui

global FT_DATA
me = [];

try
    FT.io.ClearDataset;

    all_data = cellfun(@FT.average.grand.Fetch,params.files,'uni',false);
    all_labels = GetDataField('label');
    all_times = GetDataField('time');
    all_names = GetDataField('epoch_names');

    b = cellfun(@(x) isequal(x,all_times{1}),all_times(2:end),'uni',true);
    if ~all(b)
        msg = '[ERROR]: Time is not consistent accross datasets!';
        FT.UserInput(msg,0,'title','Inconsistent Data','button','OK');
        return;
    end

    bChan = cellfun(@IsCommonChannel,all_labels{1});

    if ~any(bChan)        
        msg = '[ERROR]: No common labels could be detected across subjects!';
        FT.UserInput(msg,0,'title','Inconsistent Data','button','OK');
        return;
    end

    cCommonLabel = all_labels{1}(bChan);

    %FINISH ME%
    % bEpoch = cellfun(@(x))


    cFields = fieldnames(s.data);

    ExtractChannelData;

    s.label = cCommonLabel;

    s.data = s.data;
    [data,epoch] = deal(cell(numel(cFields),1));
    for k = 1:numel(cFields)
        tmp = s.data.(cFields{k});
        tmp = reshape(tmp,1,1,nFile);
        tmp = cat(3,tmp{:});
        data{k}.avg = nanmean(tmp,3);
        data{k}.err = nanstderr(tmp,3);
        data{k}.label = s.label;
        data{k}.time  = s.time;
        data{k}.fsample = 1/median(diff(s.time));
        epoch{k}.name = cFields{k};
    end

    FT_DATA.data = data;
    FT_DATA.epoch = epoch;
    FT_DATA.done.average = true;
catch me
end

% update display fields
FT_DATA.gui.display_mode = 'averaged';
% new dataset name (because cleared the last one)
FT_DATA.current_dataset = 'GrandAverage';
% mark data as not saved
FT_DATA.saved = false;

% update history
FT.tools.AddHistory('grand_average',params);
FT_DATA.done.grand_average = isempty(me);

%-----------------------------------------------------------------------------%
function v = GetDataField(field,varargin)
    uni = false;
    if ~isempty(varargin) && islogical(varargin{1})
        uni = varargin{1};
    end
    v = cellfun(@(x) x.(field),all_data,'uni',uni);
end
%-----------------------------------------------------------------------------%
function ExtractChannelData	
	for kA = 1:nFile
		[bChan,iChan] = ismember(cCommonLabel,all_labels{kA});
        if ~all(bChan)
            error('Common Labels are not all common (this should never happen)');
        end
		for kB = 1:numel(cFields)
			s.data.(cFields{kB}){kA} = s.data.(cFields{kB}){kA}(iChan,:);
		end
	end
end
%-----------------------------------------------------------------------------%
function b = IsCommonChannel(strChan)
	b = all(cellfun(@(x) any(strcmp(strChan,x)),all_labels));
end
%-----------------------------------------------------------------------------%
function x = nanstderr(x,dim)
    n = sum(~isnan(x),dim);
    x = nanstd(x,[],dim)./sqrt(n);
end
%-----------------------------------------------------------------------------%
end