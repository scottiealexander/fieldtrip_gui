function Manage(type)
% FT.organize.Manage
%
% Description: a static method that the GUI menu can call, which in turn
% calls edit on the analsys organization object
%
% Updated: 2014-10-13
% Peter Horak

global FT_DATA;

action = ' ';
% Keep editing until the organization editor returns done. The editor will
% raise the 'type' in the hierarchy until there is a current node at the
% level above it (e.g. dataset -> subject if there is a current study but
% no current subject). As long as the user adds or loads a node at each
% level, the editor will return 'notdone'. Similarly, if the user simply
% deletes a node the editor will return 'notdone'. If the user closes the
% editor GUI without doing anything or by adding/loading a node (at the
% level specified by type), then it will return 'done'.
while ~strcmpi(action,'done')
    action = FT_DATA.organization.edit(type);
    FT.UpdateGUI;
end

end

