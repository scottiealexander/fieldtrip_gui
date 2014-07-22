function b = CSVAppend(strPathStat,s,varargin)

% CSVAppend
%
% Description: add a column of data to a CSV spreadsheet
%
% Syntax: CSVAppend(strPathStat,s,<options>)
%
% In: 
%       strPathStat - the path to a CSV spread sheet
%       s           - the struct of data to append
%   options:
%       headers - (<fieldnames>) a cell of column labels for input 's'
%       delim   - (<tab>) the delimiting character
%
% Out: 
%       b - a logical indicating success
%
% Updated: 2013-10-14
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt = FT.ParseOpts(varargin,...
    'headers', {}  ,...
    'delim'  , '\t' ...
    );

fid = fopen(strPathStat,'r');
str = cast(fread(fid,'char'),'char')';
c = regexp(strtrim(str),'\n','split');
c = regexp(c,opt.delim,'split');
c = cat(1,c{:});

cLabel = c(1,:);
kEnd = 96+size(c,2);
cFieldTmp = num2cell(char(97:kEnd));

sTmp = FT.ReStruct(cell2struct(c(2:end,:),cFieldTmp,2));

if isempty(opt.headers)
    opt.headers = fieldnames(s);
elseif numel(opt.headers) ~= numel(fieldnames(s))
    me = MException('CSVAppend:IncompatibleSizes','number of headers and number of fields do not match');
    FT.ProcessError(me);
    return;
end

bAppend = ~ismember(opt.headers,cLabel);

cFields = fieldnames(s);

for k = 1:numel(cFields)
   if bAppend(k)
      tmp = regexp(strtrim(sprintf('%f\n',s.(cFields{k}))),'\n','split');
      sTmp.(char(kEnd+k)) = reshape(tmp,[],1);
      cLabel{end+1} = opt.headers{k};
   end
end

b = FT.io.WriteStruct(sTmp,'output',strPathStat,'headers',cLabel);
