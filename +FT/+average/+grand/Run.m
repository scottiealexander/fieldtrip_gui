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
dbstop if error;
global FT_DATA
me = [];

% try
    FT.io.ClearDataset;

    all_data = cellfun(@FT.average.grand.Fetch,params.files,'uni',false);
    all_labels = GetDataField('label');
    time = GetDataField('time');
    all_names = GetDataField('epoch_names');

    b = cellfun(@(x) isequal(x,time{1}),time(2:end),'uni',true);
    if ~all(b)
        msg = '[ERROR]: Time is not consistent accross datasets!';
        FT.UserInput(msg,0,'title','Inconsistent Data','button','OK');
        return;
    end
    time = time{1};

    chan_use = CommonElements(all_labels);
    if isempty(chan_use)
        msg = '[ERROR]: No common labels could be detected across subjects!';
        FT.UserInput(msg,0,'title','Inconsistent Data','button','OK');
        return;
    end
    
    epoch_names = CommonElements(all_names);
    if isempty(epoch_names)
        msg = '[ERROR]: No common condition names could be found across subjects!';
        FT.UserInput(msg,0,'title','Inconsistent Data','button','OK');
        return;
    end

    siz_data = [numel(chan_use) numel(time) numel(all_data)];

    nepoch = numel(epoch_names);
    [data,epoch] = deal(cell(nepoch,1));
    for ke = 1:nepoch
        data{ke}.avg = nan(siz_data);
        for kf = 1:numel(all_data)
            bepoch = strcmpi(epoch_names{ke},all_names{kf});
            [~,kchan] = ismember(chan_use,all_labels{kf});
            data{ke}.avg(:,:,kf) = all_data{kf}.data{bepoch}.avg(kchan,:);
        end
        data{ke}.err = nanstderr(data{ke}.avg,3);
        data{ke}.avg = nanmean(data{ke}.avg,3);        
        data{ke}.label = chan_use;
        data{ke}.time  = time;
        data{ke}.fsample = 1/median(diff(time));
        epoch{ke}.name = epoch_names{ke};
    end

    FT_DATA.data = data;
    FT_DATA.epoch = epoch;
    FT_DATA.done.average = true;
% catch me
% end

% update display fields
FT_DATA.gui.display_mode = 'averaged';
% new dataset name (because cleared the last one)
FT_DATA.current_dataset = [FT_DATA.study_name ': Grand Average'];
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
function ref = CommonElements(c)
    ref = c{1};
    for k = 2:numel(c)
        b = ismember(ref,c{k});
        ref = ref(b);
    end
end
%-----------------------------------------------------------------------------%
function x = nanstderr(x,dim)
    n = sum(~isnan(x),dim);
    x = nanstd(x,[],dim)./sqrt(n);
end
%-----------------------------------------------------------------------------%
end