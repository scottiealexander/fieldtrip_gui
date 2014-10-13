function Manage(type)
% FT.organize.Manage
%
% Description: create a new template from the current analysis history
%
% Updated: 2014-10-13
% Peter Horak

global FT_DATA;

action = ' ';
while ~strcmpi(action,'done')
    action = FT_DATA.organization.edit(type);
end

end

