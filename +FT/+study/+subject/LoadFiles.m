function c = LoadFile(id)

% FT.study.subject.LoadFile
%
% Description:
%
% Syntax: c = FT.study.subject.LoadFile(id)
%
% In:
%       id - the subjects id
%
% Out:
%       c - a cell of filepaths for the given subject
%
% Updated: 2014-10-01
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

subj_file = FT.study.subject.File(id);

fid = fopen(subj_file,'r');
if fid > 0
    str = transpose(fread(fid,'*char'));
    fclose(fid);
    c = regexp(str,'\n','split');
    c = c(~cellfun(@isempty,c));
    c = reshape(c,[],1);
else
    %subject doesn't yet have a filelist
    c = {};
end