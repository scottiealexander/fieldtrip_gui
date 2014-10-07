function d = Fetch(path_file)

% FT.average.Grand.Fetch
%
% Description: fetch data from a file
%
% Syntax: FT.average.Grand.Fetch(path_file)
%
% In:
%       path_file - the path to a .set or .mat dataset file
%
% Out:
%       d - a struct containing epoch and data structs if file is a vaild
%           averaged dataset, otherwise a MException object
%
% Updated: 2014-10-06
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

d = [];

[~,~,ext] = fileparts(path_file);

if ~any(strcmpi(ext,{'.mat','.set'}))
    d = MException('GrandAverage:FetchData','Invalid file format');
    return;
end

s = whos('-file',path_file);
if ~all(ismember({'done','epoch','data'},{s(:).name}))
    d = MException('GrandAverage:FetchData','Invalid file contents');
    return;
end

%loading in 1 field at a time is only ~2ms slower then a single load of all
%fields, and this way we can do some preliminary checks before loading the 
%data
d.done = LoadVar(path_file,'done');
if ~isfield(d.done,'average') || ~d.done.average
    d = MException('GrandAverage:FetchData','Dataset has not been averaged!');
    return;
end

d.epoch = LoadVar(path_file,'epoch');
if isempty(d.epoch)
    d = MException('GrandAverage:FetchData','Dataset does not contain epoch information!');
    return;
end

d.data = LoadVar(path_file,'data');

%make it easier to find common channels later on...
label = GetDataField('label');
if isempty(label)
    d = MException('GrandAverage:FetchData','Failed to find channel labels!');
    return;
end
d.label = label;

%same with time...
d.time = GetDataField('time');

%and epoch names
d.epoch_names = cellfun(@(x) x.name,d.epoch,'uni',false);

%-----------------------------------------------------------------------------%
function v = LoadVar(path_file,varname)
    try
        v = getfield(load(path_file,'-mat',varname),varname);
    catch me
        v = [];
    end
end
%-----------------------------------------------------------------------------%
function c = GetDataField(field)
    if iscell(d.data) && isfield(d.data{1},field)
        c = d.data{1}.(field);
    elseif isstruct(d.data) && isfield(d.data,field)
        c = d.data.(field);
    else
        c = [];    
    end
end
%-----------------------------------------------------------------------------%
end