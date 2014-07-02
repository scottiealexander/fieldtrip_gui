function me = ReadDataset(strPath)

% ReadDataset
%
% Description: read dataset or datafile from disk
%
% Syntax: ReadDataset
%
% In: 
%
% Out: 
%
% Updated: 2014-06-27
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

me = [];

%get extension
[~,~,ext] = fileparts(strPath);
ext = regexprep(ext,'^\.','');

try
    if any(strcmpi(ext,{'mat','set'}))    
        FT.io.ReadSetFile(strPath);
    else
        FT.io.ReadRawFile(strPath,ext);
    end
catch me
end