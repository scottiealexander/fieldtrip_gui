function Gui(obj,varargin)

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

try

%move to the analysis base dir
strDirCur = pwd;
if isdir(FT_DATA.path.base_directory)        
    cd(FT_DATA.path.base_directory);       
end

%figure out what the user is trying to load
if ishandle(obj)
    str = get(obj,'Label');
elseif ischar(obj)
    str = obj;
else
    me = MException('FT:InvalidFormat','Invalid call to FT.io.Gui, first input should be a handle or a string');
    FT.ProcessError(me);
    cd(strDirCur);
    return;    
end

switch lower(str)
    case 'load existing analysis'
        % strPath = uigetdir(pwd,'Load Existing Analysis');
        me = MException('FT:NotImplemented','This feature is not yet implemented');
        FT.ProcessError(me);
        return;
    case 'eeg file / dataset'
        [strName,strPath] = uigetfile('*','Load File');
        if ~isequal(strName,0) && ~isequal(strPath,0)
            strPath = fullfile(strPath,strName);
        end
    case 'neuralynx dataset'
        strPath = uigetdir(pwd,'Load Neuralynx Dataset');
    otherwise
        me = MException('FT:InvalidFormat','Invalid call to FT.io.Gui, first input should be a handle or a string');
        FT.ProcessError(me);
        cd(strDirCur);
        return;
end

%move back to the original directory
cd(strDirCur);

if isequal(strPath,0)
	%user selected cancel
	return; 
end

sep = filesep;
if sep == '\'
	sep = '\\';
end

[~,strName] = fileparts(regexprep(strPath,[sep '$'],''));
FT_DATA.current_dataset = strName;
FT_DATA.path.raw_file = strPath;

hMsg = FT.UserInput('Reading data from file, plese wait...',1);

%read the data    
me = FT.io.ReadDataset(strPath);

if ishandle(hMsg)
	delete(hMsg);
end

if isa(me,'MException')
    rethrow(me);
else
	if strcmpi(FT_DATA.gui.display_mode,'init')
	    FT_DATA.gui.display_mode = 'preproc';
	end
end

%update the display
FT.UpdateGUI;

%failed to load data somehow, clear everything
catch me
    FT.ProcessError(me);
    
    %grab the fields that we will still need
    gui  = FT_DATA.gui;

    %renew the FT_DATA struct
    FT_DATA = [];
    FT.Prepare('type','data');

    %add the fields back in 
    gui.display_mode = 'init'; %set display mode back to initial
    FT_DATA.gui = gui;

    %update the GUI
    FT.UpdateGUI;
end

