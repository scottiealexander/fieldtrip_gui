function d = Fetch(path_file)

% FT.average.Grand.Fetch
%
% Description: fetch data from a file
%
% Syntax: d = FT.average.Grand.Fetch(path_file)
%
% In:
%       path_file - the path to a .set or .mat dataset file
%
% Out:
%       d - a struct containing epoch and data structs
%
% Updated: 2014-10-08
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

d = load(path_file,'-mat','data','epoch');

%make it easier to find common channels later on...
d.label = GetDataField('label');

%same with time...
d.time = GetDataField('time');

%and epoch names
d.epoch_names = cellfun(@(x) x.name,d.epoch,'uni',false);

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