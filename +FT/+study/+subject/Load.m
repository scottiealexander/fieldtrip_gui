function Load

% FT.study.subject.Load
%
% Description: load a subject and possibly a dataset from that subject
%
% Syntax: FT.study.subject.Load
%
% In:
%
% Out:
%
% Updated: 2014-10-04
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

name = FT.study.subject.Select;

if isempty(name)
    return;
end

%i'm not totally sure we want to do this... but if we are to be consistent
%loading a subject *SHOULD* clear the current subject / dataset, it might
%get confusing if a dataset were loaded without a subject and then the user
%tried to load a subject, but i think it's still more consistent to clear
%the dataset in that case
FT.io.ClearDataset;

[path_file, all_files] = FT.study.subject.SelectFile(name);

if ~isempty(path_file) && exist(path_file,'file') == 2
    study_name = FT_DATA.study_name;

    %load the data!
    FT.io.Read(path_file);

    %make sure the subject's filelist gets updated if the user
    %browsed for a file
    if ~isempty(all_files)
        FT.study.subject.AddFile(name,all_files);
    end

    %make sure study name didn't get cleared        
    FT_DATA.study_name = study_name;    
end

FT_DATA.subject_name = name;

FT.UpdateGUI;

end