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
    if ischar(varargin{1})
        strPath = varargin{1};
    else
        error('Input should be a directory path, see "help FT.tools.IsNLXFile" for more info');
    end
elseif isfield(FT_DATA.path,'raw_file') && ~isempty(FT_DATA.path.raw_file)
    strPath = FT_DATA.path.raw_file;
else
    error('No data has been loaded and no file/directory path was provided as input');
end

b = isdir(strPath);
