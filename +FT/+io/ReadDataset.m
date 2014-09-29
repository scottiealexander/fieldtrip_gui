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
    % clear old data
    FT.io.ClearDataset;
    
    FT_DATA.current_dataset = params.name;
    
    if ~params.raw  
        FT.io.ReadSetFile(params.full);
        FT_DATA.path.dataset = params.full;
        
%         % If the .set file contained no base dir or and invalid one
%         if ~isdir(FT_DATA.path.base_directory)
%             FT_DATA.path.base_directory = params.path;
%         end
    else
        FT.io.ReadRawFile(params.full);
        FT_DATA.path.raw_file = params.full;
        
%         % Update base dir to reflect most recent file
%         FT_DATA.path.base_directory = params.path;
    end
    
    % Update base dir to reflect the most recently loaded file
    FT_DATA.path.base_directory = params.path;
    
    % Update gui display fields
    if params.raw || strcmpi(FT_DATA.gui.display_mode,'init')
	    FT_DATA.gui.display_mode = 'preproc';
    end
catch me
end

FT.tools.AddHistory('io',params);
end