function params = Read(strPath)

% FT.io.Read
%
% Description: a wrapper function for dataset reading/loading: given a file
%              path figure out the type of file and proceed accordingly
%
% Syntax: FT.io.Read(strPath)
%
% In:
%       strPath - the path to a file to read/load
%
% Out:
%
% Updated: 2014-09-29
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

sep = filesep;
if sep == '\'
    sep = '\\';
end

[strBase,strName,ext] = fileparts(regexprep(strPath,[sep '$'],''));
ext = regexprep(ext,'^\.','');

% Datafile type
if any(strcmpi(ext,{'mat','set'}))
    type = 'set';
elseif ~isnan(str2double(ext))
    type = 'penn';
else
    type = 'raw';
end

% Neuralynx file
if strcmpi(ext,'ncs')
    [strBase,strName] = fileparts(strBase);
    strPath = fullfile(strBase,strName);
end

params = struct('name',strName,'path',strBase,'full',strPath,'ext',ext,...
    'type',type);

hMsg = FT.UserInput('Reading data from file, please wait...',1);

% read new data    
me = FT.io.ReadDataset(params);

if ishandle(hMsg)
    delete(hMsg);
end

if ~isa(me,'MException')
    %process events? important if the data is from an edf file...
    if ~strcmpi(params.type,'set')
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
    params = [];
end

%update the display
FT.UpdateGUI;