function Gui(varargin)

% FT.io.Gui
%
% Description: read dataset or datafile from disk
%
% Syntax: FT.io.Gui(varargin)
%
% In: 
%
% Out: 
%
% Updated: 2014-09-29
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

%move to the analysis base dir
strDirCur = pwd;
if isdir(FT_DATA.path.base_directory)
    cd(FT_DATA.path.base_directory);
end

%user-selected file
[strName,strPath] = uigetfile('*','Load File');

% move back to the original directory
cd(strDirCur);

if isequal(strName,0) || isequal(strPath,0)
    return; % user selected cancel
end

%full path to the file
strPath = fullfile(strPath,strName);

%wrapper function for reading
FT.io.Read(strPath);

end
