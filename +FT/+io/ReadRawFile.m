function ReadRawFile(strPath)
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

end