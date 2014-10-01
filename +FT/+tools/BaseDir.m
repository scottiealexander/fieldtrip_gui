function strPath = BaseDir

% FT.tools.BaseDir
%
% Description: returns the full path to the base +FT directory
%
% Syntax: strPath = FT.tools.BaseDir
%
% In:
%
% Out:
%       strPath - the full path to the base +FT directory
%
% Updated: 2014-09-29
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

strPath = fileparts(fileparts(mfilename('fullpath')));
