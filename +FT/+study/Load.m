function Load

% FT.study.Load
%
% Description: load a study (which really just hangs on to the study name
%              so that subjects can be loaded / averaged)
%
% Syntax: FT.study.Load
%
% In:
%
% Out:
%
% Updated: 2014-10-01
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

m = FT.study.StudyMap;

name = m.KeySelectionGUI('Study');

if ~isempty(name)
    if any(~isemptyfield({'data','power'}))
        resp = FT.UserInput('Do you want to clear the current dataset?',...
                        0,'button',{'Yes','Cancel'},'title','Clear Dataset?');
        if strcmpi(resp,'yes')
            FT.io.ClearDataset;
        end
    end
    if ~isemptyfield('study_name')
        if ~strcmp(name,FT_DATA.study_name)
            FT_DATA.subject_name = '';
        end
    end
    FT_DATA.study_name = name;    
    FT.UpdateGUI;
end

%-----------------------------------------------------------------------------%
function b = isemptyfield(field)
    if ~iscell(field)
        field = {field};
    end
    b = false(numel(field),1);
    for k = 1:numel(field)
        b(k) = ~isfield(FT_DATA,field{k}) || isempty(FT_DATA.(field{k}));
    end
end
%-----------------------------------------------------------------------------%
end