function UpdateGUI()

% FT.UpdateGUI
%
% Description: update the FieldTrip GUI display figure
%
% Syntax: FT.UpdateGUI
%
% In: 
%
% Out: 
%
% Updated: 2013-08-07
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA
gui = FT_DATA.gui;

for kT = 1:numel(gui.hText)
    if ishandle(gui.hText(kT))
        delete(gui.hText(kT));
    end
end
FT_DATA.gui.hText = [];

%fields that we want to display
cFieldDisp = gui.display_fields.(gui.display_mode);

sizSpace = gui.sizText(2)+(gui.sizText(4)/2):-(gui.sizText(4)+.01):0;

for kF = 1:numel(cFieldDisp)
    %format the field name for display
    if ischar(cFieldDisp{kF})
        strField = cFieldDisp{kF};
    elseif iscell(cFieldDisp{kF})
        strField = cFieldDisp{kF}{end};
    end
    strField = strrep(strField,'_',' ');
    strField = regexprep(strField,'(\<[a-z])','${upper($1)}');

    %get the contents of the field from the FT_DATA struct
    strContent = ExtractField(cFieldDisp{kF});

    %format it pretty
    strContent = strrep(strContent,'_','\_');
    strAdd = ['\bf' strField '\rm' ': ' strContent];

    %add to the display
    FT_DATA.gui.hText(kF,1) = text('String',strAdd,'Units','normalized','FontSize',12,...
        'Position',[gui.sizText(1) sizSpace(kF) 0],'Parent',gui.hAx);
end

drawnow;

%-------------------------------------------------------------------------%
function s = ExtractField(c)
%extract a field from the FT_DATA struct given a field path as a cell of
%field names
    if ~iscell(c)
        c = {c};
    end
    if numel(c) > 0
        s = FT_DATA;
        for k = 1:numel(c)
            if isfield(s,c{k})
                s = s.(c{k});
            else
                s = '';
                return;
            end
        end
    else
        s = '';
    end
    if isnumeric(s)
        s = num2str(s);
    elseif islogical(s)
        if s
            s = 'YES';
        else
            s = 'NO';
        end
    elseif ~ischar(s)
        s = '';
    end
end
%-------------------------------------------------------------------------%
end