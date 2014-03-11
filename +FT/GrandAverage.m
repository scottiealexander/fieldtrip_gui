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

cPathERP = ERPFileOps('get');
nFile    = numel(cPathERP);

s.files 	 = cPathERP;
s.data 	     = struct;
s.label		 = cell(nFile,1)

bCommon = cellfun(@IsCommonChannel,s.label{1});

if ~any(bCommon)	
	error('No common labels could be detected across subjects!');
end

cCommonLabel = s.label{1}(bCommon);
cFields = fieldnames(s.data);

ExtractChannelData;

s.label = cCommonLabel;

for k = 1:numel(cFields)
	tmp = s.data.(cFields{k});
	tmp = reshape(tmp,1,1,nFile);
	tmp = cat(3,tmp{:});
	s.mean = nanmean(tmp,1);
	s.stderr = nanstderr(tmp,1);
end

FT_DATA.data = s;

if ishandle(hMsg)
	close(hMsg);
end

%-----------------------------------------------------------------------------%
function GetData(strPath)
	ifo = load(strPath,'-mat');

	if isempty(fieldnames(s.data))
		cFields = cellfun(@(x) x.name,ifo.epoch,'uni',false);
		s.data  = cell2struct(repmat({cell(nFile,1)},numel(cFields),1),cFields,1);
	end

	for k = 1:numel(ifo.epoch)
		strCond = ifo.epoch{k}.name;
		if isfield(s.data,strCond)
			data.(strCond){k} = ifo.data{k}.avg;
		else
			error('Condition names do not match between files!');
		end
		s.label{k} = ifo.data{k}.label;
	end
end
%-----------------------------------------------------------------------------%
function ExtractChannelData	
	for kA = 1:nFile
		bChan = ismember(s.label{kA},cLabel);
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
