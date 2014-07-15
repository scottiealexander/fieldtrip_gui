function str = ReformatStr(str,varargin)

% ReformatStr
%
% Description: reformat a NxM char array into a 1xP char array where newline
%              feeds replace row breaks
%
% Syntax: str = ReformatStr(str<options>)
%
% In: 
%       str - a string of no more than 2 dimentions
%   options:
%       cell - (false) true to output as a cell instead of joining with newline
%               feeds
%
% Out: 
%       str - the input string reformatted (see Description)
%
% Updated: 2013-12-13
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt = FT.ParseOpts(varargin,...
    'cell' , false ...
    );

str = mat2cell(str,ones(size(str,1),1),size(str,2));
str = strtrim(str);
b   = cellfun(@isempty,str);

if ~opt.cell
    str = FT.Join(str(~b),10);
else
    str = str(~b); 
end