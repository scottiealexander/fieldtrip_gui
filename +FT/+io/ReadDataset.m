function me = ReadDataset(params)

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

global FT_DATA;
me = [];

try
    FT_DATA.current_dataset = params.name;
    FT_DATA.path.raw_file = params.full;
    FT_DATA.path.base_directory = params.path;
    
    if ~params.raw  
        FT.io.ReadSetFile(params.full);
    else
        FT.io.ReadRawFile(params.full);
    end
    
    %update gui display fields
    if strcmpi(FT_DATA.gui.display_mode,'init')
	    FT_DATA.gui.display_mode = 'preproc';
    end
catch me
end

FT.tools.AddHistory('io',params);
end