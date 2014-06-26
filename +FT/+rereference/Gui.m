function Gui(varargin)

% FT.reference.Gui
%
% Description: get rereferencing parameters from user via a GUI
%
% Syntax: FT.reference.Gui
%
% In: 
%
% Out: 
%
% Updated: 2014-06-23
% Peter Horak
%
% See also: FT.reference.Run
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

%make sure we are ready to run
if ~FT.CheckStage('rereference')
    return;
end

%by default reference to the average of all channels
params = struct('refchannel','all');

c = {...
    {'text','String',['Select channels to use as reference:' char(10) '(default: all)']},...
    {'pushbutton','String','Select','CallBack',@SelectChannels};...
    {'pushbutton','String','Run'},...
    {'pushbutton','String','Cancel'};...
    };

win = FT.tools.Win(c,'title','Rereferencing Parameters','grid',false);
uiwait(win.h)

if strcmpi(win.res.btn,'cancel')
    return;
end

hMsg = FT.UserInput('Rereferencing data...',1);

me = FT.rereference.Run(params);
    
if ishandle(hMsg)
    close(hMsg);
end

FT.ProcessError(me);

FT.UpdateGUI;

%-------------------------------------------------------------------------%
function SelectChannels(obj,evt)
%allow user to select specific channels 
    %set the height of the figure
    nChan = numel(FT_DATA.data.label);
    if nChan < 40
        hFig = FT.tools.Inch2Px(0.171)*nChan;
    else
        hFig = FT.tools.Inch2Px(5);
    end
    wFig = FT.tools.Inch2Px(2.5);
    
    %get the users selection
    [kChan,b] = listdlg('Name','Select New Reference',...
       'ListString',FT_DATA.data.label,'ListSize',[wFig,hFig]);
   
    if b && ~isempty(kChan)
        params.refchannel = FT_DATA.data.label(kChan);
        set(obj,'String','Done');
    end
end
%-------------------------------------------------------------------------%
end
