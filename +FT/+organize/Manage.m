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
while ~strcmpi(action,'done')
    action = FT_DATA.organization.edit(type);
end

end

