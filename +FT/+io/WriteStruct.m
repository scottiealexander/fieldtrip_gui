function out = WriteStruct(s,varargin)
% FT.WriteStruct
%
% Description: convert a struct to an ascii table
%
% Syntax: out = FT.WriteTemplate(s,<options>)
%
% In: 
%       s          - a struct
%   options:
%       output  - ('') the path for the output file, if this is empty or not a
%                 valid filepath the ascii table is returned as a string
%       headers - (<fieldnames>) a cell of column headers, leave empty to use 
%                 fieldnames of the input struct
%       delim   - (<tab>) the column delimiter
%
% Out:
%       out - *IF* opt.output is empty or not a valid filepath, output is the
%             ascii table as a string, *ELSE* output is a logical inidcating if
%             the file was successfully written
%
% Updated: 2013-08-16
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt = FT.ParseOpts(varargin,...
    'output'  , '' ,...
    'headers' , [] ,...
    'delim'   , 9   ...
    );

if ~ischar(opt.delim)
    opt.delim = char(opt.delim);
end

%make sure we are 1x1 struct of Nx1 arrays
if numel(s) > 1
    s = FT.ReStruct(s);
end

cFields = fieldnames(s);

%cell-ify every field
for kF = 1:numel(cFields)
    if ~iscell(s.(cFields{kF}))
        s.(cFields{kF}) = num2cell(s.(cFields{kF}));
    end
end

%convert the struct data to a giant cell
c = reshape(struct2cell(s),1,[]);

%add column headers
if iscell(opt.headers) && all(cellfun(@ischar,opt.headers)) && numel(opt.headers) == numel(cFields)
    c = [reshape(opt.headers,1,[]); cat(2,c{:})];
else
    c = [reshape(cFields,1,[]); cat(2,c{:})];
end

%fill empty entries with '""'
bEmpty = cellfun(@isempty,c);
c(bEmpty) = {'""'};

%convert numeric data to strings
c = cellfun(@Convert2String,c,'uni',false);

%prepare the giant cell to hold the data and delimiters/newline feeds
siz = size(c);
cOut = cell(siz(1),siz(2)*2);

%every other column (startig from 1) is data
cOut(:,1:2:end-1) = c;

%add tab delimiter columns and newline feed column
cOut(:,2:2:end-2) = repmat(repmat({opt.delim},siz(1),1),1,siz(2)-1);
cOut(:,end) = repmat({char(10)},siz(1),1);

%reshape in into one long (ordered) row
cOut = reshape(cOut',1,[]);

%cat it all together
strAll = cat(2,cOut{:});

%write it to file
if ~isempty(opt.output)
    fid = fopen(opt.output,'w');    
    if fid > 0
        fwrite(fid,strAll,'char');
        fclose(fid);
        if exist(opt.output,'file')==2
            out = true;
        else
            out = false;
        end
    else
        %opt.output is not a valid filepath, assume the user wants the string
        out = strAll;
    end
else
    out = strAll;
end

%-------------------------------------------------------------------------%
function x = Convert2String(x)
%convert numeric data to strings
   if isnumeric(x) || islogical(x)
       x = num2str(x);
   elseif ischar(x)
      %nothing to do
   else
      error(['cannot conver a ' class(x) ' to a string']); 
   end
end
%-------------------------------------------------------------------------%
end