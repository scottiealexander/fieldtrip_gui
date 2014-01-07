function RedrawGUI

% RedrawGUI
%
% Description: redraw the FT.GUI display, removeing any errant graphical objects
%              that might have accidentiall appeared
%
% Syntax: RedrawGUI
%
% In: 
%
% Out: 
%
% Updated: 2013-10-25
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

gui = FT_DATA.gui;

%make axes invisible
set(gui.hAx,'Visible','off');

%get all children of axes
hChild = get(gui.hAx,'Children');

%delete all children that don't belong to us
delete(hChild(~ismember(hChild,gui.hText)));

%update the display
FT.UpdateGUI;