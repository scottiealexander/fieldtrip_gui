function b = IsNLXFile(varargin)
% IsNLXFile
%
% Description: check if a file/directory path represents a neuralynx dataset
%
% Syntax: b = IsNLXFile([strPath] = <current_dataset>)
%
% In:
%		[strPath] - the path to a dataset file/directory, if unspecified
%				    defaults to the currently loaded dataset
%
% Out: 
%		b - true if strPath represents a neurolynx dataset/directory
%
% Updated: 2014-06-27
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

b = false;

if ~isempty(varargin)

%temporary dumb method... this will have to be improved...
if isfield(FT_DATA.path,'raw_file') && ~isempty(FT_DATA.path.raw_file)
	if isdir(FT_DATA.path.raw_file)
		b = true;
	end
end