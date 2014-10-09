function [b,msg] = Verify(path_file)

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

b = true;
msg = '';

[~,~,ext] = fileparts(path_file);

if ~any(strcmpi(ext,{'.mat','.set'}))
    b = false;
    msg = 'Invalid file format, the selected file is not a FieldTripGUI dataset file (.set or .mat).';
    return;
end

s = whos('-file',path_file);
if ~all(ismember({'done','epoch','data'},{s(:).name}))
    b = false;
    msg = 'Invalid file contents: critial data is missing!';
    return;
end

%loading in 1 field at a time is only ~2ms slower then a single load of all
%fields, and this way we can do some preliminary checks before loading the 
%data
done = LoadVar(path_file,'done');
if ~isfield(done,'average') || ~done.average    
    b = false;
    msg = 'Dataset selected has not been averaged.';
    return;
end

epoch = LoadVar(path_file,'epoch');
if isempty(epoch)
    b = false;
    msg = 'Segmentation information could not be found for the selected dataset.';    
    return;
end

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