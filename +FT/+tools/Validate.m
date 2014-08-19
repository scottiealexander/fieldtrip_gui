function bGood = Validate(strStage,varargin)

% FT.tools.Validate
%
% Description:
%
% Syntax: bGood = FT.tools.Validate(strStage,varargin)
%
% In:   strStage - the stage being run
%       varargin - name-value pairs where the value is a cell of strings
%         done: stages that must already be done
%         todo: stages that must not be done yet
%         warn: stages that are recommended to complete first
%
% Out:  bGood - true if the criteria requested are satisfied
%
% Updated: 2014-07-22
% Peter Horak

global FT_DATA

%make sure data has been loaded
if ~isfield(FT_DATA,'data') || isempty(FT_DATA.data)
    FT.UserInput(['\bf\color{yellow}Notification\color{black}: No data '...
        'has been loaded, please load data before proceeding'],...
        0,'button','OK','title','Notification');
    bGood = false;
    return;
end

opt = FT.ParseOpts(varargin,...
    'done', {},...
    'todo', {},...
    'warn', {} ...
    );

% Ignore names that are not fields of FT_DATA.done (ie. recognized stages)
opt.done = opt.done(isfield(FT_DATA.done,opt.done));
opt.todo = opt.todo(isfield(FT_DATA.done,opt.todo));
opt.warn = opt.warn(isfield(FT_DATA.done,opt.warn));

% Determine which elements satisfy the conditions
bDone = cellfun(@(x)  FT_DATA.done.(x)==true,opt.done);
bTodo = cellfun(@(x) ~FT_DATA.done.(x)==true,opt.todo);
bWarn = cellfun(@(x) ~FT_DATA.done.(x)==true,opt.warn);

% Not all the necessary stages are done
if ~all(bDone)
    % Format message contents
    missing = sprintf('''%s'', ',opt.done{~bDone});
    missing = (missing(1:end-2));
    c = FT.tools.Ternary(sum(~bDone) > 1,'s','');
    
    % Display message
    FT.UserInput(['\bf\color{yellow}Notification\color{black}: Stage ''' strStage ...
        ''' cannot be run before completing stage' c ' ' missing '.\n'],...
        0,'button','OK','title','Notification');
    bGood = false;

% Some stages are done that should not be (if this stage is to be run)
elseif ~all(bTodo)
    % Format message contents
    problems = sprintf('''%s'', ',opt.todo{~bTodo});
    problems = (problems(1:end-2));
    c = FT.tools.Ternary(sum(~bTodo) > 1,'s','');

    % Display message
    FT.UserInput(['\bf\color{yellow}Notification\color{black}: Stage ''' strStage ...
        ''' cannot be run after completing stage' c ' ' problems '.\n'],...
        0,'button','OK','title','Notification');
    bGood = false;
    
% Some stages should be run first
elseif any(bWarn)
    % Format message contents
    warnings = sprintf('''%s'', ',opt.warn{bWarn});
    warnings = (warnings(1:end-2));
    c = FT.tools.Ternary(sum(bWarn) > 1,'s','');

    % Display message
    resp = FT.UserInput(['\bf\color{yellow}Warning\color{black}: Stage ''' strStage ...
        ''' should not be run before completing stage' c ' ' warnings '. Continue?\n'],...
        0,'button',{'Continue','Cancel'},'title','Warning');
    bGood = strcmpi(resp,'continue');
    
else
    bGood = FT.tools.CheckStage(strStage);
end

end