function c = AvgFileOps(action,varargin)

% AvgFileOps
%
% Description: 
%
% Syntax: c = AvgFileOps(action,[type]=prompt)
%
% In:
%		action  - the action to perform, one of:
%				  'add': add the current dataset to the average file list
%				  'get': fetch the ERP file list for the current analysis
%		[type] 	- the type of average dataset (e.g. 'erp',or 'psd')
%
% Out:
%		c - if 'action' == 'get', a cell of the average files for this analysis
%
% Updated: 2014-03-31
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;
if isempty(varargin) || isempty(varargin{1}) || ~ischar(varargin{1})
	type = FT.UserInput('\bfPlease select an average dataset type:',1,'button',{'ERP','PSD'},'title','Save Average Dataset');
	type = lower(type);
else
	type = lower(varargin{1});
end

strPathAvg = fullfile(FT_DATA.path.base_directory,[type '.cfg']);
strPathSet = FT_DATA.path.dataset;

c = ReadAvgFile(strPathAvg);

switch lower(action)
	case {'add','append'}
		%make sure we don't add duplicates
		if ~any(strcmpi(c,strPathSet))
			c{end+1,1} = strPathSet;
		end
		WriteAvgFile(c,strPathAvg);

	case {'get','fetch'}
		%nothing to do
	otherwise
		error('Invalid action: %s',action);
end

%-----------------------------------------------------------------------------%
function c = ReadAvgFile(strPath)
	if exist(strPath,'file') == 2
		fid = fopen(strPath,'r');
		if fid > 0
			str = transpose(fread(fid,'*char'));
		else
		    error('Failed to read file: %s',strPath);     
		end
		c = reshape(regexp(strtrim(str),'\n','split'),[],1);
		bRM = cellfun(@(x) isempty(x) || x(1) == '#',c);
		c(bRM) = [];
	else
		c = {};
	end
end
%-----------------------------------------------------------------------------%
function WriteAvgFile(c,strPath)
	if ~isempty(c)
		fid = fopen(strPath,'w');
		if fid > 0	    
		    fprintf(fid,'%s',FT.Join(c,10));
		    fclose(fid);
		else
		    error('Failed to write file: %s',strPath);     
		end
	end
end
%-----------------------------------------------------------------------------%
end