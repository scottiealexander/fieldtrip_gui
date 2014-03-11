function c = ERPFileOps(action)

% ERPFileOps
%
% Description: 
%
% Syntax: c = ERPFileOps(action)
%
% In:
%		action     - the action	to perform, one of:
%						'add': add the current dataset to the ERP file list
%						'get': fetch the ERP file list for the current analysis
%
% Out:
%		c - if 'action' == 'get', a cell of the ERP files for this analysis
%
% Updated: 2014-03-11
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

strPathERP = fullfile(FT_DATA.path.base_directory,'erp.cfg');
strPathSet = FT_DATA.path.dataset;

c = ReadERPFile(strPathERP);

switch lower(action)
	case {'add','append'}
		%make sure we don't add duplicates
		if ~any(strcmpi(c,strPathSet))
			c{end+1,1} = strPathSet;
		end
		WriteERPFile(c,strPathERP);

	case {'get','fetch'}
		%nothing to do
	otherwise
		error('Invalid action: %s',action);
end

%-----------------------------------------------------------------------------%
function c = ReadERPFile(strPath)
	if exist(strPath,'file') == 2
		fid = fopen(strPath,'r');
		if fid > 0
			str = transpose(fread(fid,'*char'));
		else
		    error('Failed to read file: %s',strPath);     
		end
		c = reshape(regexp(str,'\n','split'),[],1);
	else
		c = {};
	end
end
%-----------------------------------------------------------------------------%
function WriteERPFile(c,strPath)
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