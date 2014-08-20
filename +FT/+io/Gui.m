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
% Updated: 2014-06-27
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
strPath = fullfile(strPath,strName);

sep = filesep;
if sep == '\'
	sep = '\\';
end

[strBase,strName,ext] = fileparts(regexprep(strPath,[sep '$'],''));
ext = regexprep(ext,'^\.','');

% Neuralynx file
if strcmpi('ncs',ext)
    [strBase,strName] = fileparts(strBase);
    strPath = fullfile(strBase,strName);
end

params = struct('name',strName,'path',strBase,'full',strPath,'ext',ext);
params.raw = ~any(strcmpi(params.ext,{'mat','set'}));

hMsg = FT.UserInput('Reading data from file, plese wait...',1);

% read new data    
me = FT.io.ReadDataset(params);

if ishandle(hMsg)
	delete(hMsg);
end

if ~isa(me,'MException')
    %process events? important if the data is from an edf file...
    if params.raw
        if strcmpi(params.ext,'edf')
            resp = FT.UserInput(['\bf[\color{red}WARNING\color{black}]\n',...
                'It is highly recomended that you process events\n',...
                'BEFORE preprocessing EDF files.\n\nWould you like to process events now?'],...
                1,'button',{'Yes','No'},'title','WARNING!');
        else
            resp = FT.UserInput('Process events?',1,'button',{'Yes','No'},'title','MESSAGE');
        end
        if strcmpi(resp,'yes')
            FT.events.read.Gui;
        end
    end
else
    % failed to load data somehow
    FT.ProcessError(me);
    
    % clear everything
    FT.io.ClearDataset;
end

%update the display
FT.UpdateGUI;

end
