function c = LoadFiles(id)

% FT.study.subject.LoadFiles
%
% Description: load all dataset file associtate with a given subject
%
% Syntax: c = FT.study.subject.LoadFiles(id)
%
% In:
%       id - the subject's id or name
%
% Out:
%       c - a cell of filepaths for the given subject
%
% Updated: 2014-10-08
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
    c = c(cellfun(@(x) exist(x,'file')==2,c));
    c = reshape(c,[],1);
else
    %subject doesn't yet have a filelist
    c = {};
end