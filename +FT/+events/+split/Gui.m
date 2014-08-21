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

% %make sure we are ready to run
% if ~FT.tools.Validate('relabel_events','done',{'read_events'},'todo',{'define_trials'})
%     return;
% end

% Create list of values along with # occurances
events = FT.ReStruct(FT_DATA.event); % events
events.value = cellfun(@(x) num2str(x),events.value,'uni',false); % make sure values are strings
values = unique(events.value); % event values
valList = cellfun(@(x) ['"' x '"(' num2str(sum(strcmpi(x,events.value))) ')'],values,'uni',false);

% Cell of
textList = cellfun(@(x) {'text','string',x},valList,'uni',false);
editList = cellfun(@(x) {'edit','string','','tag',x,'callback',@EditColor},values,'uni',false);

inputFields = cat(2,textList,editList);
buttons = {{'pushbutton','string','Save','callback',@Save},...
    {'pushbutton','string','Load','callback',@Load};...
    {'pushbutton','string','Done'},...
    {'pushbutton','string','Cancel'}};

c = cat(1,inputFields,buttons);

win = FT.tools.Win(c,'title','Relabel Events','grid',true,'focus',values{1});
win.Wait;

params = rmfield(win.res,'btn');


hMsg = FT.UserInput('Relabeling events...',1);

me = FT.evetns.split.Run(params);

if ishandle(hMsg)
    close(hMsg);
end

FT.ProcessError(me);

FT.UpdateGUI;

%-----------------------------------------------------------------------------%
function Save(~,varargin)    
    [strName,strPath] = uiputfile({'*.evtc','Event code files (*.evtc)'},...
        'Save Event Code File',fullfile(FT_DATA.path.base_directory,'new_codes.evtc'));
    
    if ~isequal(strName,0) && ~isequal(strPath,0)
        strPathEvt = fullfile(strPath,strName);
        
        evtc = struct;
        for i = 1:numel(values)
            evtc.(values{i}) = win.GetElementProp(values{i},'string');
        end
    
        save(strPathEvt,'-struct','evtc');
    end
end
%-----------------------------------------------------------------------------%
function Load(~,varargin)
    strDir = pwd;
    if isdir(FT_DATA.path.base_directory)
        cd(FT_DATA.path.base_directory);
    end
    [strName,strPath] = uigetfile({'*.evtc','Event code files (*.evtc)'},...
        'Load Event Code File');
    cd(strDir);
    
    if ~isequal(strName,0) && ~isequal(strPath,0)
        strPathEvt = fullfile(strPath,strName);
        
        me = []; try evtc = load(strPathEvt,'-mat'); catch me; end
        if ~isa(me,'MException') && ~isempty(evtc)
            
            for i = 1:numel(values)
                if isfield(evtc,values{i})
                    win.SetElementProp(values{i},'string',evtc.(values{i}));
                end
            end
        end
    end
end
%-------------------------------------------------------------------------%
function EditColor(obj,varargin)
    strPath = fullfile(FT_DATA.path.base_directory,[get(obj,'String') '.evta']);
    
    % The given string matches an .evta file in the current base directory
    if exist(strPath,'file') == 2
        % Try to load the file
        me = []; try map = load(strPath,'-mat','evta'); catch me; end
        
        if isa(me,'MException') || isempty(map)
            % Invalid event array file
            set(obj,'BackgroundColor',[1 1 .8]); % yellow
            hWarn = warndlg(['File with given name is invalid. Input string'...
                ' will be used as the new label.'],'Warning');
            uiwait(hWarn);
        elseif length(map.evta) ~= sum(strcmpi(get(obj,'tag'),events.value))
            % Length of event array doesn't match the # of event occurances
            set(obj,'BackgroundColor',[1 .8 .8]); % red
            hWarn = warndlg(['Length of label array in specified file does'...
                ' not match the number of event occurances.'],'Warning');
            uiwait(hWarn);
        else
            % The given string corresponds to a valid event array file
            set(obj,'BackgroundColor',[.8 1 1]); % blue
        end
    elseif isempty(get(obj,'String'))
        % No label specified
        set(obj,'BackgroundColor',[1 1 1]); % white
    else
        % Give given string matches no file and will be used as the label
        set(obj,'BackgroundColor',[.8 1 .8]); % green
    end
end
%-------------------------------------------------------------------------%
end