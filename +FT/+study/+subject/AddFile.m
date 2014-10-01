function AddFile(id,path_file)

% FT.study.subject.AddFile
%
% Description:
%
% Syntax: FT.study.subject.AddFile
%
% In:
%
% Out:
%
% Updated: 2014-10-01
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

subj_file = FT.study.subject.File(id);

c = FT.study.subject.LoadFiles(id);

c{end+1,1} = path_file;

fid = fopen(subj_file,'w');
if fid > 0
    for k = 1:numel(c)
        fprintf(fid,'%s\n',c{k});
    end
else
    error('Failed opening file for writing: %s',subj_file);    
end