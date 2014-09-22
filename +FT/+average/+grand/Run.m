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

    cPathERP = params.files;
    nFile    = numel(cPathERP);

    s.files  = cPathERP;
    s.data 	 = struct;
    s.label  = cell(nFile,1);
    s.time   = [];

    cellfun(@GetData,cPathERP,reshape(num2cell(1:nFile),size(cPathERP)));

    bCommon = cellfun(@IsCommonChannel,s.label{1});

    if ~any(bCommon)	
        error('No common labels could be detected across subjects!');
    end

    cCommonLabel = s.label{1}(bCommon);
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
FT_DATA.gui.display_mode = 'analysis';
% new dataset name (because cleared the last one)
FT_DATA.current_dataset = 'GrandAverage';
% mark data as not saved
FT_DATA.saved = false;

% update history
FT.tools.AddHistory('grand_average',params);
FT_DATA.done.grand_average = isempty(me);

%-----------------------------------------------------------------------------%
function GetData(strPath,kFile)
	ifo = load(strPath,'-mat');

	if isempty(fieldnames(s.data))
		cFields = cellfun(@(x) x.name,ifo.epoch,'uni',false);
		s.data  = cell2struct(repmat({cell(nFile,1)},numel(cFields),1),cFields,1);
	end

	for kA = 1:numel(ifo.epoch)
		strCond = ifo.epoch{kA}.name;
		if isfield(s.data,strCond)
			s.data.(strCond){kFile} = ifo.data{kA}.avg;
		else
			error('Condition names do not match between files!');
		end
		if isempty(s.time)
			s.time = ifo.data{kA}.time;
		else
			if ~isequal(s.time,ifo.data{kA}.time)
				error('Sample times do not match between files!');
			end
		end
		s.label{kFile} = ifo.data{kA}.label;		
	end
end
%-----------------------------------------------------------------------------%
function ExtractChannelData	
	for kA = 1:nFile
		[bChan,iChan] = ismember(cCommonLabel,s.label{kA});
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
	b = all(cellfun(@(x) any(strcmp(strChan,x)),s.label));
end
%-----------------------------------------------------------------------------%
function x = nanstderr(x,dim)
    n = sum(~isnan(x),dim);
    x = nanstd(x,[],dim)./sqrt(n);
end
%-----------------------------------------------------------------------------%
end