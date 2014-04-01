function GrandAverage()

% FT.GrandAverage
%
% Description: 
%
% Syntax: FT.GrandAverage
%
% In: 
%
% Out: 
%
% Updated: 2014-03-11
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

%NOTE:
% we may want to clear the current dataset if there is one...
global FT_DATA;

hMsg = FT.UserInput('Calculating Grand Average ERP',1);

cPathERP = AvgFileOps('get','erp');
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
	epoch{k}.name = cFields{k};
end

FT_DATA.data = data;
FT_DATA.epoch = epoch;
FT_DATA.done.average = true;

if ishandle(hMsg)
	close(hMsg);
end

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
		bChan = ismember(s.label{kA},cCommonLabel);
		for kB = 1:numel(cFields)
			s.data.(cFields{kB}){kA} = s.data.(cFields{kB}){kA}(bChan,:);
		end
	end
end
%-----------------------------------------------------------------------------%
function b = IsCommonChannel(strChan)
	b = all(cellfun(@(x) any(strcmp(strChan,x)),s.label));
end
%-----------------------------------------------------------------------------%
end
