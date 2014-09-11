function Gui()

% FT.events.relabel.Gui
%
% Description: get parameters for relabeling events
%
% Syntax: FT.events.relabel.Gui
%
% In: 
%
% Out: 
%
% See also: FT.events.relabel.Run
%
% Updated: 2014-08-21
% Peter Horak

global FT_DATA;

%make sure we are ready to run
if ~FT.tools.Validate('relabel_events','done',{'read_events'},'todo',{'define_trials'})
    return;
end

% Restructure the events struct
events = FT.ReStruct(FT_DATA.event);

% Make sure the events.value is a cell of strings that can be field names
if ~iscell(events.value)
    events.value = arrayfun(@(x) num2str(x),events.value,'uni',false);
elseif ~iscellstr(events.value)
    events.value = cellfun(@(x) num2str(x),events.value,'uni',false);
end
ver = version('-release');
if str2double(ver(1:4)) >= 2014
    events.value = matlab.lang.makeValidName(events.value);
else
    events.value = cellfun(@(x) genvarname(x),events.value,'uni',false);
end
    
% Create list of values along with # occurances
values = unique(events.value); % event values
valList = cellfun(@(x) ['"' x '"(' num2str(sum(strcmpi(x,events.value))) ')'],values,'uni',false);

% Cell array of event values (text) and input labels (edit)
textList = cellfun(@(x) {'text','string',x},valList,'uni',false);
editList = cellfun(@(x) {'edit','string','','tag',x,'callback',@UpdateColor},values,'uni',false);
inputFields = cat(2,textList,editList);

% Cell array of control buttons
buttons = {{'pushbutton','string','Save','callback',@Save},...
    {'pushbutton','string','Load','callback',@Load};...
    {'pushbutton','string','Done'},...
    {'pushbutton','string','Cancel'}};

% Create user input window with specified content (c)
c = cat(1,inputFields,buttons);
win = FT.tools.Win(c,'title','Relabel Events','grid',true,'focus',values{1});
win.Wait;

% User selected cancel
if strcmpi(win.res.btn,'cancel')
    return;
end

% Strip button field and use edit box inputs as the parameters
params = rmfield(win.res,'btn');

hMsg = FT.UserInput('Relabeling events...',1);

me = FT.events.relabel.Run(params);

if ishandle(hMsg)
    close(hMsg);
end

FT.ProcessError(me);

FT.UpdateGUI;

%-------------------------------------------------------------------------%
% Change the background color of an edit box to reflect its contents
function UpdateColor(obj,varargin)
    [~,color] = FT.events.relabel.ProcLabel(get(obj,'string'),get(obj,'tag'),events.value);
    set(obj,'BackgroundColor',color);
end
%-----------------------------------------------------------------------------%
% Save the current labels to a .evtc (event code) file
function Save(~,varargin)
    % Collect the codes (labels) for each event value in a struct
    evtc = struct;
    for i = 1:numel(values)
        evtc.(values{i}) = win.GetElementProp(values{i},'string');
    end
    
    % Choose a file to save the codes in
    [strName,strPath] = uiputfile({'*.evtc','Event code files (*.evtc)'},...
        'Save Event Code File',fullfile(FT_DATA.path.base_directory,'new_codes.evtc'));
    
    % Save the codes as a struct
    if ~isequal(strName,0) && ~isequal(strPath,0)
        strPathEvt = fullfile(strPath,strName);
        save(strPathEvt,'-struct','evtc');
    end
end
%-----------------------------------------------------------------------------%
% Load labels from a .evtc (event code) file
function Load(~,varargin)
    % Choose an event code file to load
    strDir = pwd;
    if isdir(FT_DATA.path.base_directory)
        cd(FT_DATA.path.base_directory);
    end
    [strName,strPath] = uigetfile({'*.evtc','Event code files (*.evtc)'},'Load Event Code File');
    cd(strDir);
    
    % Check that the user didn't select cancel
    if ~isequal(strName,0) && ~isequal(strPath,0)
        strPathEvt = fullfile(strPath,strName);
        
        % Attempt to load the codes
        err = []; try evtc = load(strPathEvt,'-mat'); catch err; end
        if ~isa(err,'MException') && ~isempty(evtc)
            
            % For each event type, if evtc has a corresponding code use it,
            % otherwise set the code to ''
            for i = 1:numel(values)
                if isfield(evtc,values{i})
                    win.SetElementProp(values{i},'string',evtc.(values{i}));
                else
                    win.SetElementProp(values{i},'string','');
                end
                UpdateColor(win.GetElementProp(values{i},'h'));
            end
        end
    end
end
%-------------------------------------------------------------------------%
end