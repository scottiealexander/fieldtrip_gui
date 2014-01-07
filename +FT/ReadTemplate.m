function ReadTemplate()

% FT.ReadTemplate
%
% Description: read a FT.GUI template file for use in repeat analyses
%
% Syntax: FT.ReadTemplate
%
% In: 
%
% Out: 
%
% Updated: 2013-08-01
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

strPathTemplate = FT_DATA.path.template;

fid = fopen(strPathTemplate,'r');

if fid > 0
    str = reshape(cast(fread(fid,'char'),'char'),1,[]);
    fclose(fid);
else
    error(['Could not read template file: ' strPathTemplate]);
end

re = reshape(regexp(str,'(#[^#]+)\n{3}|(#[^#]+)\n$','tokens'),1,[]);
re = reshape(cat(2,re{:}),[],1);

[cFields,cContent] = cellfun(@ExtractSection,re,'uni',false);

FT_DATA.template = cell2struct(cat(1,cContent{:}),cat(1,cFields{:}),1);

%-------------------------------------------------------------------------%
function [cFields,cContent] = ExtractSection(str)
%convert a section of the template file to a cell of fields and their
%corresponding content
    [strName,k] = regexp(str,'^#(\w*)\n','tokens','end');
    strName = strName{1}{1};
    str = str(k+1:end);
    reTmp = regexp(str,'(?<header>\w+)\t+(?<content>[^\n]*)\n?','names');
    reTmp = FT.ReStruct(reTmp);
    nField = numel(reTmp.header);
    cContent = cell(nField,1);
    for k = 1:nField
       cContent{k,1} = FixContent(reTmp.content{k});
    end
    cFields = reTmp.header;
    FT_DATA.template.(strName) = cell2struct(cContent,cFields,1);
end
%-------------------------------------------------------------------------%
function c = FixContent(str)
%fix content formatting: convert numeric strings to doubles, leave single 
%word content as strings and put multi-word content into a cell
%     if strcmpi(str,'"ch17 - ch18"')
%         disp('stop');
%     end
    c = regexp(str,'"(?<item>[^"]*)"','names');
    c = regexp(c.item,'\s+|,','split');
    if  ischar(c) || (iscell(c) && numel(c)==1)
        if iscell(c)
            c = c{1};
        end
        if all(ismember(c,'0123456789.+-e')) && ~isempty(c)
            c = str2double(c);
        end
    elseif iscell(c)
        if all(cellfun(@(x) all(ismember(x,'0123456789.+-e')) && ~isempty(x),c))
            c = str2double(c);
        else
            c = FT.Join(c,32);
        end
    end
end
%-------------------------------------------------------------------------%
end