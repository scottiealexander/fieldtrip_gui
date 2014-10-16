function b = Verify(path_file)

% FT.average.grand.Verify
%
% Description: verify that a .set file is ready to be averaged
%
% Syntax: [b,msg] = FT.average.grand.Verify(path_file)
%
% In:
%       path_file - the path to a .set file
%
% Out:
%       b   - true of the file is 'ready' false otherwise
%       msg - any empty string ('') if b is true, otherwise a string with info
%             about the missing or invalid aspect of the dataset 
%
% Updated: 2014-10-08
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

b = false;

[~,~,ext] = fileparts(path_file);

if ~any(strcmpi(ext,{'.mat','.set'}))
    return; % invalid file format
end

% % very slow for large files, is there an alternative?
% s = whos('-file',path_file,'done','epoch','data');
% if ~all(ismember({'done','epoch','data'},{s(:).name}))
%     return; % invalid file contents
% end
try
    done = LoadVar(path_file,'done');
    if isempty(done) || ~isfield(done,'average') || ~done.average    
        return; % dataset has not been averaged
    end

    epoch = LoadVar(path_file,'epoch');
    if isempty(epoch)
        return; % segmentation information could not be found
    end
catch
    return;
end
b = true;

%-----------------------------------------------------------------------------%
function v = LoadVar(path_file,varname)
    try
        v = getfield(load(path_file,'-mat',varname),varname);
    catch
        v = [];
    end
end
%-----------------------------------------------------------------------------%
end