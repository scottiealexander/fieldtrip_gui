function UpdateGUI()

% FT.UpdateGUI
%
% Description: update the FieldTrip GUI display figure, if figure cannot
%              be found aborts
%
% Syntax: FT.UpdateGUI
%
% In: 
%
% Out: 
%
% Updated: 2014-10-01
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA
if isempty(FT_DATA) || isempty(findobj('Type','figure','Name','FieldTrip GUI'))
    return;
end

gui = FT_DATA.gui;

FT_DATA.size = sprintf('%.1f MB',getfield(whos('FT_DATA'),'bytes')/1e6);

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
    strContent = strrep(tostring(strContent),'_','\_');
    strAdd = ['\bf' strField '\rm' ': ' strContent];

    %add to the display
    FT_DATA.gui.hText(kF,1) = text('String',strAdd,'Units','normalized','FontSize',12,...
        'Position',[gui.sizText(1) sizSpace(kF) 0],'Parent',gui.hAx);
end

drawnow;
%-------------------------------------------------------------------------%
function v = ExtractField(field)
    v = '';
    if FT.tools.IsFieldPath(field)
        if iscellstr(field)
            v = getfield(FT_DATA,field{:});
        elseif ischar(field)
            v = FT_DATA.(field);
        end
    end
end
%-------------------------------------------------------------------------%
function s = tostring(s)
    if isempty(s)
        s = 'no';
    elseif isnumeric(s)
        s = num2str(s);
    elseif islogical(s)
        s = FT.tools.Ternary(s,'yes','no');
    elseif ~ischar(s)
        s = '';
    end
            
end
%-------------------------------------------------------------------------%
end