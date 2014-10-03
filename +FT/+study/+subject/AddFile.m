function AddFile(id,path_file)

% FT.study.subject.AddFile
%
% Description: add a file to a subject's filelist
%
% Syntax: FT.study.subject.AddFile(id,path_file)
%
% In:
%       id - the subject's id or name
%       path_file - the filepath to add to the subject's filelist or cell of such
%
% Out:
%
% Updated: 2014-10-03
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

subj_file = FT.study.subject.File(id);

c = FT.study.subject.LoadFiles(id);

if ~iscell(path_file)
    path_file = {path_file};
end

c_all = unique(cat(1,reshape(c,[],1),reshape(path_file,[],1)));

if numel(c_all) > numel(c)
    fid = fopen(subj_file,'w');
    if fid > 0
        for k = 1:numel(c_all)
            fprintf(fid,'%s\n',c_all{k});
        end
    else
        error('Failed opening file for writing: %s',subj_file);    
    end
end