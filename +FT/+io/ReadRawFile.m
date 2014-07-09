function ReadRawFile(strPath,strType)
% ReadRawFile
%
% Description: read a raw EEG file
%
% Syntax: ReadRawFile(strPath,strType)
%
% In:
%       strPath - the path to a raw EEG file (.eeg, .bdf etc.)
%       strType - the type/file extension for the data file
%
% Out: 
%
% Updated: 2014-07-02
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

%read data from raw eeg file
cfg = FT.tools.CFGDefault;
cfg.dataset    = strPath;
cfg.continuous = 'yes';

FT_DATA.data = ft_preprocessing(cfg);

%raw data has no processing done (this is a bit of a hack, it might be
%better to completely clear the data set before loading a new one)
dFields = fieldnames(FT_DATA.done);
for k = 1:numel(dFields)
    FT_DATA.done.(dFields{k}) = false;
end

%process events? important if the data is from an edf file...
if strcmpi(strType,'edf')
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