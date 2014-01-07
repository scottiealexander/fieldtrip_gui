function strDir = SubDir(strDir,varargin)

% FT.SubDir
%
% Description: extract a sub-directory path from a directory path
%
% Syntax: strDir = FT.SubDir(strDir,[n]=1)
%
% In: 
%       strDir - the path to a directory
%       [n] - the number of directories to remove from the path
%
% Out: 
%       strDir - the path to the directory 'n' directories up from the
%                input directory
%
% Updated: 2013-08-02
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

if ispc
    error('this function will not work on windows...');
end

if nargin == 2
    n = varargin{1};
    if ~isnumeric(n)
        error('input for option ''n'' *MUST* be numeric');
    end
else
    n = 1;
end

c = regexp(strDir,filesep,'split');
c = c(~cellfun(@isempty,c));
nSlash = numel(c) - n;
if nSlash < 1
    strDir = filesep;
else
    cOut = cell(1,nSlash*2);
    cOut(1:2:(nSlash*2)-1) = repmat({filesep},1,nSlash);
    cOut(2:2:nSlash*2) = c(1:end-n);
    strDir = cat(2,cOut{:});
end