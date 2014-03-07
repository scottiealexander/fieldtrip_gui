function GranAverage()

% FT.GranAverage
%
% Description: 
%
% Syntax: FT.GranAverage
%
% In: 
%
% Out: 
%
% Updated: 2014-03-07
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA

if isdir(FT_DATA.path.base_directory)
	strDir = uigetdir(FT_DATA.path.base_directory,'Select Study Directory');
else
	base_dir = SubDir(mfilename('fullpath'),2);
	if isdir(fullfile(base_dir,'studies'))
		base_dir = fullfile(base_dir,'studies');
	end
	strDir = uigetdir(base_dir,'Select Study Directory');
end

cDir = GetDirs(strDir);

%FINISH FIXME TODO
% find and read all erp.cfg files
% but make sure we don't include something that our user doesn't want us to

%-----------------------------------------------------------------------------%
function strDir = SubDir(strDir,n)
	if n < 0
		error('invalid depth given');
	end
	if filesep == '\'
		sep = '\\';
	else
		sep = filesep;
	end
	c = regexp(strDir,sep,'split');

	strDir = FT.Join(c(1:end-n),filesep);
end
%-----------------------------------------------------------------------------%
function cDir = GetDirs(strDir)
	s    = dir(strDir);	
	cDir = s.name(s.isdir);
	b    = cellfun(@isempty,regexp(cDir,'\..*','match'));
	cDir = cellfun(@(x) fullfile(strDir,x),cDir(b),'uni',false);
end
%-----------------------------------------------------------------------------%
end